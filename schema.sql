-- Ejecuta este archivo una sola vez en la consola de tu base de datos D1.
CREATE TABLE IF NOT EXISTS community_members (
  discord_user_id TEXT PRIMARY KEY,
  username TEXT NOT NULL,
  global_name TEXT,
  nickname TEXT,
  avatar_url TEXT,
  first_seen_at INTEGER NOT NULL,
  last_login_at INTEGER NOT NULL,
  last_seen_web_at INTEGER
);

CREATE TABLE IF NOT EXISTS web_sessions (
  session_id TEXT PRIMARY KEY,
  discord_user_id TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  FOREIGN KEY (discord_user_id) REFERENCES community_members(discord_user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_web_sessions_expiry ON web_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_web_sessions_user ON web_sessions(discord_user_id);
CREATE INDEX IF NOT EXISTS idx_members_last_login ON community_members(last_login_at);
