-- ============================================================
-- Article 55 – Fair Electoral System
-- Database Schema for Supabase (PostgreSQL)
-- ============================================================

-- Users table: stores resident information and roles
CREATE TABLE IF NOT EXISTS users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    block_number TEXT NOT NULL,
    flat_number TEXT NOT NULL,
    phone       TEXT NOT NULL,
    email       TEXT,
    role        TEXT NOT NULL DEFAULT 'user'
                  CHECK (role IN ('user', 'admin')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Unique constraints
ALTER TABLE users ADD CONSTRAINT uq_users_phone UNIQUE (phone);
ALTER TABLE users ADD CONSTRAINT uq_users_flat  UNIQUE (flat_number);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role);

-- ============================================================
-- Future tables (Phase 2+)
-- ============================================================

-- Candidates table (placeholder)
-- CREATE TABLE candidates (
--     id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     name        TEXT NOT NULL,
--     photo_url   TEXT,
--     position    TEXT NOT NULL,
--     manifesto   TEXT,
--     created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );

-- Votes table (placeholder)
-- CREATE TABLE votes (
--     id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     user_id      UUID REFERENCES users(id) NOT NULL,
--     candidate_id UUID REFERENCES candidates(id) NOT NULL,
--     voted_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     UNIQUE(user_id)  -- One vote per user
-- );

-- Flats voted tracking (placeholder)
-- CREATE TABLE flats_voted (
--     flat_number TEXT PRIMARY KEY REFERENCES users(flat_number),
--     voted_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );

-- ============================================================
-- Row Level Security (to enable when ready)
-- ============================================================
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can read own data" ON users
--   FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Admins can read all" ON users
--   FOR SELECT USING (
--     EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
--   );

-- ============================================================
-- Seed data for development
-- ============================================================
INSERT INTO users (name, block_number, flat_number, phone, email, role)
VALUES
    ('Arpit', 'A', '101', '9335946391', 'arpit@example.com', 'user'),
    ('Admin', 'A', '001', '8947043315', 'admin@article55.app', 'admin')
ON CONFLICT (phone) DO NOTHING;
