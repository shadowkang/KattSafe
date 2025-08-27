import React, { useState, useEffect } from 'react';
import ChatInterface from './components/ChatInterface';
import Header from './components/Header';
import StatusPanel from './components/StatusPanel';
import './App.css';
import './components/styles.css';

function App() {
  const [apiStatus, setApiStatus] = useState('checking');
  const [availablePdfs, setAvailablePdfs] = useState([]);
  const [selectedPdf, setSelectedPdf] = useState('harness_gear');
  const [ocrMethod, setOcrMethod] = useState('pymupdf');

  // Check API status on component mount
  useEffect(() => {
    checkApiStatus();
  }, []);

  const checkApiStatus = async () => {
    try {
      const response = await fetch('/health');
      if (response.ok) {
        const data = await response.json();
        setApiStatus('connected');
        setAvailablePdfs(data.available_pdfs || []);
      } else {
        setApiStatus('error');
      }
    } catch (error) {
      console.error('API health check failed:', error);
      setApiStatus('error');
    }
  };

  return (
    <div className="App">
      <Header 
        apiStatus={apiStatus} 
        onRefresh={checkApiStatus}
      />
      
      <div className="app-container">
        <StatusPanel 
          apiStatus={apiStatus}
          availablePdfs={availablePdfs}
          selectedPdf={selectedPdf}
          ocrMethod={ocrMethod}
          onPdfChange={setSelectedPdf}
          onOcrMethodChange={setOcrMethod}
          onRefresh={checkApiStatus}
        />
        
        <ChatInterface 
          selectedPdf={selectedPdf}
          ocrMethod={ocrMethod}
          apiStatus={apiStatus}
        />
      </div>
    </div>
  );
}

export default App;
