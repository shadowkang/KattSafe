# PDF Question Answering Chatbot Frontend

A modern React-based chatbot interface for the PDF Question Answering API with OCR capabilities. This frontend provides an intuitive chat interface to interact with your FastAPI backend for intelligent PDF document analysis.

## 🌟 Features

### 💬 **Intelligent Chatbot Interface**
- Real-time conversation with your PDF documents
- Typing indicators and smooth animations
- Message history with timestamps
- Copy message functionality

### 📊 **Advanced Response Display**
- **Confidence scoring** - Visual indicators for answer reliability
- **Source citations** - Direct page references with quotes
- **Multi-language support** - Automatic language detection
- **Error handling** - Graceful error messages and retry options

### 🔧 **Configuration Panel**
- **PDF Selection** - Switch between available documents
- **OCR Method Selection** - Choose from PyMuPDF, PDF2Image, or No OCR
- **PDF Inspection** - View document structure and content preview
- **Real-time API status** - Connection monitoring and health checks

### 🎨 **Modern UI/UX**
- **Responsive design** - Works on desktop, tablet, and mobile
- **Glass morphism effects** - Modern translucent design
- **Smooth animations** - Engaging user interactions
- **Professional styling** - Clean and intuitive interface

### 🚀 **Performance & Reliability**
- **Real-time API communication** - Fast response times
- **Connection status monitoring** - Automatic reconnection
- **Sample questions** - Quick testing with predefined queries
- **Loading states** - Clear feedback during processing

## 📋 Prerequisites

Before running the frontend, ensure you have:

1. **Node.js** (version 16 or higher)
2. **npm** (comes with Node.js)
3. **FastAPI backend running** on `http://localhost:8000`

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd pdf-qa-frontend
npm install
```

### 2. Start the Development Server

```bash
npm start
```

The application will open automatically at `http://localhost:3000`

### 3. Verify Backend Connection

- The header should show "API: Connected" in green
- If not connected, ensure your FastAPI server is running on port 8000

## 📁 Project Structure

```
pdf-qa-frontend/
├── public/
│   ├── index.html          # Main HTML template
│   └── manifest.json       # PWA manifest
├── src/
│   ├── components/
│   │   ├── Header.js        # App header with status
│   │   ├── StatusPanel.js   # Configuration and PDF management
│   │   ├── ChatInterface.js # Main chat interface
│   │   ├── MessageBubble.js # Individual message component
│   │   └── styles.css       # Component styles
│   ├── App.js              # Main application component
│   ├── App.css             # Global styles
│   ├── index.js            # React entry point
│   └── index.css           # Base styles
├── package.json            # Dependencies and scripts
└── README.md              # This file
```

## 🎯 How to Use

### 1. **Select Your PDF**
- Use the Configuration panel to choose from available PDFs
- View PDF status (Available/Missing)
- Inspect PDF content to see page count and preview

### 2. **Choose OCR Method**
- **PyMuPDF (Default)**: Best for most PDFs with OCR fallback
- **PDF2Image + OCR**: Best for completely image-based PDFs
- **No OCR**: Direct text extraction only

### 3. **Ask Questions**
- Type your question in the chat input
- Use sample questions for quick testing
- View responses with confidence scores and citations

### 4. **Interpret Responses**
- **High Confidence (80%+)**: Reliable answers with strong evidence
- **Medium Confidence (60-80%)**: Good answers but verify if critical
- **Low Confidence (<60%)**: Uncertain answers, may need clarification

## 🔧 API Endpoints Used

The frontend communicates with these backend endpoints:

- `GET /health` - Check API status and available PDFs
- `POST /ask` - Send questions and receive answers
- `GET /pdfs` - List all available PDF documents
- `GET /inspect/{pdf_name}` - Get PDF content analysis

## 🎨 Customization

### Styling
- Modify `src/App.css` for global styles
- Update `src/components/styles.css` for component-specific styles
- Colors and themes can be customized using CSS custom properties

### Configuration
- Update `package.json` proxy setting if backend runs on different port
- Modify API base URL in components if needed

## 🛠️ Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run tests
- `npm eject` - Eject from Create React App (⚠️ irreversible)

## 📱 Responsive Design

The interface is fully responsive and optimized for:
- **Desktop** (1200px+): Full sidebar and chat interface
- **Tablet** (768px-1199px): Stacked layout with collapsible sidebar
- **Mobile** (<768px): Vertical stack with touch-friendly controls

## 🔒 Security Considerations

- API requests are proxied through the development server
- No sensitive data is stored in localStorage
- All communication is over HTTP (use HTTPS in production)

## 🐛 Troubleshooting

### Common Issues:

1. **"API: Disconnected" Error**
   - Ensure FastAPI server is running on port 8000
   - Check if backend is accessible at `http://localhost:8000/health`
   - Verify no firewall is blocking the connection

2. **Questions Not Working**
   - Verify PDF files exist in the backend directory
   - Check browser console for error messages
   - Ensure selected PDF is available (green status)

3. **Slow Responses**
   - OCR processing can take time for image-heavy PDFs
   - Try switching to "No OCR" method for faster results
   - Check backend server logs for processing details

### Debug Mode:
Open browser Developer Tools (F12) to view:
- Network requests to the API
- Console errors or warnings
- Application state and props

## 🚀 Production Deployment

### Build for Production:
```bash
npm run build
```

### Deploy Options:
- **Static hosting**: Netlify, Vercel, GitHub Pages
- **Server hosting**: Nginx, Apache with React build
- **Container deployment**: Docker with multi-stage build

### Environment Variables:
Create `.env` file for production configuration:
```
REACT_APP_API_URL=https://your-api-domain.com
REACT_APP_VERSION=1.0.0
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## 📄 License

This project is part of the KateSafe PDF QA system. Please refer to the main project license.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review browser console for error messages
3. Verify backend API is running and accessible
4. Check that PDF files are available in the backend directory

---

**Happy Chatting with your PDFs! 🎉📄💬**
