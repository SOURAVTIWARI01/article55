-- Society Voting System Database Schema
-- This file contains the complete database schema for the voting system

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  block_number TEXT NOT NULL,
  flat_number TEXT NOT NULL,
  phone TEXT UNIQUE NOT NULL,
  email TEXT,
  has_voted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_flat ON users(flat_number);

-- ============================================
-- CANDIDATES TABLE
-- ============================================
CREATE TABLE candidates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  full_name TEXT NOT NULL,
  summary TEXT CHECK (length(summary) <= 300),
  photo_url TEXT,
  category TEXT CHECK (category IN ('President', 'Secretary', 'Treasurer')),
  is_approved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Index for filtering by category and approval status
CREATE INDEX idx_candidates_category ON candidates(category);
CREATE INDEX idx_candidates_approved ON candidates(is_approved);

-- ============================================
-- VOTES TABLE
-- ============================================
CREATE TABLE votes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  candidate_id UUID REFERENCES candidates(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, category)
);

-- Index for vote counting
CREATE INDEX idx_votes_candidate ON votes(candidate_id);
CREATE INDEX idx_votes_category ON votes(category);

-- ============================================
-- TRIGGER: Enforce One Vote Per Flat
-- ============================================
CREATE OR REPLACE FUNCTION check_flat_vote()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM votes v
    JOIN users u1 ON v.user_id = u1.id
    JOIN users u2 ON NEW.user_id = u2.id
    WHERE u1.flat_number = u2.flat_number
    AND v.category = NEW.category
    AND v.user_id != NEW.user_id
  ) THEN
    RAISE EXCEPTION 'This flat has already voted for %', NEW.category;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_one_vote_per_flat
BEFORE INSERT ON votes
FOR EACH ROW EXECUTE FUNCTION check_flat_vote();
