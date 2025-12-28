# Multi-stage build for full-stack application
FROM node:20-alpine AS backend-builder

WORKDIR /app/backend

# Copy backend package files
COPY backend/package*.json ./
COPY backend/tsconfig.json ./

# Install backend dependencies
RUN npm ci

# Copy backend source code
COPY backend/src ./src

# Build backend TypeScript
RUN npm run build

# Frontend builder stage
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./
COPY frontend/tsconfig.json ./
COPY frontend/svelte.config.js ./
COPY frontend/vite.config.ts ./

# Install frontend dependencies
RUN npm ci

# Copy frontend source code
COPY frontend/src ./src
# Copy static directory (now always exists, even if empty)
COPY frontend/static ./static

# Build frontend
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Install process manager for running both services
RUN npm install -g concurrently

# Setup backend
WORKDIR /app/backend

# Copy backend package files
COPY backend/package*.json ./

# Install backend production dependencies
RUN npm ci --only=production

# Copy built backend from builder
COPY --from=backend-builder /app/backend/dist ./dist

# Create data directory for database
RUN mkdir -p /app/data && chmod 777 /app/data

# Setup frontend
WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./

# Install frontend production dependencies
RUN npm ci --only=production

# Copy built frontend from builder
COPY --from=frontend-builder /app/frontend/build ./build

# Create startup script with better error handling
WORKDIR /app
RUN cat > /app/start-concurrent.sh << 'EOF'
#!/bin/sh
set -e

# Use Render's PORT if set, otherwise use defaults
FRONTEND_PORT=${PORT:-${FRONTEND_PORT:-3000}}
BACKEND_PORT=${BACKEND_PORT:-3001}

echo "=== Starting Application ==="
echo "NODE_ENV: ${NODE_ENV:-production}"
echo "Backend PORT: ${BACKEND_PORT}"
echo "Frontend PORT: ${FRONTEND_PORT}"
echo "Database path: ${DATABASE_PATH:-/app/data/chatbot.db}"

# Verify build outputs exist
echo "Verifying build outputs..."
if [ ! -f "/app/backend/dist/index.js" ]; then
  echo "ERROR: Backend build not found at /app/backend/dist/index.js"
  ls -la /app/backend/dist/ || echo "Backend dist directory does not exist"
  exit 1
fi
echo "✓ Backend build found"

if [ ! -f "/app/frontend/build/index.js" ]; then
  echo "ERROR: Frontend build not found at /app/frontend/build/index.js"
  ls -la /app/frontend/build/ || echo "Frontend build directory does not exist"
  exit 1
fi
echo "✓ Frontend build found"

# Ensure database directory exists and is writable
mkdir -p /app/data
chmod 777 /app/data
echo "✓ Database directory ready"

# Start services with concurrently
echo "Starting services..."
cd /app && exec concurrently --kill-others-on-fail --raw \
  "cd /app/backend && PORT=${BACKEND_PORT} DATABASE_PATH=${DATABASE_PATH:-/app/data/chatbot.db} node dist/index.js" \
  "cd /app/frontend && PORT=${FRONTEND_PORT} node build/index.js"
EOF
RUN chmod +x /app/start-concurrent.sh

# Expose ports
EXPOSE 3001 3000

# Set environment variables
ENV NODE_ENV=production
ENV BACKEND_PORT=3001
ENV FRONTEND_PORT=3000
ENV DATABASE_PATH=/app/data/chatbot.db

# Health check (checks backend)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start both services using concurrently
CMD ["sh", "/app/start-concurrent.sh"]

