# AI Customer Support Chatbot

A full-stack AI-powered customer support chatbot built for live chat interactions. This application simulates a customer support experience where an AI agent answers user questions using Google's Gemini API.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Google Gemini API key ([Get one here](https://aistudio.google.com/apikey))

### Local Development

```bash
# Clone the repository
git clone <repository-url>
cd Agentic-Customer-Support-Chatbot

# Run the startup script (handles everything automatically)
npm start
```

The startup script will:
- ✅ Check Node.js version
- ✅ Install dependencies
- ✅ Set up environment variables
- ✅ Initialize database
- ✅ Start backend (port 3001) and frontend (port 5173)

**First time setup:** Edit `backend/.env` and add your `GEMINI_API_KEY`.

### Docker

**Option 1: Single Container (Recommended for Deployment)**
```bash
# Build and run both services in one container
docker build -t chatbot-app .
docker run -d -p 3001:3001 -p 3000:3000 \
  -e GEMINI_API_KEY=your_key_here \
  -e FRONTEND_URL=http://localhost:3000 \
  -e VITE_API_URL=http://localhost:3001 \
  -v chatbot-data:/app/data \
  chatbot-app
```

**Option 2: Docker Compose (Development)**
```bash
# Set up environment
cd backend && cp .env.example .env
# Edit .env and add GEMINI_API_KEY

# Start with Docker Compose
cd ..
docker-compose up --build
```

Access at:
- Frontend: http://localhost:3000 (single container) or http://localhost:5173 (docker-compose)
- Backend: http://localhost:3001

## 📚 Documentation

- **[Setup Guide](SETUP.md)** - Detailed setup instructions
- **[Deployment Guide](DEPLOYMENT.md)** - Docker and cloud deployment
- **[Docker Guide](DOCKER.md)** - Single Dockerfile deployment
- **[API Documentation](API.md)** - API endpoints reference
- **[Architecture](ARCHITECTURE.md)** - System architecture and design

## 🛠️ Tech Stack

- **Backend:** Node.js, TypeScript, Express, SQLite, Google Gemini API
- **Frontend:** SvelteKit, TypeScript, Vite
- **Features:** Real-time chat, conversation persistence, markdown rendering

## 📄 License

MIT License - see LICENSE file for details
