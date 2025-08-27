import React from 'react';
import { Activity, RefreshCw } from 'lucide-react';

const Header = ({ apiStatus, onRefresh }) => {
  const getStatusColor = () => {
    switch (apiStatus) {
      case 'connected': return '#28a745';
      case 'error': return '#dc3545';
      case 'checking': return '#ffc107';
      default: return '#6c757d';
    }
  };

  const getStatusText = () => {
    switch (apiStatus) {
      case 'connected': return 'Connected';
      case 'error': return 'Disconnected';
      case 'checking': return 'Checking...';
      default: return 'Unknown';
    }
  };

  return (
    <header className="header">
      <div className="header-content">
        <div className="header-left">
          <h1 className="header-title">
            📄 PDF QA Chatbot
          </h1>
          <span className="header-subtitle">
            Intelligent PDF Question Answering with OCR
          </span>
        </div>
        
        <div className="header-right">
          <div className="api-status">
            <Activity 
              size={16} 
              color={getStatusColor()}
              className={apiStatus === 'checking' ? 'pulse' : ''}
            />
            <span style={{ color: getStatusColor() }}>
              API: {getStatusText()}
            </span>
          </div>
          
          <button 
            className="btn btn-secondary"
            onClick={onRefresh}
            title="Refresh API Status"
          >
            <RefreshCw size={16} />
            Refresh
          </button>
        </div>
      </div>
    </header>
  );
};

export default Header;
