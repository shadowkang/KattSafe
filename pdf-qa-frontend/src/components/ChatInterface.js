import React, { useState, useRef, useEffect } from 'react';
import { Send, Bot, User, Copy, RefreshCw, AlertCircle } from 'lucide-react';
import MessageBubble from './MessageBubble';

const ChatInterface = ({ selectedPdf, ocrMethod, apiStatus, apiUrl }) => {
  const [messages, setMessages] = useState([]);
  const [inputMessage, setInputMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);

  // Use provided API URL or fallback to localhost
  const API_URL = apiUrl || 'http://localhost:8000';

  // Sample questions for quick testing
  const sampleQuestions = [
    "What is this manual about?",
    "What are the safety requirements mentioned in the manual?",
    "How do you operate the harness gear?",
    "What are the fixing details mentioned in this document?",
    "What are the installation procedures?",
    
  ];

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  useEffect(() => {
    // Add welcome message when component mounts
    if (messages.length === 0) {
      setMessages([{
        id: 1,
        type: 'bot',
        content: "👋 Hello! I'm your PDF Question Answering assistant. I can help you find information from your PDF documents using advanced OCR technology. Ask me anything about the selected PDF!",
        timestamp: new Date(),
        confidence: null,
        citations: []
      }]);
    }
  }, []);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const sendMessage = async (messageText = inputMessage) => {
    if (!messageText.trim() || isLoading || apiStatus !== 'connected') return;

    const userMessage = {
      id: Date.now(),
      type: 'user',
      content: messageText.trim(),
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setInputMessage('');
    setIsLoading(true);

    try {
      const response = await fetch(`${API_URL}/ask`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          question: messageText.trim(),
          pdf: selectedPdf,
          ocr_method: ocrMethod,
          format: 'json'
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      const botMessage = {
        id: Date.now() + 1,
        type: 'bot',
        content: data.answer || 'No answer received',
        timestamp: new Date(),
        confidence: data.confidence,
        citations: data.citations || [],
        language: data.language,
        pdf: data.pdf,
        ocrMethod: data.ocr_method
      };

      setMessages(prev => [...prev, botMessage]);
    } catch (error) {
      console.error('Error sending message:', error);
      
      const errorMessage = {
        id: Date.now() + 1,
        type: 'bot',
        content: `❌ Sorry, I encountered an error: ${error.message}. Please check if the API server is running and try again.`,
        timestamp: new Date(),
        confidence: null,
        citations: [],
        isError: true
      };

      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const clearChat = () => {
    setMessages([{
      id: 1,
      type: 'bot',
      content: "Chat cleared! How can I help you with your PDF documents?",
      timestamp: new Date(),
      confidence: null,
      citations: []
    }]);
  };

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).then(() => {
      // Could add a toast notification here
    });
  };

  return (
    <div className="chat-interface">
      <div className="chat-header">
        <div className="chat-title">
          <Bot size={20} />
          PDF QA Assistant
        </div>
        <div className="chat-info">
          PDF: <strong>{selectedPdf}</strong> | OCR: <strong>{ocrMethod}</strong>
        </div>
        <button 
          className="btn btn-secondary btn-sm"
          onClick={clearChat}
          title="Clear Chat"
        >
          <RefreshCw size={16} />
          Clear
        </button>
      </div>

      <div className="messages-container">
        {messages.map((message) => (
          <MessageBubble
            key={message.id}
            message={message}
            onCopy={copyToClipboard}
          />
        ))}
        
        {isLoading && (
          <div className="message-bubble bot-message loading-message fade-in">
            <div className="message-avatar">
              <Bot size={16} />
            </div>
            <div className="message-content">
              <div className="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
              <div className="message-meta">
                Processing your question...
              </div>
            </div>
          </div>
        )}
        
        <div ref={messagesEndRef} />
      </div>

      {apiStatus !== 'connected' && (
        <div className="connection-warning">
          <AlertCircle size={16} />
          API connection required to send messages
        </div>
      )}

      <div className="sample-questions">
        <div className="sample-questions-title">💡 Sample Questions:</div>
        <div className="sample-questions-list">
          {sampleQuestions.map((question, index) => (
            <button
              key={index}
              className="sample-question-btn"
              onClick={() => sendMessage(question)}
              disabled={isLoading || apiStatus !== 'connected'}
            >
              {question}
            </button>
          ))}
        </div>
      </div>

      <div className="chat-input-container">
        <div className="chat-input-wrapper">
          <textarea
            ref={inputRef}
            className="chat-input"
            value={inputMessage}
            onChange={(e) => setInputMessage(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Ask a question about your PDF document..."
            rows={1}
            disabled={isLoading || apiStatus !== 'connected'}
          />
          <button
            className="send-button"
            onClick={() => sendMessage()}
            disabled={!inputMessage.trim() || isLoading || apiStatus !== 'connected'}
          >
            <Send size={18} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ChatInterface;
