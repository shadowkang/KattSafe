import React, { useState, useEffect } from 'react';
import { FileText, Settings, Eye, AlertCircle } from 'lucide-react';

const StatusPanel = ({ 
  apiStatus, 
  availablePdfs, 
  selectedPdf, 
  ocrMethod, 
  onPdfChange, 
  onOcrMethodChange, 
  onRefresh 
}) => {
  const [pdfList, setPdfList] = useState({});
  const [inspectionData, setInspectionData] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (apiStatus === 'connected') {
      fetchPdfList();
    }
  }, [apiStatus]);

  const fetchPdfList = async () => {
    try {
      const response = await fetch('/pdfs');
      if (response.ok) {
        const data = await response.json();
        setPdfList(data.available_pdfs || {});
      }
    } catch (error) {
      console.error('Failed to fetch PDF list:', error);
    }
  };

  const inspectPdf = async (pdfName) => {
    setLoading(true);
    try {
      const response = await fetch(`/inspect/${pdfName}`);
      if (response.ok) {
        const data = await response.json();
        setInspectionData(data);
      }
    } catch (error) {
      console.error('Failed to inspect PDF:', error);
    } finally {
      setLoading(false);
    }
  };

  const ocrMethods = [
    { value: 'pymupdf', label: 'PyMuPDF (Default)' },
    { value: 'pdf2image', label: 'PDF2Image + OCR' },
    { value: 'no_ocr', label: 'No OCR' }
  ];

  return (
    <div className="status-panel">
      <div className="panel-section">
        <h3 className="panel-title">
          <Settings size={18} />
          Configuration
        </h3>
        
        <div className="form-group">
          <label className="form-label">Select PDF Document</label>
          <select 
            className="form-control form-select"
            value={selectedPdf}
            onChange={(e) => onPdfChange(e.target.value)}
          >
            {Object.entries(pdfList).map(([key, info]) => (
              <option key={key} value={key}>
                {info.filename} {!info.exists && '(Missing)'}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label className="form-label">OCR Method</label>
          <select 
            className="form-control form-select"
            value={ocrMethod}
            onChange={(e) => onOcrMethodChange(e.target.value)}
          >
            {ocrMethods.map((method) => (
              <option key={method.value} value={method.value}>
                {method.label}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="panel-section">
        <h3 className="panel-title">
          <FileText size={18} />
          Available PDFs
        </h3>
        
        <div className="pdf-list">
          {Object.entries(pdfList).map(([key, info]) => (
            <div key={key} className="pdf-item">
              <div className="pdf-info">
                <div className="pdf-name">{info.filename}</div>
                <div className="pdf-status">
                  {info.exists ? (
                    <span className="status-badge status-success">Available</span>
                  ) : (
                    <span className="status-badge status-error">Missing</span>
                  )}
                </div>
              </div>
              
              {info.exists && (
                <button 
                  className="btn-inspect"
                  onClick={() => inspectPdf(key)}
                  disabled={loading}
                  title="Inspect PDF Content"
                >
                  <Eye size={14} />
                </button>
              )}
            </div>
          ))}
        </div>
      </div>

      {inspectionData && (
        <div className="panel-section">
          <h3 className="panel-title">
            <Eye size={18} />
            PDF Inspection
          </h3>
          
          <div className="inspection-details">
            <div className="inspection-item">
              <strong>Document:</strong> {inspectionData.filename}
            </div>
            <div className="inspection-item">
              <strong>Pages:</strong> {inspectionData.total_pages}
            </div>
            <div className="inspection-item">
              <strong>Characters:</strong> {inspectionData.total_characters?.toLocaleString()}
            </div>
            
            {inspectionData.preview_pages && inspectionData.preview_pages.length > 0 && (
              <div className="preview-section">
                <strong>Preview:</strong>
                {inspectionData.preview_pages.slice(0, 2).map((page, index) => (
                  <div key={index} className="preview-page">
                    <div className="preview-header">Page {page.page_number}</div>
                    <div className="preview-content">
                      {page.preview}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {apiStatus === 'error' && (
        <div className="panel-section">
          <div className="error-message">
            <AlertCircle size={18} />
            <div>
              <strong>API Connection Error</strong>
              <p>Cannot connect to the PDF QA API. Please ensure the FastAPI server is running on port 8000.</p>
              <button className="btn btn-primary mt-2" onClick={onRefresh}>
                Retry Connection
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default StatusPanel;
