import Database, { type Database as DatabaseType } from 'better-sqlite3';
import path from 'path';
import { fileURLToPath } from 'url';
import { existsSync, mkdirSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Get database path from environment or use default
const dbPath = process.env.DATABASE_PATH || path.join(__dirname, '../../chatbot.db');

// Ensure the directory exists for the database file
const dbDir = path.dirname(dbPath);
if (!existsSync(dbDir)) {
  mkdirSync(dbDir, { recursive: true });
}

// Create database connection with error handling
let db: DatabaseType;
try {
  db = new Database(dbPath);
  // Test write access
  db.pragma('journal_mode = WAL'); // Enable WAL mode for better concurrency
} catch (error: any) {
  console.error('Failed to initialize database:', error.message);
  console.error('Database path:', dbPath);
  throw new Error(`Database initialization failed: ${error.message}`);
}

// Enable foreign keys
db.pragma('foreign_keys = ON');

export interface Conversation {
  id: string;
  createdAt: string;
  updatedAt: string;
}

export interface Message {
  id: string;
  conversationId: string;
  sender: 'user' | 'ai';
  text: string;
  timestamp: string;
}

export function initDatabase() {
  // Create conversations table
  db.exec(`
    CREATE TABLE IF NOT EXISTS conversations (
      id TEXT PRIMARY KEY,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
  `);

  // Create messages table
  db.exec(`
    CREATE TABLE IF NOT EXISTS messages (
      id TEXT PRIMARY KEY,
      conversationId TEXT NOT NULL,
      sender TEXT NOT NULL CHECK(sender IN ('user', 'ai')),
      text TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (conversationId) REFERENCES conversations(id) ON DELETE CASCADE
    )
  `);

  // Create indexes for better query performance
  db.exec(`
    CREATE INDEX IF NOT EXISTS idx_messages_conversationId ON messages(conversationId);
    CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp);
  `);
}

export const dbInstance: DatabaseType = db;

