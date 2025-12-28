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
RUN mkdir -p /app/data

# Setup frontend
WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./

# Install frontend production dependencies
RUN npm ci --only=production

# Copy built frontend from builder
COPY --from=frontend-builder /app/frontend/build ./build

# Create startup script
WORKDIR /app
RUN echo '#!/bin/sh\n\
cd /app/backend && node dist/index.js &\n\
cd /app/frontend && node build/index.js &\n\
wait' > /app/start.sh && chmod +x /app/start.sh

# Alternative: Use concurrently (already installed)
RUN echo '#!/bin/sh\n\
cd /app && concurrently --kill-others-on-fail \
  "cd backend && PORT=3001 node dist/index.js" \
  "cd frontend && PORT=3000 node build/index.js"' > /app/start-concurrent.sh && chmod +x /app/start-concurrent.sh

# Expose ports
EXPOSE 3001 3000

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3001
ENV FRONTEND_PORT=3000

# Health check (checks backend)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start both services using concurrently
CMD ["sh", "/app/start-concurrent.sh"]

