# Deployment Guide

Deployment instructions for Docker and cloud platforms.

## Docker Deployment

### Using Docker Compose (Recommended)

1. **Set up environment:**
   ```bash
   cd backend
   cp .env.example .env
   # Edit .env and set GEMINI_API_KEY
   ```

2. **Start services:**
   ```bash
   docker-compose up --build
   ```

3. **Access:**
   - Frontend: http://localhost:5173
   - Backend: http://localhost:3001

### Individual Docker Containers

**Backend:**
```bash
cd backend
docker build -t chatbot-backend .
docker run -p 3001:3001 \
  -e GEMINI_API_KEY=your_key \
  -e FRONTEND_URL=http://localhost:5173 \
  -e DATABASE_PATH=/app/data/chatbot.db \
  -v backend-data:/app/data \
  chatbot-backend
```

**Frontend:**
```bash
cd frontend
docker build -t chatbot-frontend .
docker run -p 5173:3000 \
  -e VITE_API_URL=http://localhost:3001 \
  chatbot-frontend
```

## Cloud Deployment

### Environment Variables

**Backend:**
- `GEMINI_API_KEY` (required)
- `FRONTEND_URL` (for CORS)
- `API_KEY` (for data endpoints)
- `DATABASE_PATH` (default: `./chatbot.db`)
- `PORT` (auto-set by platform)

**Frontend:**
- `VITE_API_URL` (backend URL)
- `PORT` (auto-set by platform)

### Platform-Specific Notes

**Render.com:**
- Use Web Service for both backend and frontend
- SQLite data may be lost on restart (ephemeral filesystem)
- Consider PostgreSQL for production

**Railway.app:**
- Auto-detects Node.js
- Supports persistent volumes for SQLite
- Better for SQLite than Render

**Fly.io:**
- Use `fly launch` for each service
- Supports persistent volumes
- Global edge network

**Vercel (Frontend only):**
- Excellent SvelteKit support
- Automatic deployments
- Use separate backend hosting

## Production Considerations

1. **Database:** Use PostgreSQL instead of SQLite for production
2. **Environment Variables:** Secure all API keys
3. **CORS:** Configure `FRONTEND_URL` correctly
4. **Rate Limiting:** Already configured (100 req/15min)
5. **Health Checks:** Both services have `/health` endpoints

## Docker Compose Configuration

The `docker-compose.yml` includes:
- Multi-stage builds for optimization
- Health checks for both services
- Persistent volume for database
- Environment variable configuration
- Automatic restart policies

