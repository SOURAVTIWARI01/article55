-- ============================================================
-- Article 55 – Phase 2: Candidates & Voting
-- ============================================================

-- ─── Category Enum ──────────────────────────────────────────
DO $$ BEGIN
  CREATE TYPE candidate_category AS ENUM ('president', 'secretary', 'treasurer');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  CREATE TYPE vote_type AS ENUM ('single', 'upvote', 'downvote');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ─── Candidates Table ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.candidates (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name   TEXT NOT NULL CHECK (length(trim(full_name)) > 0),
    summary     TEXT DEFAULT '',
    photo_url   TEXT,
    category    candidate_category NOT NULL,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    created_by  UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_candidates_category ON public.candidates(category);
CREATE INDEX IF NOT EXISTS idx_candidates_approved ON public.candidates(is_approved);

-- ─── Votes Table ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.votes (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    flat_number  TEXT NOT NULL,
    category     candidate_category NOT NULL,
    candidate_id UUID NOT NULL REFERENCES public.candidates(id) ON DELETE CASCADE,
    vote_type    vote_type NOT NULL DEFAULT 'single',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One vote per flat per category (critical integrity constraint)
ALTER TABLE public.votes
  ADD CONSTRAINT uq_votes_flat_category UNIQUE (flat_number, category);

CREATE INDEX IF NOT EXISTS idx_votes_candidate ON public.votes(candidate_id);
CREATE INDEX IF NOT EXISTS idx_votes_category  ON public.votes(category);
CREATE INDEX IF NOT EXISTS idx_votes_user      ON public.votes(user_id);

-- ─── RLS: Candidates ────────────────────────────────────────
ALTER TABLE public.candidates ENABLE ROW LEVEL SECURITY;

-- Users see only approved candidates
DROP POLICY IF EXISTS "Users read approved candidates" ON public.candidates;
CREATE POLICY "Users read approved candidates"
  ON public.candidates FOR SELECT
  TO anon, authenticated
  USING (is_approved = TRUE);

-- Admin sees all candidates
DROP POLICY IF EXISTS "Admin reads all candidates" ON public.candidates;
CREATE POLICY "Admin reads all candidates"
  ON public.candidates FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- Users can insert their own candidature
DROP POLICY IF EXISTS "Users insert own candidature" ON public.candidates;
CREATE POLICY "Users insert own candidature"
  ON public.candidates FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

-- Only admin can update (approve/reject)
DROP POLICY IF EXISTS "Admin updates candidates" ON public.candidates;
CREATE POLICY "Admin updates candidates"
  ON public.candidates FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- Only admin can delete
DROP POLICY IF EXISTS "Admin deletes candidates" ON public.candidates;
CREATE POLICY "Admin deletes candidates"
  ON public.candidates FOR DELETE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- ─── RLS: Votes ─────────────────────────────────────────────
ALTER TABLE public.votes ENABLE ROW LEVEL SECURITY;

-- Users can insert their own vote
DROP POLICY IF EXISTS "Users insert own vote" ON public.votes;
CREATE POLICY "Users insert own vote"
  ON public.votes FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can only see their own votes (not who others voted for)
DROP POLICY IF EXISTS "Users read own votes" ON public.votes;
CREATE POLICY "Users read own votes"
  ON public.votes FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Admin can see all votes
DROP POLICY IF EXISTS "Admin reads all votes" ON public.votes;
CREATE POLICY "Admin reads all votes"
  ON public.votes FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- No one can update votes (immutable once cast)
-- No UPDATE policy = no updates allowed

-- Only admin can delete suspicious votes
DROP POLICY IF EXISTS "Admin deletes votes" ON public.votes;
CREATE POLICY "Admin deletes votes"
  ON public.votes FOR DELETE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- ─── Atomic Vote RPC ────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.cast_vote(
  p_user_id      UUID,
  p_flat_number  TEXT,
  p_category     candidate_category,
  p_candidate_id UUID,
  p_vote_type    vote_type DEFAULT 'single'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_vote_id UUID;
BEGIN
  -- Verify candidate is approved
  IF NOT EXISTS (
    SELECT 1 FROM public.candidates
    WHERE id = p_candidate_id AND category = p_category AND is_approved = TRUE
  ) THEN
    RAISE EXCEPTION 'Candidate not found or not approved for this category';
  END IF;

  -- Verify user owns this flat
  IF NOT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = p_user_id AND flat_number = p_flat_number
  ) THEN
    RAISE EXCEPTION 'User flat number mismatch';
  END IF;

  -- Insert vote (unique constraint will block duplicates)
  INSERT INTO public.votes (user_id, flat_number, category, candidate_id, vote_type)
  VALUES (p_user_id, p_flat_number, p_category, p_candidate_id, p_vote_type)
  RETURNING id INTO v_vote_id;

  RETURN v_vote_id;
END;
$$;

-- ─── Vote Count View (no voter identity exposed) ────────────
CREATE OR REPLACE VIEW public.vote_counts AS
SELECT
  v.category,
  v.candidate_id,
  c.full_name AS candidate_name,
  COUNT(*) AS total_votes
FROM public.votes v
JOIN public.candidates c ON c.id = v.candidate_id
GROUP BY v.category, v.candidate_id, c.full_name;

-- ─── Seed Candidates ────────────────────────────────────────
INSERT INTO public.candidates (full_name, summary, category, is_approved, created_by)
VALUES
  ('Rajesh Sharma', 'Experienced community leader with 10 years of service. Focused on infrastructure and amenities improvement.', 'president', TRUE, NULL),
  ('Priya Mehta', 'Advocate for transparency and digital governance. Aims to modernize society operations.', 'president', TRUE, NULL),
  ('Amit Patel', 'Financial expert committed to reducing maintenance costs and improving fund allocation.', 'treasurer', TRUE, NULL),
  ('Sneha Gupta', 'Chartered accountant with a plan for transparent financial reporting.', 'treasurer', TRUE, NULL),
  ('Vikram Singh', 'Organized and detail-oriented. Plans to digitize all society records.', 'secretary', TRUE, NULL),
  ('Neha Kapoor', 'Communication specialist focused on better resident engagement.', 'secretary', TRUE, NULL)
ON CONFLICT DO NOTHING;
