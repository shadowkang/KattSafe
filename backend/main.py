import os
import json
import concurrent.futures
from typing import Optional, List, Dict
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pdf_qa import pdf_qa, extract_pdf_text_per_page

# Pydantic models for request/response
class QuestionRequest(BaseModel):
    question: str
    pdf: str = "harness_gear"
    ocr_method: str = "pymupdf"
    format: str = "json"

class Citation(BaseModel):
    page: int
    quote: str

class QuestionResponse(BaseModel):
    success: bool
    pdf: str
    question: str
    ocr_method: str
    answer: str
    confidence: Optional[float] = None
    language: Optional[str] = None
    citations: Optional[List[Citation]] = None
    format: Optional[str] = None

class HealthResponse(BaseModel):
    status: str
    message: str
    available_pdfs: List[str]
    ocr_methods: List[str]

class PDFInfo(BaseModel):
    path: str
    exists: bool
    filename: str

class PDFListResponse(BaseModel):
    available_pdfs: Dict[str, PDFInfo]
    total_count: int

class PDFInspectionResponse(BaseModel):
    pdf_name: str
    filename: str
    total_pages: int
    total_characters: int
    preview_pages: List[Dict]

# Create FastAPI app
app = FastAPI(
    title="PDF Question Answering API",
    description="Advanced PDF Question Answering system with OCR capabilities using Azure OpenAI",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS configuration
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# PDF paths configuration
PDF_BASE_PATH = os.getenv("PDF_BASE_PATH", "./pdfs")
AVAILABLE_PDFS = {
    "harness_gear": os.path.join(PDF_BASE_PATH, "harness-gear-operation-manual.pdf"),
    "skylight_mesh": os.path.join(PDF_BASE_PATH, "2920-sp391-sp392-skylight-mesh-fixing-details-with-clip.pdf")
}

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint with API status"""
    return HealthResponse(
        status="healthy",
        message="PDF QA FastAPI is running",
        available_pdfs=list(AVAILABLE_PDFS.keys()),
        ocr_methods=["pymupdf", "pdf2image", "no_ocr"]
    )

@app.post("/ask", response_model=QuestionResponse)
async def ask_question(request: QuestionRequest):
    """
    Ask questions about PDF documents with OCR support
    """
    try:
        # Determine PDF path
        if request.pdf in AVAILABLE_PDFS:
            pdf_path = AVAILABLE_PDFS[request.pdf]
        else:
            pdf_path = request.pdf
        
        # Check if PDF exists
        if not os.path.exists(pdf_path):
            raise HTTPException(
                status_code=404,
                detail={
                    "error": f"PDF not found: {pdf_path}",
                    "available_pdfs": list(AVAILABLE_PDFS.keys())
                }
            )
        
        # Process the question (run in thread to avoid blocking)
        def process_question():
            return pdf_qa(pdf_path, request.question, 
                         format_type=request.format, 
                         ocr_method=request.ocr_method)
        
        # Run in executor to avoid blocking
        with concurrent.futures.ThreadPoolExecutor() as executor:
            future = executor.submit(process_question)
            answer = future.result(timeout=60)  # 60 second timeout
        
        # Parse answer if JSON format
        if request.format == "json":
            try:
                parsed_answer = json.loads(answer)
                citations = [
                    Citation(page=cite.get('page', 0), quote=cite.get('quote', ''))
                    for cite in parsed_answer.get('citations', [])
                ]
                
                return QuestionResponse(
                    success=True,
                    pdf=os.path.basename(pdf_path),
                    question=request.question,
                    ocr_method=request.ocr_method,
                    answer=parsed_answer.get('answer', 'No answer'),
                    confidence=parsed_answer.get('confidence', 0),
                    language=parsed_answer.get('language', 'en'),
                    citations=citations
                )
            except json.JSONDecodeError:
                return QuestionResponse(
                    success=True,
                    pdf=os.path.basename(pdf_path),
                    question=request.question,
                    ocr_method=request.ocr_method,
                    answer=answer,
                    format="raw_text"
                )
        else:
            return QuestionResponse(
                success=True,
                pdf=os.path.basename(pdf_path),
                question=request.question,
                ocr_method=request.ocr_method,
                answer=answer,
                format="free_text"
            )
            
    except concurrent.futures.TimeoutError:
        raise HTTPException(status_code=408, detail="Request timeout - processing took too long")
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": f"Processing error: {str(e)}",
                "success": False
            }
        )

@app.get("/pdfs", response_model=PDFListResponse)
async def list_pdfs():
    """List all available PDF documents"""
    pdf_info = {}
    for name, path in AVAILABLE_PDFS.items():
        pdf_info[name] = PDFInfo(
            path=path,
            exists=os.path.exists(path),
            filename=os.path.basename(path)
        )
    
    return PDFListResponse(
        available_pdfs=pdf_info,
        total_count=len(AVAILABLE_PDFS)
    )

@app.get("/inspect/{pdf_name}", response_model=PDFInspectionResponse)
async def inspect_pdf(pdf_name: str):
    """Inspect PDF content and structure"""
    if pdf_name not in AVAILABLE_PDFS:
        raise HTTPException(
            status_code=404,
            detail=f"PDF '{pdf_name}' not found. Available: {list(AVAILABLE_PDFS.keys())}"
        )
    
    pdf_path = AVAILABLE_PDFS[pdf_name]
    if not os.path.exists(pdf_path):
        raise HTTPException(
            status_code=404,
            detail=f"PDF file does not exist: {pdf_path}"
        )
    
    try:
        # Run PDF extraction in thread
        def extract_pages():
            return extract_pdf_text_per_page(pdf_path, use_ocr=True)
        
        with concurrent.futures.ThreadPoolExecutor() as executor:
            future = executor.submit(extract_pages)
            pages = future.result(timeout=30)
        
        preview_pages = []
        for i, page_text in enumerate(pages[:3], 1):  # Show first 3 pages
            preview_pages.append({
                "page_number": i,
                "character_count": len(page_text.strip()),
                "preview": page_text.strip()[:300] + "..." if len(page_text.strip()) > 300 else page_text.strip()
            })
        
        return PDFInspectionResponse(
            pdf_name=pdf_name,
            filename=os.path.basename(pdf_path),
            total_pages=len(pages),
            preview_pages=preview_pages,
            total_characters=sum(len(page.strip()) for page in pages)
        )
        
    except concurrent.futures.TimeoutError:
        raise HTTPException(status_code=408, detail="PDF inspection timeout")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error inspecting PDF: {str(e)}")

@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "PDF Question Answering API with FastAPI",
        "version": "2.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
        "endpoints": {
            "health": "/health",
            "ask": "/ask (POST)",
            "pdfs": "/pdfs",
            "inspect": "/inspect/{pdf_name}"
        }
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    uvicorn.run(app, host=host, port=port)
