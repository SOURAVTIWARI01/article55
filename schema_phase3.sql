-- ============================================================
-- Article 55 – Phase 3: Admin Layer & Security Hardening
-- ============================================================

-- ─── Blocked Flats Table ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.blocked_flats (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flat_number TEXT NOT NULL UNIQUE,
    reason      TEXT NOT NULL DEFAULT 'Suspicious activity',
    blocked_by  UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blocked_flats_flat ON public.blocked_flats(flat_number);

-- ─── RLS: Blocked Flats (admin-only) ────────────────────────
ALTER TABLE public.blocked_flats ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin manages blocked flats" ON public.blocked_flats;
CREATE POLICY "Admin manages blocked flats"
  ON public.blocked_flats FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin')
  );

-- ─── Updated cast_vote RPC (checks blocked flats) ──────────
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
  -- Check if flat is blocked
  IF EXISTS (
    SELECT 1 FROM public.blocked_flats WHERE flat_number = p_flat_number
  ) THEN
    RAISE EXCEPTION 'This flat has been blocked from voting. Contact admin.';
  END IF;

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

-- ─── Admin Stats RPC ────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_admin_stats()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_users', (SELECT COUNT(*) FROM public.users WHERE role = 'user'),
    'total_candidates', (SELECT COUNT(*) FROM public.candidates WHERE is_approved = TRUE),
    'total_votes', (SELECT COUNT(*) FROM public.votes),
    'president_votes', (SELECT COUNT(*) FROM public.votes WHERE category = 'president'),
    'secretary_votes', (SELECT COUNT(*) FROM public.votes WHERE category = 'secretary'),
    'treasurer_votes', (SELECT COUNT(*) FROM public.votes WHERE category = 'treasurer'),
    'blocked_flats', (SELECT COUNT(*) FROM public.blocked_flats),
    'pending_candidates', (SELECT COUNT(*) FROM public.candidates WHERE is_approved = FALSE)
  ) INTO result;
  RETURN result;
END;
$$;

-- ─── Admin Get All Votes (with names) ───────────────────────
CREATE OR REPLACE FUNCTION public.get_all_votes()
RETURNS TABLE (
  vote_id UUID,
  user_name TEXT,
  flat_number TEXT,
  category candidate_category,
  candidate_name TEXT,
  vote_type vote_type,
  voted_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    v.id AS vote_id,
    u.name AS user_name,
    v.flat_number,
    v.category,
    c.full_name AS candidate_name,
    v.vote_type,
    v.created_at AS voted_at
  FROM public.votes v
  JOIN public.users u ON u.id = v.user_id
  JOIN public.candidates c ON c.id = v.candidate_id
  ORDER BY v.created_at DESC;
END;
$$;

-- ─── Safe Vote Deletion RPC ─────────────────────────────────
CREATE OR REPLACE FUNCTION public.delete_vote(p_vote_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verify caller is admin
  IF NOT EXISTS (
    SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Unauthorized: admin access required';
  END IF;

  DELETE FROM public.votes WHERE id = p_vote_id;
END;
$$;
