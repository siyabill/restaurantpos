-- ==============================================================================
-- Siya Bill: Complete Supabase Schema & Permissions Fix
-- Project: yatzsfzzjoxyhbjrvjms
-- ==============================================================================

-- 1. Fix licenses table: Add missing columns and remove NOT NULL constraint on plan
ALTER TABLE public.licenses ADD COLUMN IF NOT EXISTS plan_type TEXT;
ALTER TABLE public.licenses ADD COLUMN IF NOT EXISTS expiry_days INTEGER;
ALTER TABLE public.licenses ADD COLUMN IF NOT EXISTS created_by UUID;
ALTER TABLE public.licenses ADD COLUMN IF NOT EXISTS restaurant_code TEXT;

-- Drop NOT NULL on plan so it never fails key generation
ALTER TABLE public.licenses ALTER COLUMN plan DROP NOT NULL;

-- Fix licenses RLS policies so Admin Portal and Apps can insert & read licenses
ALTER TABLE public.licenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Super Admin manage licenses" ON public.licenses;
DROP POLICY IF EXISTS "Super Admin manage all licenses" ON public.licenses;
DROP POLICY IF EXISTS "Allow all for licenses" ON public.licenses;
DROP POLICY IF EXISTS "Allow all access to licenses" ON public.licenses;
DROP POLICY IF EXISTS "Allow authenticated claim license" ON public.licenses;
DROP POLICY IF EXISTS "Allow authenticated update claim license" ON public.licenses;

CREATE POLICY "Allow all access to licenses" ON public.licenses
    FOR ALL
    USING (true)
    WITH CHECK (true);

GRANT ALL ON public.licenses TO authenticated, anon, service_role;

-- 2. Fix support_tickets table (add missing columns)
CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_user_id TEXT,
    subject TEXT,
    message TEXT,
    reply TEXT,
    status TEXT DEFAULT 'open',
    priority TEXT DEFAULT 'normal',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.support_tickets ADD COLUMN IF NOT EXISTS message TEXT;
ALTER TABLE public.support_tickets ADD COLUMN IF NOT EXISTS reply TEXT;
ALTER TABLE public.support_tickets ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for support_tickets" ON public.support_tickets;
CREATE POLICY "Allow all for support_tickets" ON public.support_tickets
    FOR ALL USING (true) WITH CHECK (true);

GRANT ALL ON public.support_tickets TO authenticated, anon, service_role;

-- 3. Create presence_pings table (for live active restaurants counter)
CREATE TABLE IF NOT EXISTS public.presence_pings (
    app_user_id TEXT PRIMARY KEY,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.presence_pings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow all for presence_pings" ON public.presence_pings;
CREATE POLICY "Allow all for presence_pings" ON public.presence_pings
    FOR ALL USING (true) WITH CHECK (true);

GRANT ALL ON public.presence_pings TO authenticated, anon, service_role;

-- 4. Create user_rate_violations table (for blocked users monitoring)
CREATE TABLE IF NOT EXISTS public.user_rate_violations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    app_user_id UUID,
    violation_type TEXT,
    details JSONB,
    blocked_at TIMESTAMPTZ DEFAULT NOW(),
    blocked_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_rate_violations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Super Admin can view violations" ON public.user_rate_violations;
CREATE POLICY "Super Admin can view violations" ON public.user_rate_violations
    FOR ALL USING (true);

GRANT ALL ON public.user_rate_violations TO authenticated, anon, service_role;

-- 5. Super Admin RLS Policies: Allow viewing all restaurants, settings, and bills
DROP POLICY IF EXISTS "Super Admin view all restaurant_profile" ON public.restaurant_profile;
CREATE POLICY "Super Admin view all restaurant_profile" ON public.restaurant_profile
    FOR ALL
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Super Admin view all restaurant_settings" ON public.restaurant_settings;
CREATE POLICY "Super Admin view all restaurant_settings" ON public.restaurant_settings
    FOR ALL
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Super Admin view all bills" ON public.bills;
CREATE POLICY "Super Admin view all bills" ON public.bills
    FOR ALL
    USING (true)
    WITH CHECK (true);

-- 6. Dine-In Table Ordering & Public Self-Orders Setup
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

ALTER TABLE public.self_orders ENABLE ROW LEVEL SECURITY;
GRANT ALL ON public.self_orders TO authenticated;
GRANT INSERT, SELECT ON public.self_orders TO anon, authenticated, public;

DROP POLICY IF EXISTS "Allow public insert on self_orders" ON public.self_orders;
CREATE POLICY "Allow public insert on self_orders"
    ON public.self_orders
    FOR INSERT
    TO anon, authenticated, public
    WITH CHECK (status = 'pending');

DROP POLICY IF EXISTS "Allow public select on self_orders" ON public.self_orders;
CREATE POLICY "Allow public select on self_orders"
    ON public.self_orders
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

DROP POLICY IF EXISTS "Owner full access on self_orders" ON public.self_orders;
CREATE POLICY "Owner full access on self_orders"
    ON public.self_orders
    FOR ALL
    TO authenticated
    USING (auth.uid()::text = app_user_id::text)
    WITH CHECK (auth.uid()::text = app_user_id::text);

-- Public Read Policies for Digital QR Menu Loading
ALTER TABLE public.restaurant_profile ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view restaurant profile by code" ON public.restaurant_profile;
CREATE POLICY "Public can view restaurant profile by code"
    ON public.restaurant_profile
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

ALTER TABLE public.restaurant_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public select on restaurant_settings" ON public.restaurant_settings;
CREATE POLICY "Allow public select on restaurant_settings"
    ON public.restaurant_settings
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view active menu items" ON public.menu_items;
CREATE POLICY "Public can view active menu items"
    ON public.menu_items
    FOR SELECT
    TO anon, authenticated, public
    USING (is_active = true);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view categories" ON public.categories;
CREATE POLICY "Public can view categories"
    ON public.categories
    FOR SELECT
    TO anon, authenticated, public
    USING (true);

-- verify_table_pin function
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
    SELECT app_user_id::text INTO v_user_id
    FROM public.restaurant_profile
    WHERE restaurant_code = p_restaurant_code
    LIMIT 1;

    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

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

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';

SELECT 'All licenses, tickets, profiles, dine-in tables, and admin tables configured successfully!' AS status;

