# AI Customer Support Chatbot

A full-stack AI-powered customer support chatbot built for live chat interactions. This application simulates a customer support experience where an AI agent answers user questions using Google's Gemini API.

**Built for:** Spur Software Engineer Hiring Assignment  
**Tech Stack:** Node.js + TypeScript, SvelteKit, SQLite, Google Gemini API

---

## 📋 Table of Contents

- [Local Setup (Recommended)](#-local-setup-recommended)
- [Manual Setup (Alternative)](#-manual-setup-alternative)
- [How to Run Locally](#-how-to-run-locally)
- [Database Setup](#-database-setup)
- [Environment Variables](#-environment-variables)
- [Architecture Overview](#-architecture-overview)
- [LLM Integration](#-llm-integration)
- [Functional Requirements](#-functional-requirements)
- [Trade-offs & Future Improvements](#-trade-offs--future-improvements)
- [Additional Documentation](#-additional-documentation)

---

## 🚀 Local Setup (Recommended)

### Prerequisites

- **Node.js 18+** and npm
- **Google Gemini API key** ([Get one here](https://aistudio.google.com/apikey))

### Quick Start with Automated Script

The easiest way to set up and run the application locally is using the automated startup script:

```bash
# Clone the repository
git clone <repository-url>
cd Agentic-Customer-Support-Chatbot

# Run the automated setup and start script
node start.js
```

Or using npm:

```bash
npm start
```

### What the Script Does

The `start.js` script automatically handles everything for you:

1. **✅ Checks Node.js version** - Verifies Node.js 18+ is installed
2. **✅ Checks npm** - Ensures npm is available
3. **✅ Installs dependencies** - Automatically installs:
   - Root dependencies
   - Backend dependencies (`backend/node_modules`)
   - Frontend dependencies (`frontend/node_modules`)
4. **✅ Sets up environment variables** - Creates `backend/.env` from template if missing
5. **✅ Initializes database** - Creates SQLite database and tables if they don't exist
6. **✅ Starts both servers** - Launches:
   - Backend server on `http://localhost:3001`
   - Frontend server on `http://localhost:5173`

### First-Time Setup

On your first run, the script will:

1. Create `backend/.env` file with default values
2. Show a warning that `GEMINI_API_KEY` needs to be configured
3. Start the servers (they'll run but API calls will fail until you add the key)

**To complete setup:**

1. Open `backend/.env` in your editor
2. Replace `your_gemini_api_key_here` with your actual Gemini API key:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```
3. Save the file
4. Restart the script:
   ```bash
   node start.js
   # or
   npm start
   ```

### Access the Application

Once the script is running, you'll see:

```
============================================================
  Application is running!
============================================================

Backend: http://localhost:3001
Frontend: http://localhost:5173

Open your browser and visit: http://localhost:5173
```

- **Frontend (Chat UI):** http://localhost:5173
- **Backend API:** http://localhost:3001
- **Health Check:** http://localhost:3001/health

**To stop the servers:** Press `Ctrl+C` in the terminal

---

## 🔧 Manual Setup (Alternative)

If you prefer to set up manually or the automated script doesn't work for you:

### Step 1: Install Dependencies

```bash
# Install all dependencies (root, backend, frontend)
npm run install:all

# Or install separately:
npm install
cd backend && npm install
cd ../frontend && npm install
```

### Step 2: Configure Environment Variables

#### Backend Configuration

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

**Required:**
- `GEMINI_API_KEY` - Your Google Gemini API key ([Get one here](https://aistudio.google.com/apikey))

**Optional:**
- `PORT` - Backend server port (default: 3001)
- `DATABASE_PATH` - SQLite database file path (default: `./chatbot.db`)
- `FRONTEND_URL` - Frontend URL for CORS (default: `http://localhost:5173`)
- `API_KEY` - API key for data endpoints (optional, for admin access)

#### Frontend Configuration

```bash
cd frontend
cp .env.example .env
```

Edit `frontend/.env`:

```env
VITE_API_URL=http://localhost:3001
```

**Required:**
- `VITE_API_URL` - Backend API URL (default: `http://localhost:3001`)

### Step 3: Initialize Database

The database is automatically initialized when the backend server starts for the first time. However, you can also initialize it manually:

```bash
cd backend
npm run migrate
```

This creates:
- `conversations` table - Stores conversation sessions
- `messages` table - Stores all user and AI messages
- Indexes for efficient queries

**Note:** The database file (`chatbot.db` by default) will be created automatically in the backend directory on first run.

### Step 4: Start Development Servers

**Option A: Using the startup script (Recommended)**
```bash
node start.js
# or
npm start
```

**Option B: Manual start (two terminals)**

Terminal 1 - Backend:
```bash
cd backend
npm run dev
```

Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
```

---

## 🗄️ Database Setup

### Automatic Initialization

The database is automatically initialized when you run `node start.js` or when the backend server starts for the first time. No manual setup required!

### Manual Initialization

If you need to manually initialize or reset the database:

```bash
cd backend
npm run migrate
```

### Database Schema

The database uses SQLite and includes:

**Conversations Table:**
```sql
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
```

**Messages Table:**
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  conversationId TEXT NOT NULL,
  sender TEXT NOT NULL CHECK(sender IN ('user', 'ai')),
  text TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (conversationId) REFERENCES conversations(id) ON DELETE CASCADE
);
```

**Indexes:**
- `idx_messages_conversationId` - Fast conversation lookups
- `idx_messages_timestamp` - Chronological sorting

### Database Location

- **Default:** `backend/chatbot.db`
- **Custom:** Set `DATABASE_PATH` in `backend/.env`

### Resetting the Database

To start fresh:

```bash
# Delete the database file
rm backend/chatbot.db

# Reinitialize
cd backend
npm run migrate
```

---

## 🔐 Environment Variables

### Backend Environment Variables

Located in `backend/.env`:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `GEMINI_API_KEY` | ✅ Yes | - | Google Gemini API key |
| `PORT` | ❌ No | `3001` | Backend server port |
| `NODE_ENV` | ❌ No | `development` | Environment mode |
| `DATABASE_PATH` | ❌ No | `./chatbot.db` | SQLite database file path |
| `FRONTEND_URL` | ❌ No | `http://localhost:5173` | Frontend URL for CORS |
| `API_KEY` | ❌ No | - | API key for data endpoints |

### Frontend Environment Variables

Located in `frontend/.env`:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `VITE_API_URL` | ❌ No | `http://localhost:3001` | Backend API URL |

### Getting Your Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the API key
5. Add it to `backend/.env`:
   ```env
   GEMINI_API_KEY=your_copied_api_key_here
   ```

### Security Notes

- ✅ Never commit `.env` files (they're in `.gitignore`)
- ✅ Use `.env.example` files as templates
- ✅ Keep API keys secret and secure
- ✅ Use different keys for development and production

---

## 🏗️ Architecture Overview

### System Architecture

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

### Backend Structure (Layered Architecture)

```
backend/
├── src/
│   ├── index.ts              # Entry point, Express server setup
│   ├── db/
│   │   ├── database.ts       # Database connection & initialization
│   │   └── migrate.ts        # Database migration script
│   ├── routes/
│   │   ├── chatRoutes.ts     # Chat endpoints (POST /chat/message, GET /chat/history)
│   │   └── dataRoutes.ts     # Data endpoints (conversations, messages, stats)
│   ├── services/
│   │   ├── conversationService.ts  # Business logic for conversations & messages
│   │   └── llmService.ts           # LLM integration & prompt management
│   └── middleware/
│       └── auth.ts           # API key authentication
```

**Layer Separation:**
1. **Routes Layer** - HTTP request handling, input validation (Zod), error handling
2. **Service Layer** - Business logic, database operations, LLM integration
3. **Data Layer** - Database schema, SQLite connection, migrations

### Frontend Structure

```
frontend/
├── src/
│   ├── routes/
│   │   ├── +page.svelte      # Main page with chat widget
│   │   └── api/              # SvelteKit API routes (proxies to backend)
│   └── lib/
│       ├── api.ts            # API client abstraction
│       └── components/
│           └── ChatWidget.svelte  # Main chat UI component
```

**Key Design Decisions:**

1. **Session-based Conversations**
   - Each conversation has a unique UUID (`sessionId`)
   - Persisted in localStorage for client-side session management
   - Backend creates/retrieves conversations based on `sessionId`
   - Allows conversation resumption on page reload

2. **Conversation History Context**
   - Last 10 messages included in LLM prompt for context
   - Balances context quality with token costs
   - Maintains conversation continuity

3. **Error Resilience**
   - All LLM errors caught and converted to user-friendly messages
   - Application never crashes on API failures
   - Graceful degradation with fallback error messages

4. **Input Validation & Safety**
   - Zod schemas for runtime type validation
   - Message length limits (2000 chars)
   - SQL injection protection via parameterized queries
   - HTML escaping for user messages

5. **SQLite over PostgreSQL**
   - Chosen for simplicity and ease of setup
   - Suitable for demo/small deployments
   - Can be migrated to PostgreSQL for production (schema is compatible)

---

## 🤖 LLM Integration

### Provider: Google Gemini

**Model:** `gemini-2.5-flash`  
**API:** Google Generative AI SDK (`@google/generative-ai`)

### Prompt Design

The LLM is prompted with:

1. **System Context (Domain Knowledge)**
   - Store information: "SpurStore" - a fictional e-commerce store
   - Shipping policy (worldwide, standard/express options, pricing)
   - Return/refund policy (30-day returns, processing times)
   - Support hours (Monday-Friday 9 AM - 6 PM EST, etc.)
   - Product information (general categories)

2. **Conversation History**
   - Last 10 messages formatted as:
     ```
     Customer: [user message]
     Support Agent: [ai response]
     ```

3. **Current User Message**
   - Appended to prompt for context-aware responses

**Example Prompt Structure:**
```
[DOMAIN_KNOWLEDGE with shipping, returns, support hours]

Previous conversation:
Customer: What's your return policy?
Support Agent: We have a 30-day return policy...

Customer: [current user message]
Support Agent:
```

### Guardrails & Error Handling

1. **API Error Handling:**
   - Invalid API key → User-friendly error message
   - Rate limit exceeded → "Please try again in a moment"
   - Timeout → "Request timed out. Please try again."
   - Generic errors → Fallback friendly message

2. **Token Management:**
   - Max message length: 2000 characters (truncated if exceeded)
   - Max tokens per response: 500 (configured in LLM service)
   - Max history messages: 10 (for context)

3. **Out-of-Scope Handling:**
   - LLM instructed to redirect questions outside knowledge base
   - Provides support email and hours for complex queries
   - Never makes up information

### Configuration

All LLM settings in `backend/src/services/llmService.ts`:
- `MAX_MESSAGE_LENGTH = 2000`
- `MAX_TOKENS = 500`
- `MAX_HISTORY_MESSAGES = 10`
- Model: `gemini-2.5-flash`

---

## ✅ Functional Requirements

### 1. Chat UI (Frontend) ✅

- ✅ **Scrollable message list** - Messages container with auto-scroll
- ✅ **Clear distinction** - User messages (right, blue) vs AI messages (left, white)
- ✅ **Input box + send button** - Textarea with send button
- ✅ **Enter key sends** - Enter sends, Shift+Enter for new line
- ✅ **Auto-scroll to latest** - Automatically scrolls to bottom on new messages
- ✅ **Disabled send while loading** - Button disabled during API call
- ✅ **Typing indicator** - "Agent is typing..." animation shown while waiting

**Additional UX Features:**
- Welcome message with suggestion buttons
- Markdown rendering for AI responses
- Error messages displayed clearly
- Message timestamps
- Optimistic UI updates

### 2. Backend API ✅

- ✅ **POST /chat/message** - Accepts `{ message: string, sessionId?: string }`
- ✅ **Returns** `{ reply: string, sessionId: string }`
- ✅ **Message persistence** - All messages (user + AI) saved to database
- ✅ **Session management** - Conversations associated with `sessionId`
- ✅ **LLM integration** - Calls Google Gemini API for replies

**Additional Endpoints:**
- `GET /chat/history/:sessionId` - Retrieve conversation history
- `GET /data/*` - Admin endpoints for conversations, messages, stats
- `GET /health` - Health check endpoint

### 3. LLM Integration ✅

- ✅ **Real LLM API** - Google Gemini API integration
- ✅ **API key via env vars** - `GEMINI_API_KEY` in `.env` (not committed)
- ✅ **Service abstraction** - `LLMService` class wraps LLM calls
- ✅ **System prompt** - Includes domain knowledge (shipping, returns, support hours)
- ✅ **Conversation history** - Last 10 messages included for context
- ✅ **Error handling** - Graceful handling of timeouts, invalid keys, rate limits
- ✅ **Token limits** - Max 500 tokens per response, 2000 chars per message

### 4. FAQ / Domain Knowledge ✅

The AI agent is seeded with knowledge about:

- ✅ **Shipping Policy**
  - Worldwide shipping (standard 5-7 days, express 2-3 days)
  - Pricing: $5.99 standard (free over $50), $12.99 express
  - Supported countries: USA, Canada, UK, Australia, Europe
  - Processing time: 1-2 business days

- ✅ **Return/Refund Policy**
  - 30-day return policy
  - Unused items in original packaging
  - Refund processing: 5-7 business days
  - Return shipping costs (customer responsible unless defective)

- ✅ **Support Hours**
  - Monday-Friday: 9 AM - 6 PM EST
  - Saturday: 10 AM - 4 PM EST
  - Sunday: Closed
  - Email: support@spurstore.com
  - Response time: Within 24 hours

**Implementation:** Hardcoded in `DOMAIN_KNOWLEDGE` constant in `llmService.ts` (can be moved to DB if needed)

### 5. Data Model & Persistence ✅

- ✅ **Conversations table** - `id`, `createdAt`, `updatedAt`
- ✅ **Messages table** - `id`, `conversationId`, `sender` ('user' | 'ai'), `text`, `timestamp`
- ✅ **Session resumption** - Given `sessionId`, fetches and displays past messages
- ✅ **No auth required** - Simple session-based conversations

**Database:**
- SQLite for simplicity
- Foreign key constraints
- Indexes for performance
- CASCADE delete for data integrity

### 6. Robustness & Error Handling ✅

- ✅ **Input validation**
  - Empty messages rejected (Zod validation)
  - Long messages truncated to 2000 chars
  - UUID validation for `sessionId`

- ✅ **Error handling**
  - Backend never crashes on bad input (try-catch everywhere)
  - LLM/API failures caught and surfaced as clean error messages
  - User-friendly error messages in UI

- ✅ **No hardcoded secrets**
  - All API keys via environment variables
  - `.env.example` files provided
  - `.env` files in `.gitignore`

- ✅ **Graceful failure**
  - All errors logged to console
  - User-facing error messages
  - Application continues running after errors

---

## 🔄 Trade-offs & Future Improvements

### Trade-offs Made

1. **SQLite vs PostgreSQL**
   - **Chosen:** SQLite for simplicity
   - **Trade-off:** Less suitable for high-concurrency production, but perfect for demo
   - **Migration path:** Schema is simple and can be easily migrated to PostgreSQL

2. **Hardcoded FAQ vs Database**
   - **Chosen:** Hardcoded in prompt for simplicity
   - **Trade-off:** Less flexible, but easier to maintain for this scope
   - **Future:** Could move to database with admin UI for updates

3. **Synchronous vs Streaming Responses**
   - **Chosen:** Synchronous (wait for full response)
   - **Trade-off:** Slightly slower perceived performance, but simpler implementation
   - **Future:** Could add streaming for better UX

4. **No Authentication**
   - **Chosen:** Session-based conversations without user auth
   - **Trade-off:** Simpler, but no user accounts or multi-device sync
   - **Future:** Could add OAuth/JWT for user accounts

5. **Simple Rate Limiting**
   - **Chosen:** Basic IP-based rate limiting (100 req/15min)
   - **Trade-off:** Works for demo, but not sophisticated enough for production abuse prevention
   - **Future:** Could add per-user rate limiting, CAPTCHA, etc.

### If I Had More Time...

1. **Testing**
   - Unit tests for services (conversationService, llmService)
   - Integration tests for API endpoints
   - E2E tests for chat flow
   - Test coverage for error scenarios

2. **Performance**
   - Redis caching for frequently accessed conversations
   - Database connection pooling
   - Response streaming for LLM replies
   - Optimistic UI updates (already done, but could be enhanced)

3. **Features**
   - Message search within conversations
   - Export conversation history
   - Admin dashboard for viewing all conversations
   - Analytics (response times, common questions, etc.)
   - Multi-language support
   - File upload support

4. **Production Readiness**
   - PostgreSQL migration
   - Comprehensive logging (Winston/Pino)
   - Monitoring & alerting (Sentry, DataDog)
   - CI/CD pipeline
   - Docker optimization (multi-stage builds)
   - Health checks with dependency checks

5. **UX Enhancements**
   - Message reactions/feedback
   - Typing indicators with estimated time
   - Rich media support (images, links)
   - Conversation search
   - Dark mode

6. **Architecture**
   - WebSocket support for real-time updates
   - Message queue for async LLM processing
   - Microservices split (chat service, LLM service, data service)
   - GraphQL API option

---

## 📚 Additional Documentation

- **[SETUP.md](SETUP.md)** - Detailed setup instructions
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Docker and cloud deployment guide
- **[DOCKER.md](DOCKER.md)** - Single Dockerfile deployment
- **[API.md](API.md)** - Complete API endpoints reference
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design decisions

---

## 🛠️ Tech Stack

- **Backend:** Node.js 18+, TypeScript, Express.js, SQLite (better-sqlite3), Google Gemini API
- **Frontend:** SvelteKit, TypeScript, Vite, Marked (markdown rendering)
- **Validation:** Zod
- **Database:** SQLite (can migrate to PostgreSQL)

---

## 📄 License

MIT License - see LICENSE file for details

---

## 🎯 Assignment Requirements Checklist

✅ **Chat UI** - Scrollable, user/AI distinction, input box, send button, Enter key, auto-scroll, disabled send, typing indicator  
✅ **Backend API** - POST /chat/message, persistence, session management, LLM integration  
✅ **LLM Integration** - Real API (Gemini), env vars, error handling, guardrails  
✅ **FAQ Knowledge** - Shipping, returns, support hours  
✅ **Data Model** - Conversations, messages, sessionId support  
✅ **Robustness** - Input validation, error handling, no hardcoded secrets  
✅ **Documentation** - README with setup, architecture, LLM notes, trade-offs
