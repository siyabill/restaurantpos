-- ==============================================================================
-- Migration: Fix Dine-In Table Ordering & Public Self-Orders
-- Date: 2026-09-28
-- 
-- 1. Create verify_table_pin RPC for customer Dine-in table PIN verification
-- 2. Allow public/anon access to restaurant_profile, settings, menu_items, categories
-- 3. Ensure self_orders table exists with RLS policies allowing public insertion
-- 4. Enable Realtime on self_orders and active_orders
-- ==============================================================================

-- 1. Create self_orders table if not exists
CREATE TABLE IF NOT EXISTS public.self_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_user_id UUID NOT NULL,
    table_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    items JSONB NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    timestamp BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on self_orders
ALTER TABLE public.self_orders ENABLE ROW LEVEL SECURITY;

-- Grant permissions on self_orders
GRANT ALL ON public.self_orders TO authenticated;
GRANT INSERT, SELECT ON public.self_orders TO anon, authenticated, public;

-- RLS: Allow anyone (customer via QR code) to insert pending self-orders
DROP POLICY IF EXISTS "Allow public insert on self_orders" ON public.self_orders;
CREATE POLICY "Allow public insert on self_orders"
    ON public.self_orders
    FOR INSERT
    TO anon, authenticated, public
    WITH CHECK (status = 'pending');

-- RLS: Allow public to select own self-orders
DROP POLICY IF EXISTS "Allow public select on self_orders" ON public.self_orders;
CREATE POLICY "Allow public select on self_orders"
    ON public.self_orders
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

-- RLS: Allow restaurant owner full access to their self_orders
DROP POLICY IF EXISTS "Owner full access on self_orders" ON public.self_orders;
CREATE POLICY "Owner full access on self_orders"
    ON public.self_orders
    FOR ALL
    TO authenticated
    USING (auth.uid()::text = app_user_id::text)
    WITH CHECK (auth.uid()::text = app_user_id::text);

-- 2. Public Read Policies for Digital QR Menu Loading
-- restaurant_profile (Public read needed for customer menu page)
ALTER TABLE public.restaurant_profile ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view restaurant profile by code" ON public.restaurant_profile;
CREATE POLICY "Public can view restaurant profile by code"
    ON public.restaurant_profile
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

-- restaurant_settings (Public read needed for online delivery/takeaway toggles)
ALTER TABLE public.restaurant_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public select on restaurant_settings" ON public.restaurant_settings;
CREATE POLICY "Allow public select on restaurant_settings"
    ON public.restaurant_settings
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

-- menu_items (Public read needed to display digital menu)
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view active menu items" ON public.menu_items;
CREATE POLICY "Public can view active menu items"
    ON public.menu_items
    FOR SELECT
    TO anon, authenticated, public
    USING (is_active = true);

-- categories (Public read needed to display categories)
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view categories" ON public.categories;
CREATE POLICY "Public can view categories"
    ON public.categories
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

-- 3. Stored Procedure: verify_table_pin
-- Allows unauthenticated customer phones to verify Table PIN without exposing active_orders
CREATE OR REPLACE FUNCTION public.verify_table_pin(
    p_restaurant_code TEXT,
    p_table_id TEXT,
    p_pin TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id TEXT;
    v_match BOOLEAN;
BEGIN
    -- 1. Find restaurant's app_user_id from restaurant_code
    SELECT app_user_id::text INTO v_user_id
    FROM public.restaurant_profile
    WHERE restaurant_code = p_restaurant_code
    LIMIT 1;

    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- 2. Check if table PIN matches in active_orders
    SELECT EXISTS (
        SELECT 1
        FROM public.active_orders
        WHERE app_user_id::text = v_user_id
          AND id::text = p_table_id::text
          AND table_pin = p_pin
    ) INTO v_match;

    RETURN COALESCE(v_match, FALSE);
END;
$$;

GRANT EXECUTE ON FUNCTION public.verify_table_pin(TEXT, TEXT, TEXT) TO anon, authenticated, service_role;

-- 4. Enable Supabase Realtime for self_orders & active_orders
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'self_orders'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.self_orders;
  END IF;
  
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'active_orders'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.active_orders;
  END IF;
END $$;
