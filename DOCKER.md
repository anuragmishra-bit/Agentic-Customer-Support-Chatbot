# Docker Deployment Guide

## Single Dockerfile Deployment

The root `Dockerfile` builds and runs both backend and frontend services in a single container.

### Build the Image

```bash
docker build -t chatbot-app .
```

### Run the Container

```bash
docker run -d \
  -p 3001:3001 \
  -p 3000:3000 \
  -e GEMINI_API_KEY=your_gemini_api_key_here \
  -e FRONTEND_URL=http://localhost:3000 \
  -e VITE_API_URL=http://localhost:3001 \
  -e DATABASE_PATH=/app/data/chatbot.db \
  -e API_KEY=your_secure_api_key_here \
  -v chatbot-data:/app/data \
  --name chatbot-app \
  chatbot-app
```

### Access the Application

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:3001
- **Health Check:** http://localhost:3001/health

### Environment Variables

**Required:**
- `GEMINI_API_KEY` - Your Google Gemini API key

**Optional:**
- `FRONTEND_URL` - Frontend URL for CORS (default: http://localhost:3000)
- `VITE_API_URL` - Backend URL for frontend (default: http://localhost:3001)
- `DATABASE_PATH` - Database file path (default: /app/data/chatbot.db)
- `API_KEY` - API key for data endpoints
- `PORT` - Backend port (default: 3001)
- `FRONTEND_PORT` - Frontend port (default: 3000)

### Using Docker Compose (Alternative)

For development or if you prefer separate containers, use `docker-compose.yml`:

```bash
docker-compose up --build
```

## Platform Deployment

### Render.com

1. Connect your GitHub repository
2. Create a new **Web Service**
3. Set **Dockerfile Path:** `Dockerfile`
4. Add environment variables
5. Deploy

**Note:** Render will automatically detect the Dockerfile and build it.

### Railway.app

1. Connect your GitHub repository
2. Railway will auto-detect the Dockerfile
3. Add environment variables
4. Deploy

### Fly.io

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Launch app
fly launch

# Set environment variables
fly secrets set GEMINI_API_KEY=your_key

# Deploy
fly deploy
```

### Heroku

```bash
# Login to Heroku
heroku login

# Create app
heroku create your-app-name

# Set environment variables
heroku config:set GEMINI_API_KEY=your_key

# Deploy
git push heroku main
```

## Port Configuration

The single Dockerfile exposes both ports:
- **3001** - Backend API
- **3000** - Frontend

Most platforms will automatically map these ports. Some platforms (like Render) may require you to set the port in environment variables.

## Health Checks

The Dockerfile includes a health check that monitors the backend service. The frontend service runs alongside it.

## Database Persistence

Use a Docker volume to persist the database:

```bash
docker run -v chatbot-data:/app/data ...
```

Or use a named volume in docker-compose.

## Troubleshooting

### Container won't start
- Check environment variables are set
- Verify `GEMINI_API_KEY` is provided
- Check logs: `docker logs chatbot-app`

### Services not accessible
- Verify ports are exposed correctly
- Check firewall/security group settings
- Ensure ports aren't already in use

### Database issues
- Ensure volume is mounted for persistence
- Check write permissions on `/app/data`
- Verify `DATABASE_PATH` environment variable

