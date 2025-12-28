# Architecture Documentation

System architecture and design decisions for the AI Customer Support Chatbot.

## System Overview

```
┌─────────────┐      HTTP/REST      ┌─────────────┐
│   Frontend  │ ◄─────────────────► │   Backend   │
│  (SvelteKit)│                      │  (Express)  │
└─────────────┘                      └──────┬──────┘
                                            │
                                            ▼
                                    ┌─────────────┐
                                    │   SQLite    │
                                    │  Database   │
                                    └─────────────┘
                                            │
                                            ▼
                                    ┌─────────────┐
                                    │   Gemini    │
                                    │     API     │
                                    └─────────────┘
```

## Backend Architecture

### Layers

1. **Routes Layer** (`routes/`)
   - HTTP request handling
   - Input validation (Zod)
   - Error handling

2. **Service Layer** (`services/`)
   - **ConversationService:** Database operations
   - **LLMService:** Gemini API integration

3. **Data Layer** (`db/`)
   - Database initialization
   - Schema definition
   - SQLite connection

### Key Components

**ConversationService:**
- Manages conversations and messages
- Handles CRUD operations
- Provides statistics

**LLMService:**
- Integrates with Google Gemini API (model: `gemini-2.5-flash`)
- Manages conversation context (last 10 messages)
- Handles prompt construction with domain knowledge (shipping, returns, support hours)
- Error handling and fallbacks (timeouts, rate limits, invalid keys)
- Token management (max 500 tokens, 2000 char message limit)

## Frontend Architecture

### Structure

- **Component-based:** Main chat logic in `ChatWidget.svelte`
- **API Abstraction:** All API calls in `lib/api.ts`
- **State Management:** Svelte reactivity
- **Session Persistence:** localStorage

### Features

- Markdown rendering for AI responses
- Real-time typing indicators
- Optimistic UI updates
- Error handling
- Session management

## Database Schema

### Conversations Table
```sql
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

### Messages Table
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  conversationId TEXT NOT NULL,
  sender TEXT NOT NULL CHECK(sender IN ('user', 'ai')),
  text TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (conversationId) REFERENCES conversations(id) ON DELETE CASCADE
)
```

**Indexes:**
- `idx_messages_conversationId` - Fast conversation lookups
- `idx_messages_timestamp` - Chronological sorting

## Security Features

1. **CORS:** Environment-aware, configurable origins
2. **Rate Limiting:** 100 req/15min in production
3. **API Key Auth:** For data endpoints
4. **Input Validation:** Zod schemas
5. **SQL Injection Protection:** Parameterized queries
6. **Request Size Limits:** 10mb JSON limit

## Design Decisions

### SQLite over PostgreSQL
- Chosen for simplicity and ease of setup
- Suitable for demo/small deployments
- Can be migrated to PostgreSQL for production

### Session-based Conversations
- Each conversation has unique UUID
- Persists in localStorage
- Allows conversation resumption

### Conversation History Context
- Last 10 messages included for LLM context
- Balances context with token costs
- Manages conversation continuity

### Error Resilience
- All LLM errors caught and converted to user-friendly messages
- Application never crashes on API failures
- Graceful degradation

## Technology Choices

**Backend:**
- **Express.js:** Mature, well-documented web framework
- **TypeScript:** Type safety and better DX
- **better-sqlite3:** Fast, synchronous SQLite driver
- **Zod:** Runtime type validation

**Frontend:**
- **SvelteKit:** Modern, performant framework
- **Vite:** Fast build tool
- **marked:** Markdown rendering

## Performance Considerations

- Database indexes for common queries
- Rate limiting to prevent abuse
- Request size limits
- Efficient SQL queries
- Optimistic UI updates

## LLM Integration

### Provider: Google Gemini
- **Model:** `gemini-2.5-flash`
- **API:** Google Generative AI SDK (`@google/generative-ai`)
- **Configuration:** Via `GEMINI_API_KEY` environment variable

### Prompt Design
The LLM receives:
1. **System Context:** Domain knowledge about SpurStore (shipping, returns, support hours)
2. **Conversation History:** Last 10 messages formatted as Customer/Support Agent dialogue
3. **Current Message:** User's current question

### Error Handling
- Invalid API key → User-friendly error message
- Rate limit exceeded → "Please try again in a moment"
- Timeout → "Request timed out. Please try again."
- Generic errors → Fallback friendly message

See [README.md](README.md#-llm-integration) for detailed LLM documentation.

## Future Improvements

1. **Database:** Migrate to PostgreSQL for production
2. **Caching:** Add Redis for session management
3. **Streaming:** Stream LLM responses for better UX
4. **Monitoring:** Add logging and metrics
5. **Testing:** Comprehensive test suite

