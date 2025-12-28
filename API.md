# API Documentation

Complete API reference for the chatbot backend.

## Base URL

- **Development:** http://localhost:3001
- **Production:** Your backend domain

## Endpoints

### Chat Endpoints

#### POST `/chat/message`
Send a message to the AI agent.

**Request:**
```json
{
  "message": "What's your return policy?",
  "sessionId": "optional-uuid"
}
```

**Response:**
```json
{
  "reply": "We have a 30-day return policy...",
  "sessionId": "uuid-here"
}
```

#### GET `/chat/history/:sessionId`
Retrieve conversation history for a specific session.

**Response:**
```json
{
  "sessionId": "uuid-here",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "messages": [
    {
      "id": "msg-id",
      "conversationId": "uuid-here",
      "sender": "user",
      "text": "Hello",
      "timestamp": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### Data Endpoints

All data endpoints require API key authentication via:
- Header: `X-API-Key: your_api_key`
- Query parameter: `?apiKey=your_api_key`

#### GET `/data/conversations`
List all conversations with pagination.

**Query Parameters:**
- `limit` (optional, 1-100): Number of results
- `offset` (optional): Pagination offset

**Response:**
```json
{
  "conversations": [...],
  "pagination": {
    "total": 10,
    "limit": 10,
    "offset": 0,
    "hasMore": false
  }
}
```

#### GET `/data/conversations/:id`
Get a specific conversation with all messages.

**Response:**
```json
{
  "id": "uuid-here",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z",
  "messages": [...]
}
```

#### GET `/data/messages`
List all messages with optional filters.

**Query Parameters:**
- `limit` (optional, 1-100)
- `offset` (optional)
- `conversationId` (optional): Filter by conversation

**Response:**
```json
{
  "messages": [...],
  "pagination": {...},
  "filters": {
    "conversationId": "uuid-here"
  }
}
```

#### GET `/data/stats`
Get database statistics.

**Response:**
```json
{
  "totalConversations": 10,
  "totalMessages": 50,
  "userMessages": 25,
  "aiMessages": 25,
  "averageMessagesPerConversation": 5.0,
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### System Endpoints

#### GET `/health`
Health check endpoint with database connectivity.

**Response:**
```json
{
  "status": "ok",
  "database": "connected",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Authentication

Data endpoints (`/data/*`) require API key authentication:
- Set `API_KEY` environment variable in backend
- Include in requests via `X-API-Key` header or `?apiKey` query parameter

## Rate Limiting

- **Production:** 100 requests per 15 minutes per IP
- **Development:** 1000 requests per 15 minutes per IP
- Applied to `/chat` and `/data` endpoints

## Error Responses

All errors follow this format:
```json
{
  "error": "Error type",
  "message": "Human-readable error message"
}
```

**Status Codes:**
- `200` - Success
- `400` - Bad Request (validation error)
- `401` - Unauthorized (missing/invalid API key)
- `404` - Not Found
- `429` - Too Many Requests (rate limit)
- `500` - Internal Server Error
- `503` - Service Unavailable (database disconnected)

