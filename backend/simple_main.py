import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List, Dict
import json

# Simple models
class QuestionRequest(BaseModel):
    question: str
    pdf: str = "harness_gear"
    ocr_method: str = "pymupdf"
    format: str = "json"

class QuestionResponse(BaseModel):
    success: bool
    pdf: str
    question: str
    answer: str
    confidence: Optional[float] = None

class HealthResponse(BaseModel):
    status: str
    message: str
    available_pdfs: List[str]

# Create FastAPI app
app = FastAPI(
    title="PDF QA API - Simplified",
    description="Basic PDF Question Answering system",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for now
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        message="PDF QA API is running (simplified version)",
        available_pdfs=["harness_gear", "skylight_mesh"]
    )

@app.post("/ask", response_model=QuestionResponse)
async def ask_question(request: QuestionRequest):
    """
    Basic question answering - returns a mock response for now
    """
    # For now, return a simple response to test deployment
    mock_answer = f"This is a test response for the question: '{request.question}'. The system is working but using simplified PDF processing."
    
    return QuestionResponse(
        success=True,
        pdf=request.pdf,
        question=request.question,
        answer=mock_answer,
        confidence=0.8
    )

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "PDF QA API - Simplified Version",
        "status": "running",
        "docs": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
