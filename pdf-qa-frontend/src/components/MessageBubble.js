import React from 'react';
import { Bot, User, Copy, FileText, Award, Globe } from 'lucide-react';

const MessageBubble = ({ message, onCopy }) => {
  const { type, content, timestamp, confidence, citations, language, pdf, ocrMethod, isError } = message;

  const formatTime = (date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const getConfidenceColor = (conf) => {
    if (conf >= 0.8) return '#28a745'; // Green
    if (conf >= 0.6) return '#ffc107'; // Yellow
    return '#dc3545'; // Red
  };

  const getConfidenceLabel = (conf) => {
    if (conf >= 0.8) return 'High';
    if (conf >= 0.6) return 'Medium';
    return 'Low';
  };

  return (
    <div className={`message-bubble ${type}-message ${isError ? 'error-message' : ''} fade-in`}>
      <div className="message-avatar">
        {type === 'bot' ? <Bot size={16} /> : <User size={16} />}
      </div>
      
      <div className="message-content">
        <div className="message-text">
          {content}
        </div>
        
        {/* Bot message metadata */}
        {type === 'bot' && !isError && (
          <div className="message-metadata">
            {confidence !== null && (
              <div className="confidence-indicator">
                <Award size={12} />
                <span 
                  className="confidence-value"
                  style={{ color: getConfidenceColor(confidence) }}
                >
                  {getConfidenceLabel(confidence)} Confidence ({(confidence * 100).toFixed(0)}%)
                </span>
              </div>
            )}
            
            {language && (
              <div className="language-indicator">
                <Globe size={12} />
                <span>{language === 'en' ? 'English' : 'Chinese'}</span>
              </div>
            )}
            
            {pdf && (
              <div className="source-indicator">
                <FileText size={12} />
                <span>Source: {pdf}</span>
              </div>
            )}
          </div>
        )}
        
        {/* Citations */}
        {citations && citations.length > 0 && (
          <div className="citations">
            <div className="citations-title">📚 Sources:</div>
            {citations.map((citation, index) => (
              <div key={index} className="citation-item">
                <div className="citation-page">Page {citation.page}</div>
                <div className="citation-quote">"{citation.quote}"</div>
              </div>
            ))}
          </div>
        )}
        
        <div className="message-footer">
          <span className="message-time">{formatTime(timestamp)}</span>
          <button 
            className="copy-button"
            onClick={() => onCopy(content)}
            title="Copy message"
          >
            <Copy size={12} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default MessageBubble;
