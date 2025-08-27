import os
from typing import List, Dict, Optional
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# ---------- Azure OpenAI Setup ----------
def setup_azure_openai():
    """Setup Azure OpenAI client"""
    try:
        from openai import AzureOpenAI
        
        # Azure OpenAI configuration from environment
        api_key = os.getenv("AZURE_OPENAI_API_KEY", "8OgwTbueNSFrNWeEUZ2tOgnlVwYC7PXLiULoOZKz6JQgWkNcWjucJQQJ99BHACL93NaXJ3w3AAAAACOGzn2y")
        endpoint = os.getenv("AZURE_OPENAI_ENDPOINT", "https://azureaitestenv.cognitiveservices.azure.com/")
        deployment = os.getenv("AZURE_OPENAI_DEPLOYMENT", "gpt-4")
        api_version = os.getenv("AZURE_OPENAI_API_VERSION", "2024-02-01")
        
        client = AzureOpenAI(
            api_key=api_key,
            api_version=api_version,
            azure_endpoint=endpoint
        )
        
        return client, deployment
    except Exception as e:
        print(f"Azure OpenAI setup failed: {e}")
        print("Using mock client for demonstration...")
        
        # Mock client for demonstration
        class MockClient:
            class Chat:
                class Completions:
                    def create(self, **kwargs):
                        class MockResponse:
                            def __init__(self):
                                self.choices = [MockChoice()]
                        class MockChoice:
                            def __init__(self):
                                self.message = MockMessage()
                        class MockMessage:
                            def __init__(self):
                                self.content = '{"answer": "Mock response - please configure Azure OpenAI credentials", "confidence": 0.5, "language": "en", "citations": []}'
                        return MockResponse()
                
                def __init__(self):
                    self.completions = self.Completions()
            
            def __init__(self):
                self.chat = self.Chat()
        
        return MockClient(), "mock-deployment"

# Setup Azure OpenAI
client, deployment = setup_azure_openai()

# ---------- Simplified PDF text extraction (no OCR) ----------
def extract_pdf_text_per_page(pdf_path: str, use_ocr: bool = True) -> List[str]:
    """
    Extract text per page using PyMuPDF (fitz) - basic text extraction only.
    """
    try:
        import fitz  # PyMuPDF
    except ImportError as e:
        print(f"PyMuPDF import error: {e}")
        return []

    try:
        doc = fitz.open(pdf_path)
        pages = []
        
        for page_num, page in enumerate(doc, 1):
            # Extract text directly
            text = page.get_text("text")
            
            # If no text found, try blocks method
            if not text.strip():
                text_blocks = page.get_text("blocks")
                if isinstance(text_blocks, list):
                    text = "\n".join([b[4] for b in text_blocks if len(b) >= 5 and isinstance(b[4], str)])
            
            pages.append(text.strip())
        
        doc.close()
        return pages
        
    except Exception as e:
        print(f"Error extracting PDF text: {e}")
        return []

# ---------- Fallback method (same as above) ----------
def extract_pdf_text_with_pdf2image(pdf_path: str) -> List[str]:
    """
    Fallback method - same as basic extraction since OCR is not available
    """
    print("pdf2image OCR not available, using basic text extraction")
    return extract_pdf_text_per_page(pdf_path, use_ocr=False)

# ---------- Prompt templates ----------
JSON_PROMPT = """You are an assistant that answers questions strictly from the provided PDF content.

Output JSON schema (return valid JSON only, no extra text):
{{
  "answer": "<concise answer or the exact string: The provided PDF does not contain enough information to answer this question.>",
  "language": "en|zh",
  "citations": [
    {{
      "page": <integer page number, 1-based>,
      "quote": "<short supporting snippet from that page>"
    }}
  ],
  "confidence": <float 0..1>
}}

Rules:
- Use only the PDF content below.
- If uncertain or unsupported by the text, use the exact insufficiency string above.
- Keep "answer" ≤ 120 words unless the question explicitly asks for a long explanation.
- Always include at least one citation when you provide a substantive answer.
- Match the user's language (English/Chinese) for "answer" and "language".
- Do not invent references.

PDF CONTENT (paged):
{pdf_text_block}

QUESTION:
{user_question}
"""

def build_paged_block(docs_pages: Dict[str, List[str]], max_chars: int = 120000) -> str:
    """
    Turn multiple PDFs into a single paged text block
    """
    lines = []
    total = 0
    for fname, pages in docs_pages.items():
        for i, text in enumerate(pages, start=1):
            header = f"=== {os.path.basename(fname)} — Page {i} ==="
            chunk = f"{header}\n{text}\n"
            if total + len(chunk) > max_chars:
                return "\n".join(lines)
            lines.append(chunk)
            total += len(chunk)
    return "\n".join(lines)

# ---------- Azure OpenAI caller ----------
def call_azure_openai(prompt: str, format_type: str = "json") -> str:
    """
    Calls Azure OpenAI chat completions endpoint.
    """
    if format_type == "json":
        system_message = "You only answer from the provided PDF content. Return valid JSON only."
    else:
        system_message = "You only answer from the provided PDF content."
    
    resp = client.chat.completions.create(
        model=deployment,
        messages=[
            {"role": "system", "content": system_message},
            {"role": "user", "content": prompt},
        ],
        temperature=0.1,
        max_tokens=1000,
    )
    return resp.choices[0].message.content.strip()

# ---------- Enhanced QA function with OCR options ----------
def pdf_qa(pdf_path: str, question: str, format_type: str = "json", max_chars: int = 120000, 
           ocr_method: str = "pymupdf") -> str:
    """
    Enhanced PDF Question Answering with OCR support
    """
    # Check if file exists
    if not os.path.exists(pdf_path):
        return f"Error: File not found: {pdf_path}"
    
    try:
        if ocr_method == "pdf2image":
            pages = extract_pdf_text_with_pdf2image(pdf_path)
        elif ocr_method == "no_ocr":
            pages = extract_pdf_text_per_page(pdf_path, use_ocr=False)
        else:  # pymupdf (default)
            pages = extract_pdf_text_per_page(pdf_path, use_ocr=True)
        
        if not pages:
            return "Error: Could not extract any text from PDF"
            
        docs_pages = {pdf_path: pages}
        
        # Build paged text block
        pdf_text_block = build_paged_block(docs_pages, max_chars=max_chars)
        
        # Build prompt
        prompt = JSON_PROMPT.format(pdf_text_block=pdf_text_block, user_question=question)
        
        # Call Azure OpenAI
        answer = call_azure_openai(prompt, format_type)
        
        return answer
        
    except Exception as e:
        return f"Error processing PDF: {str(e)}"
