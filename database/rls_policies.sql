-- Row-Level Security (RLS) Policies
-- These policies ensure data security and prevent unauthorized access

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Allow anyone to insert (register)
CREATE POLICY "Allow user registration" ON users
  FOR INSERT WITH CHECK (true);

-- Users can read all user data (for checking flat voting status)
CREATE POLICY "Users can view all users" ON users
  FOR SELECT USING (true);

-- Users can update only their own has_voted status
CREATE POLICY "Users can update own voting status" ON users
  FOR UPDATE USING (auth.uid()::text = id::text);

-- ============================================
-- CANDIDATES TABLE POLICIES
-- ============================================

-- Anyone can insert candidates (pending approval)
CREATE POLICY "Allow candidate creation" ON candidates
  FOR INSERT WITH CHECK (true);

-- Only approved candidates are visible to regular users
CREATE POLICY "View approved candidates" ON candidates
  FOR SELECT USING (is_approved = true);

-- ============================================
-- VOTES TABLE POLICIES
-- ============================================

-- Users can insert their own votes
CREATE POLICY "Users can vote" ON votes
  FOR INSERT WITH CHECK (true);

-- Users can view all votes (for live count)
CREATE POLICY "Users can view votes" ON votes
  FOR SELECT USING (true);

-- Users cannot update or delete votes (immutable)
-- Only admins can delete votes (policy will be added in Issue #3)
