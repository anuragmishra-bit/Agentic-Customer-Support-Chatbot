# Setup Guide

Detailed instructions for setting up the AI Customer Support Chatbot.

## Prerequisites

- **Node.js 18+** and npm
- **Google Gemini API key** ([Get one here](https://aistudio.google.com/apikey))

## Quick Setup (Recommended)

Use the automated startup script:

```bash
npm start
```

This handles everything automatically. On first run, you'll need to:
1. Add your `GEMINI_API_KEY` to `backend/.env`
2. Restart the script

## Manual Setup

### 1. Install Dependencies

```bash
# Install all dependencies
npm run install:all

# Or install separately
npm install
cd backend && npm install
cd ../frontend && npm install
```

### 2. Environment Variables

**Backend:**
```bash
cd backend
cp .env.example .env
```

Edit `backend/.env`:
```env
PORT=3001
NODE_ENV=development
GEMINI_API_KEY=your_gemini_api_key_here
DATABASE_PATH=./chatbot.db
FRONTEND_URL=http://localhost:5173
API_KEY=your_secure_api_key_here
```

**Frontend:**
```bash
cd frontend
cp .env.example .env
```

Edit `frontend/.env`:
```env
VITE_API_URL=http://localhost:3001
```

### 3. Initialize Database

```bash
cd backend
npm run migrate
```

### 4. Start Development Servers

**Option A: Using the startup script**
```bash
npm start
```

**Option B: Manual start**
```bash
# Terminal 1 - Backend
cd backend
npm run dev

# Terminal 2 - Frontend
cd frontend
npm run dev
```

## Access the Application

- **Frontend:** http://localhost:5173
- **Backend API:** http://localhost:3001
- **Health Check:** http://localhost:3001/health

## Troubleshooting

### Backend won't start
- Check that `GEMINI_API_KEY` is set in `backend/.env`
- Ensure port 3001 is not in use
- Run `npm run migrate` to initialize database

### Frontend can't connect
- Verify backend is running on port 3001
- Check `VITE_API_URL` in `frontend/.env`
- Check CORS settings in backend

### Database errors
- Delete `backend/chatbot.db` and run `npm run migrate` again
- Ensure write permissions in backend directory

