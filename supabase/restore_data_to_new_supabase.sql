-- ==============================================================================
-- Migration & Data Restore from Old Supabase (lecqxvnznxceonmuqatv)
-- To New Supabase (yatzsfzzjoxyhbjrvjms)
-- ==============================================================================

-- 1. Ensure required admin tables exist
CREATE TABLE IF NOT EXISTS public.presence_pings (
    app_user_id TEXT PRIMARY KEY,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.presence_pings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can ping presence" ON public.presence_pings;
CREATE POLICY "Public can ping presence" ON public.presence_pings
    FOR ALL USING (true) WITH CHECK (true);

GRANT ALL ON public.presence_pings TO authenticated, anon, service_role;

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
    FOR ALL USING (auth.jwt() ->> 'email' = 'gudduk483@gmail.com');

GRANT ALL ON public.user_rate_violations TO authenticated, anon, service_role;

-- 2. Super Admin RLS Policies for restaurant_profile and restaurant_settings
-- Allow Super Admin (gudduk483@gmail.com) to view and manage ALL restaurants in Admin Panel
DROP POLICY IF EXISTS "Super Admin manage restaurant_profile" ON public.restaurant_profile;
CREATE POLICY "Super Admin manage restaurant_profile" ON public.restaurant_profile
    FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'email' = 'gudduk483@gmail.com' OR auth.uid()::text = app_user_id::text)
    WITH CHECK (auth.jwt() ->> 'email' = 'gudduk483@gmail.com' OR auth.uid()::text = app_user_id::text);

DROP POLICY IF EXISTS "Super Admin manage restaurant_settings" ON public.restaurant_settings;
CREATE POLICY "Super Admin manage restaurant_settings" ON public.restaurant_settings
    FOR ALL
    TO authenticated
    USING (auth.jwt() ->> 'email' = 'gudduk483@gmail.com' OR auth.uid()::text = app_user_id::text)
    WITH CHECK (auth.jwt() ->> 'email' = 'gudduk483@gmail.com' OR auth.uid()::text = app_user_id::text);

-- 3. Restore Data from Old Supabase Project

-- restaurant_profile (5 rows)
INSERT INTO public.restaurant_profile ("app_user_id", "id", "restaurant_name", "phone", "email", "address", "gst_number", "fssai_number", "restaurant_code", "upi_id", "upi_enabled", "thank_you_message", "gst_percentage", "subscription_status", "subscription_plan", "subscription_expiry", "license_key", "activation_date", "referred_by_reward_granted", "updated_at", "referred_by", "referral_claimed")
VALUES ('74cb3082-864f-4639-ba12-19d9e0438401', 'global', 'test2', '7564876666', NULL, NULL, '', '', 'RES-ACC5FF', NULL, FALSE, NULL, 0, 'trial', 'suspended', 1782798396424, 'RESPOS-Y01-1812541809776-93EFB3BB5F8CB06A8467D5886436D6AE27F2149475A6EFCA9E51E0A6B70EFBD5C79650F8A6F95807BFE4C40F410A8E0B77E9F0F6C17E715647F86FA0CA929776', 1781005827962, TRUE, '2026-06-23T05:46:36.424+00:00', 'RES-WCHE7D', TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "restaurant_name" = EXCLUDED."restaurant_name", "phone" = EXCLUDED."phone", "email" = EXCLUDED."email", "address" = EXCLUDED."address", "gst_number" = EXCLUDED."gst_number", "fssai_number" = EXCLUDED."fssai_number", "restaurant_code" = EXCLUDED."restaurant_code", "upi_id" = EXCLUDED."upi_id", "upi_enabled" = EXCLUDED."upi_enabled", "thank_you_message" = EXCLUDED."thank_you_message", "gst_percentage" = EXCLUDED."gst_percentage", "subscription_status" = EXCLUDED."subscription_status", "subscription_plan" = EXCLUDED."subscription_plan", "subscription_expiry" = EXCLUDED."subscription_expiry", "license_key" = EXCLUDED."license_key", "activation_date" = EXCLUDED."activation_date", "referred_by_reward_granted" = EXCLUDED."referred_by_reward_granted", "updated_at" = EXCLUDED."updated_at", "referred_by" = EXCLUDED."referred_by", "referral_claimed" = EXCLUDED."referral_claimed";

INSERT INTO public.restaurant_profile ("app_user_id", "id", "restaurant_name", "phone", "email", "address", "gst_number", "fssai_number", "restaurant_code", "upi_id", "upi_enabled", "thank_you_message", "gst_percentage", "subscription_status", "subscription_plan", "subscription_expiry", "license_key", "activation_date", "referred_by_reward_granted", "updated_at", "referred_by", "referral_claimed")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'global', 'Khana Khazana Family Restaurant', '9709954676', 'khanakhazanasinghwara@gmail.com', 'Main Road Singhwara', '10IGJPK1984A1ZO', '20424311000121', 'RES-BP20VY', 'khanakhazanafamilyrestaurant@cnrb', TRUE, 'Thank You for Visiting! Please Visit Again', 0, 'premium', 'lifetime', 10421527447516, 'RESPOS-LIF-10421527447516-F7BB8C8E4CE43D30D25ED2733922113CB08BAC89DA17C680C4606AAA71F5363E5D9DBEF2D59D7F938B7E7935E3231E976C5276DE7045C26CEA1FBFEF60B1D64C', 1781613863968, FALSE, '2026-06-23T12:30:48.8+00:00', NULL, FALSE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "restaurant_name" = EXCLUDED."restaurant_name", "phone" = EXCLUDED."phone", "email" = EXCLUDED."email", "address" = EXCLUDED."address", "gst_number" = EXCLUDED."gst_number", "fssai_number" = EXCLUDED."fssai_number", "restaurant_code" = EXCLUDED."restaurant_code", "upi_id" = EXCLUDED."upi_id", "upi_enabled" = EXCLUDED."upi_enabled", "thank_you_message" = EXCLUDED."thank_you_message", "gst_percentage" = EXCLUDED."gst_percentage", "subscription_status" = EXCLUDED."subscription_status", "subscription_plan" = EXCLUDED."subscription_plan", "subscription_expiry" = EXCLUDED."subscription_expiry", "license_key" = EXCLUDED."license_key", "activation_date" = EXCLUDED."activation_date", "referred_by_reward_granted" = EXCLUDED."referred_by_reward_granted", "updated_at" = EXCLUDED."updated_at", "referred_by" = EXCLUDED."referred_by", "referral_claimed" = EXCLUDED."referral_claimed";

INSERT INTO public.restaurant_profile ("app_user_id", "id", "restaurant_name", "phone", "email", "address", "gst_number", "fssai_number", "restaurant_code", "upi_id", "upi_enabled", "thank_you_message", "gst_percentage", "subscription_status", "subscription_plan", "subscription_expiry", "license_key", "activation_date", "referred_by_reward_granted", "updated_at", "referred_by", "referral_claimed")
VALUES ('5b7b3961-d90d-4064-a72d-20675a6536c5', 'global', 'Siys Resturent', '8677994666', NULL, NULL, '', '', 'RES-56A1C9', NULL, FALSE, NULL, 0, 'trial', 'free-trial', 1783502603479, NULL, 1782134260222, FALSE, '2026-07-01T09:23:23.479+00:00', NULL, FALSE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "restaurant_name" = EXCLUDED."restaurant_name", "phone" = EXCLUDED."phone", "email" = EXCLUDED."email", "address" = EXCLUDED."address", "gst_number" = EXCLUDED."gst_number", "fssai_number" = EXCLUDED."fssai_number", "restaurant_code" = EXCLUDED."restaurant_code", "upi_id" = EXCLUDED."upi_id", "upi_enabled" = EXCLUDED."upi_enabled", "thank_you_message" = EXCLUDED."thank_you_message", "gst_percentage" = EXCLUDED."gst_percentage", "subscription_status" = EXCLUDED."subscription_status", "subscription_plan" = EXCLUDED."subscription_plan", "subscription_expiry" = EXCLUDED."subscription_expiry", "license_key" = EXCLUDED."license_key", "activation_date" = EXCLUDED."activation_date", "referred_by_reward_granted" = EXCLUDED."referred_by_reward_granted", "updated_at" = EXCLUDED."updated_at", "referred_by" = EXCLUDED."referred_by", "referral_claimed" = EXCLUDED."referral_claimed";

INSERT INTO public.restaurant_profile ("app_user_id", "id", "restaurant_name", "phone", "email", "address", "gst_number", "fssai_number", "restaurant_code", "upi_id", "upi_enabled", "thank_you_message", "gst_percentage", "subscription_status", "subscription_plan", "subscription_expiry", "license_key", "activation_date", "referred_by_reward_granted", "updated_at", "referred_by", "referral_claimed")
VALUES ('efe79cde-76f8-4fbe-9184-82eb7a31d177', 'global', 'Sita Hotal And Resturent', '7564876666', NULL, NULL, '', '', 'RES-WCHE7D', NULL, FALSE, NULL, 0, 'trial', 'suspended', 1783502625039, 'RESPOS-M01-1783598127961-78160C4FF1D98A50A2BF96993534F65226F4CB532BCE096E84F32B7AEEE54404D49F1BA1FF680A074296CF5013B743DA843F5FAD0CC76147BBD4FA2E8B3F543E', 1781006136482, TRUE, '2026-07-01T09:23:45.039+00:00', 'QLHFYD', TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "restaurant_name" = EXCLUDED."restaurant_name", "phone" = EXCLUDED."phone", "email" = EXCLUDED."email", "address" = EXCLUDED."address", "gst_number" = EXCLUDED."gst_number", "fssai_number" = EXCLUDED."fssai_number", "restaurant_code" = EXCLUDED."restaurant_code", "upi_id" = EXCLUDED."upi_id", "upi_enabled" = EXCLUDED."upi_enabled", "thank_you_message" = EXCLUDED."thank_you_message", "gst_percentage" = EXCLUDED."gst_percentage", "subscription_status" = EXCLUDED."subscription_status", "subscription_plan" = EXCLUDED."subscription_plan", "subscription_expiry" = EXCLUDED."subscription_expiry", "license_key" = EXCLUDED."license_key", "activation_date" = EXCLUDED."activation_date", "referred_by_reward_granted" = EXCLUDED."referred_by_reward_granted", "updated_at" = EXCLUDED."updated_at", "referred_by" = EXCLUDED."referred_by", "referral_claimed" = EXCLUDED."referral_claimed";

INSERT INTO public.restaurant_profile ("app_user_id", "id", "restaurant_name", "phone", "email", "address", "gst_number", "fssai_number", "restaurant_code", "upi_id", "upi_enabled", "thank_you_message", "gst_percentage", "subscription_status", "subscription_plan", "subscription_expiry", "license_key", "activation_date", "referred_by_reward_granted", "updated_at", "referred_by", "referral_claimed")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'global', 'Test Resturent', '7564876666', NULL, NULL, '', '', 'RES-JJ9POM', NULL, FALSE, NULL, 0, 'premium', 'lifetime', 10422812443144, 'RESPOS-M01-1784638955029-007EE4ABABCC495EE954DCD053B38E38A46753D3F4779354199F0E9ACD33593EE1981014E8BF522D10F077962996543F05290869FEE217B9B6FB449DB71EEB27', 1782044049242, FALSE, '2026-07-01T09:40:43.144+00:00', NULL, FALSE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "restaurant_name" = EXCLUDED."restaurant_name", "phone" = EXCLUDED."phone", "email" = EXCLUDED."email", "address" = EXCLUDED."address", "gst_number" = EXCLUDED."gst_number", "fssai_number" = EXCLUDED."fssai_number", "restaurant_code" = EXCLUDED."restaurant_code", "upi_id" = EXCLUDED."upi_id", "upi_enabled" = EXCLUDED."upi_enabled", "thank_you_message" = EXCLUDED."thank_you_message", "gst_percentage" = EXCLUDED."gst_percentage", "subscription_status" = EXCLUDED."subscription_status", "subscription_plan" = EXCLUDED."subscription_plan", "subscription_expiry" = EXCLUDED."subscription_expiry", "license_key" = EXCLUDED."license_key", "activation_date" = EXCLUDED."activation_date", "referred_by_reward_granted" = EXCLUDED."referred_by_reward_granted", "updated_at" = EXCLUDED."updated_at", "referred_by" = EXCLUDED."referred_by", "referral_claimed" = EXCLUDED."referral_claimed";

-- restaurant_settings (5 rows)
INSERT INTO public.restaurant_settings ("app_user_id", "id", "bill_sequence", "kot_sequence", "last_kot_date", "print_phone", "print_email", "print_address", "print_fssai", "print_gst", "print_thank_you", "print_qr_code", "baud_rate", "printer_width", "printer_mode", "updated_at", "online_delivery_enabled", "online_takeaway_enabled")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'global', 41, 3, '2026-09-13', TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, 9600, 32, 'single', '2026-09-13T09:57:04.496599+00:00', TRUE, TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "bill_sequence" = EXCLUDED."bill_sequence", "kot_sequence" = EXCLUDED."kot_sequence", "last_kot_date" = EXCLUDED."last_kot_date", "print_phone" = EXCLUDED."print_phone", "print_email" = EXCLUDED."print_email", "print_address" = EXCLUDED."print_address", "print_fssai" = EXCLUDED."print_fssai", "print_gst" = EXCLUDED."print_gst", "print_thank_you" = EXCLUDED."print_thank_you", "print_qr_code" = EXCLUDED."print_qr_code", "baud_rate" = EXCLUDED."baud_rate", "printer_width" = EXCLUDED."printer_width", "printer_mode" = EXCLUDED."printer_mode", "updated_at" = EXCLUDED."updated_at", "online_delivery_enabled" = EXCLUDED."online_delivery_enabled", "online_takeaway_enabled" = EXCLUDED."online_takeaway_enabled";

INSERT INTO public.restaurant_settings ("app_user_id", "id", "bill_sequence", "kot_sequence", "last_kot_date", "print_phone", "print_email", "print_address", "print_fssai", "print_gst", "print_thank_you", "print_qr_code", "baud_rate", "printer_width", "printer_mode", "updated_at", "online_delivery_enabled", "online_takeaway_enabled")
VALUES ('efe79cde-76f8-4fbe-9184-82eb7a31d177', 'global', 1, NULL, NULL, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, 9600, 32, 'single', '2026-06-09T10:40:06.292993+00:00', TRUE, TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "bill_sequence" = EXCLUDED."bill_sequence", "kot_sequence" = EXCLUDED."kot_sequence", "last_kot_date" = EXCLUDED."last_kot_date", "print_phone" = EXCLUDED."print_phone", "print_email" = EXCLUDED."print_email", "print_address" = EXCLUDED."print_address", "print_fssai" = EXCLUDED."print_fssai", "print_gst" = EXCLUDED."print_gst", "print_thank_you" = EXCLUDED."print_thank_you", "print_qr_code" = EXCLUDED."print_qr_code", "baud_rate" = EXCLUDED."baud_rate", "printer_width" = EXCLUDED."printer_width", "printer_mode" = EXCLUDED."printer_mode", "updated_at" = EXCLUDED."updated_at", "online_delivery_enabled" = EXCLUDED."online_delivery_enabled", "online_takeaway_enabled" = EXCLUDED."online_takeaway_enabled";

INSERT INTO public.restaurant_settings ("app_user_id", "id", "bill_sequence", "kot_sequence", "last_kot_date", "print_phone", "print_email", "print_address", "print_fssai", "print_gst", "print_thank_you", "print_qr_code", "baud_rate", "printer_width", "printer_mode", "updated_at", "online_delivery_enabled", "online_takeaway_enabled")
VALUES ('74cb3082-864f-4639-ba12-19d9e0438401', 'global', 1, NULL, NULL, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, 9600, 32, 'single', '2026-06-09T11:48:32.848957+00:00', TRUE, TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "bill_sequence" = EXCLUDED."bill_sequence", "kot_sequence" = EXCLUDED."kot_sequence", "last_kot_date" = EXCLUDED."last_kot_date", "print_phone" = EXCLUDED."print_phone", "print_email" = EXCLUDED."print_email", "print_address" = EXCLUDED."print_address", "print_fssai" = EXCLUDED."print_fssai", "print_gst" = EXCLUDED."print_gst", "print_thank_you" = EXCLUDED."print_thank_you", "print_qr_code" = EXCLUDED."print_qr_code", "baud_rate" = EXCLUDED."baud_rate", "printer_width" = EXCLUDED."printer_width", "printer_mode" = EXCLUDED."printer_mode", "updated_at" = EXCLUDED."updated_at", "online_delivery_enabled" = EXCLUDED."online_delivery_enabled", "online_takeaway_enabled" = EXCLUDED."online_takeaway_enabled";

INSERT INTO public.restaurant_settings ("app_user_id", "id", "bill_sequence", "kot_sequence", "last_kot_date", "print_phone", "print_email", "print_address", "print_fssai", "print_gst", "print_thank_you", "print_qr_code", "baud_rate", "printer_width", "printer_mode", "updated_at", "online_delivery_enabled", "online_takeaway_enabled")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'global', 5582, 17, '2026-09-26', TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, 115200, 32, 'single', '2026-09-26T17:31:24.375583+00:00', FALSE, TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "bill_sequence" = EXCLUDED."bill_sequence", "kot_sequence" = EXCLUDED."kot_sequence", "last_kot_date" = EXCLUDED."last_kot_date", "print_phone" = EXCLUDED."print_phone", "print_email" = EXCLUDED."print_email", "print_address" = EXCLUDED."print_address", "print_fssai" = EXCLUDED."print_fssai", "print_gst" = EXCLUDED."print_gst", "print_thank_you" = EXCLUDED."print_thank_you", "print_qr_code" = EXCLUDED."print_qr_code", "baud_rate" = EXCLUDED."baud_rate", "printer_width" = EXCLUDED."printer_width", "printer_mode" = EXCLUDED."printer_mode", "updated_at" = EXCLUDED."updated_at", "online_delivery_enabled" = EXCLUDED."online_delivery_enabled", "online_takeaway_enabled" = EXCLUDED."online_takeaway_enabled";

INSERT INTO public.restaurant_settings ("app_user_id", "id", "bill_sequence", "kot_sequence", "last_kot_date", "print_phone", "print_email", "print_address", "print_fssai", "print_gst", "print_thank_you", "print_qr_code", "baud_rate", "printer_width", "printer_mode", "updated_at", "online_delivery_enabled", "online_takeaway_enabled")
VALUES ('5b7b3961-d90d-4064-a72d-20675a6536c5', 'global', 1, NULL, NULL, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, 9600, 32, 'single', '2026-06-22T13:17:40.221521+00:00', TRUE, TRUE)
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "bill_sequence" = EXCLUDED."bill_sequence", "kot_sequence" = EXCLUDED."kot_sequence", "last_kot_date" = EXCLUDED."last_kot_date", "print_phone" = EXCLUDED."print_phone", "print_email" = EXCLUDED."print_email", "print_address" = EXCLUDED."print_address", "print_fssai" = EXCLUDED."print_fssai", "print_gst" = EXCLUDED."print_gst", "print_thank_you" = EXCLUDED."print_thank_you", "print_qr_code" = EXCLUDED."print_qr_code", "baud_rate" = EXCLUDED."baud_rate", "printer_width" = EXCLUDED."printer_width", "printer_mode" = EXCLUDED."printer_mode", "updated_at" = EXCLUDED."updated_at", "online_delivery_enabled" = EXCLUDED."online_delivery_enabled", "online_takeaway_enabled" = EXCLUDED."online_takeaway_enabled";

-- licenses (4 rows)
INSERT INTO public.licenses ("id", "license_key", "plan_type", "status", "expiry_days", "created_by", "claimed_by_user_id", "claimed_at", "created_at", "restaurant_code")
VALUES ('66e175ab-a14b-41bb-a97b-6d633c72f0da', 'RESPOS-LIF-10421527447516-F7BB8C8E4CE43D30D25ED2733922113CB08BAC89DA17C680C4606AAA71F5363E5D9DBEF2D59D7F938B7E7935E3231E976C5276DE7045C26CEA1FBFEF60B1D64C', 'lifetime', 'claimed', 99999, NULL, '80da6da2-f043-470f-8cd0-c266c2c03117', '2026-06-16T12:44:24.266+00:00', '2026-06-16T12:44:08.155371+00:00', 'RES-BP20VY')
ON CONFLICT ("id") DO UPDATE SET "license_key" = EXCLUDED."license_key", "plan_type" = EXCLUDED."plan_type", "status" = EXCLUDED."status", "expiry_days" = EXCLUDED."expiry_days", "created_by" = EXCLUDED."created_by", "claimed_by_user_id" = EXCLUDED."claimed_by_user_id", "claimed_at" = EXCLUDED."claimed_at", "created_at" = EXCLUDED."created_at", "restaurant_code" = EXCLUDED."restaurant_code";

INSERT INTO public.licenses ("id", "license_key", "plan_type", "status", "expiry_days", "created_by", "claimed_by_user_id", "claimed_at", "created_at", "restaurant_code")
VALUES ('87671ace-39cd-4e81-ab8a-b8f9ef6e855e', 'RESPOS-LIF-10421957638009-BBA0DA3EDE557F38BAF716E2C94EF8C9FA26BB29EA69487F14421402611E6BD528826689E7336180F608AFA2AD2E5F7DD68B9571D17411039FC4DD6C09570E8F', 'lifetime', 'claimed', 99999, NULL, '97497e5c-9036-47dc-8973-035f1a928aa4', '2026-06-21T12:14:09.473+00:00', '2026-06-21T12:13:58.430475+00:00', 'RES-JJ9POM')
ON CONFLICT ("id") DO UPDATE SET "license_key" = EXCLUDED."license_key", "plan_type" = EXCLUDED."plan_type", "status" = EXCLUDED."status", "expiry_days" = EXCLUDED."expiry_days", "created_by" = EXCLUDED."created_by", "claimed_by_user_id" = EXCLUDED."claimed_by_user_id", "claimed_at" = EXCLUDED."claimed_at", "created_at" = EXCLUDED."created_at", "restaurant_code" = EXCLUDED."restaurant_code";

INSERT INTO public.licenses ("id", "license_key", "plan_type", "status", "expiry_days", "created_by", "claimed_by_user_id", "claimed_at", "created_at", "restaurant_code")
VALUES ('eb9d5a58-54d8-4364-900b-e3162da4839a', 'RESPOS-M01-1784638554411-A7F654DD34D6BCBF4F0D7AA1863941895BABF86FF1A1736B16D050075DA47C2678AB7D5E71198C2960741B7BA68668468E14D411E60CCC14014B564304410BD0', 'lifetime', 'claimed', 30, NULL, '97497e5c-9036-47dc-8973-035f1a928aa4', '2026-06-21T12:55:54.699902+00:00', '2026-06-21T12:55:54.699902+00:00', 'RES-JJ9POM')
ON CONFLICT ("id") DO UPDATE SET "license_key" = EXCLUDED."license_key", "plan_type" = EXCLUDED."plan_type", "status" = EXCLUDED."status", "expiry_days" = EXCLUDED."expiry_days", "created_by" = EXCLUDED."created_by", "claimed_by_user_id" = EXCLUDED."claimed_by_user_id", "claimed_at" = EXCLUDED."claimed_at", "created_at" = EXCLUDED."created_at", "restaurant_code" = EXCLUDED."restaurant_code";

INSERT INTO public.licenses ("id", "license_key", "plan_type", "status", "expiry_days", "created_by", "claimed_by_user_id", "claimed_at", "created_at", "restaurant_code")
VALUES ('76c027d3-c195-41ce-9c96-4007a5722798', 'RESPOS-M01-1784638955029-007EE4ABABCC495EE954DCD053B38E38A46753D3F4779354199F0E9ACD33593EE1981014E8BF522D10F077962996543F05290869FEE217B9B6FB449DB71EEB27', 'lifetime', 'claimed', 30, NULL, '97497e5c-9036-47dc-8973-035f1a928aa4', '2026-06-21T13:02:35.333757+00:00', '2026-06-21T13:02:35.333757+00:00', 'RES-JJ9POM')
ON CONFLICT ("id") DO UPDATE SET "license_key" = EXCLUDED."license_key", "plan_type" = EXCLUDED."plan_type", "status" = EXCLUDED."status", "expiry_days" = EXCLUDED."expiry_days", "created_by" = EXCLUDED."created_by", "claimed_by_user_id" = EXCLUDED."claimed_by_user_id", "claimed_at" = EXCLUDED."claimed_at", "created_at" = EXCLUDED."created_at", "restaurant_code" = EXCLUDED."restaurant_code";

-- subscription_plans (3 rows)
INSERT INTO public.subscription_plans ("id", "name", "price", "duration_days", "features", "stripe_price_id", "is_active", "created_at")
VALUES ('8a721466-9b8a-414f-8ade-60b0786bdea2', 'Yearly Plan', 999, 365, '["Full POS Access","WhatsApp Support","Priority Support","1  Store"]'::jsonb, NULL, TRUE, '2026-05-21T12:46:18.720327+00:00')
ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "duration_days" = EXCLUDED."duration_days", "features" = EXCLUDED."features", "stripe_price_id" = EXCLUDED."stripe_price_id", "is_active" = EXCLUDED."is_active", "created_at" = EXCLUDED."created_at";

INSERT INTO public.subscription_plans ("id", "name", "price", "duration_days", "features", "stripe_price_id", "is_active", "created_at")
VALUES ('43a4f8ad-d544-456c-a7a8-d63142366fcc', 'Monthly Plan', 99, 30, '["Full POS Access","WhatsApp Support","Priority Support","1  Store"]'::jsonb, NULL, TRUE, '2026-05-21T12:46:18.720327+00:00')
ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "duration_days" = EXCLUDED."duration_days", "features" = EXCLUDED."features", "stripe_price_id" = EXCLUDED."stripe_price_id", "is_active" = EXCLUDED."is_active", "created_at" = EXCLUDED."created_at";

INSERT INTO public.subscription_plans ("id", "name", "price", "duration_days", "features", "stripe_price_id", "is_active", "created_at")
VALUES ('49023beb-2bde-4376-a951-e6d7717d4b3d', 'Half-Yearly Plan', 499, 180, '["Full POS Access","WhatsApp Support","Priority Support","1  Store"]'::jsonb, NULL, TRUE, '2026-05-21T12:46:18.720327+00:00')
ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "duration_days" = EXCLUDED."duration_days", "features" = EXCLUDED."features", "stripe_price_id" = EXCLUDED."stripe_price_id", "is_active" = EXCLUDED."is_active", "created_at" = EXCLUDED."created_at";

-- settings (3 rows)
INSERT INTO public.settings ("app_user_id", "id", "data", "updated_at")
VALUES ('global', 'pricing_plans', '{"43a4f8ad-d544-456c-a7a8-d63142366fcc":{"days":30,"name":"Monthly Plan","price":149,"features":["Full POS Access","WhatsApp Support","Priority Support","1  Store"]},"49023beb-2bde-4376-a951-e6d7717d4b3d":{"days":180,"name":"Half-Yearly Plan","price":599,"features":["Full POS Access","WhatsApp Support","Priority Support","1  Store"]},"8a721466-9b8a-414f-8ade-60b0786bdea2":{"days":365,"name":"Yearly Plan","price":999,"features":["Full POS Access","WhatsApp Support","Priority Support","1  Store"]}}'::jsonb, '2026-06-08T15:01:37.208+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.settings ("app_user_id", "id", "data", "updated_at")
VALUES ('global', 'payment_settings', '{"upi_id_1":"8677994666-4@axl","upi_id_2":"gudduk483-10@okaxis"}'::jsonb, '2026-06-21T12:49:22.519+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.settings ("app_user_id", "id", "data", "updated_at")
VALUES ('global', 'system_backups', '{"records":[{"id":"BK-1783422659185","sizeBytes":2309585,"timestamp":"2026-07-07T11:10:59.185Z","plansCount":3,"ticketsCount":0,"totalRecords":1902,"licensesCount":4},{"id":"BK-1782193740149","sizeBytes":710979,"timestamp":"2026-06-23T05:49:00.149Z","plansCount":3,"ticketsCount":0,"totalRecords":602,"licensesCount":4},{"id":"RS-1781269992095","sizeBytes":17128,"timestamp":"2026-06-12T13:13:12.095Z","plansCount":3,"ticketsCount":2,"totalRecords":28,"licensesCount":8},{"id":"RS-1781015244134","sizeBytes":9554283,"timestamp":"2026-06-09T14:27:24.134Z","plansCount":3,"ticketsCount":2,"totalRecords":10027,"licensesCount":8},{"id":"RS-1779376723874","sizeBytes":42123,"timestamp":"2026-05-21T15:18:43.874Z","plansCount":3,"ticketsCount":1,"totalRecords":78,"licensesCount":1},{"id":"RS-1779376603377","sizeBytes":42123,"timestamp":"2026-05-21T15:16:43.377Z","plansCount":3,"ticketsCount":1,"totalRecords":78,"licensesCount":1},{"id":"RS-1779376528117","sizeBytes":42123,"timestamp":"2026-05-21T15:15:28.117Z","plansCount":3,"ticketsCount":1,"totalRecords":78,"licensesCount":1},{"id":"BK-1779376516601","sizeBytes":42123,"timestamp":"2026-05-21T15:15:16.601Z","plansCount":3,"ticketsCount":1,"totalRecords":78,"licensesCount":1},{"id":"BK-1779287480385","sizeBytes":38445,"timestamp":"2026-05-20T14:31:20.385Z","plansCount":3,"ticketsCount":0,"totalRecords":80,"licensesCount":1},{"id":"BK-1779285499599","sizeBytes":2767,"timestamp":"2026-05-20T13:58:19.599Z","plansCount":3,"ticketsCount":0,"licensesCount":1}]}'::jsonb, '2026-07-07T11:10:59.186+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at";

-- categories (12 rows)
INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-0vhmo3', 'Veg & Starters', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-2243ag', 'Add On (Rice & Roti)', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-0ffcb8', 'Egg', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-gl5w8q', 'Chicken', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-yek1zk', 'Briyani', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-qw1i0y', 'Thali', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-f41pgu', 'Beverages', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'c-l1bd1x', 'Paneer', '2026-06-16T12:48:23.769+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'c-5t3cx0', 'Soup', '2026-06-23T13:22:00.653+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'c-fvq9q8', 'Starter', '2026-06-23T13:22:00.653+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'c-ztfl8h', 'Mains', '2026-06-23T13:22:00.653+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

INSERT INTO public.categories ("app_user_id", "id", "name", "updated_at")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'c-euzt5j', 'Chinese', '2026-06-23T13:22:00.653+00:00')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "updated_at" = EXCLUDED."updated_at";

-- menu_items (68 rows)
INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-2xi49z', 'Hot & Sour Soup', 130, 'Soup', TRUE, FALSE, '[]'::jsonb, '{}'::jsonb, '2026-06-23T13:22:00.88+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-7zw8ej', 'Paneer Tikka', 240, 'Starter', TRUE, FALSE, '[{"name":"Half","price":140},{"name":"Full","price":240}]'::jsonb, '{}'::jsonb, '2026-06-23T13:22:00.88+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-2vbuyi', 'Kadhai Paneer', 285, 'Mains', TRUE, FALSE, '[]'::jsonb, '{}'::jsonb, '2026-06-23T13:22:00.88+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-3zijqc', 'Veg Chowmein', 160, 'Chinese', TRUE, TRUE, '[{"name":"Half","price":90},{"name":"Full","price":160}]'::jsonb, '{}'::jsonb, '2026-07-15T13:09:41.816+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-21l8kp', 'Dal Makhani', 220, 'Mains', TRUE, TRUE, '[{"name":"Half","price":130},{"name":"Full","price":220}]'::jsonb, '{}'::jsonb, '2026-07-15T13:09:43.514+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-tmyqqh', 'Tomato Soup', 120, 'Soup', TRUE, TRUE, '[{"name":"Half","price":70},{"name":"Full","price":120}]'::jsonb, '{}'::jsonb, '2026-07-15T13:09:45.179+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', 'i-dv22sz', 'Veg Spring Roll', 180, 'Starter', TRUE, TRUE, '[]'::jsonb, '{}'::jsonb, '2026-07-15T13:09:47.261+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', '1782469005615', 'Dahi', 30, 'Add On (Rice & Roti)', TRUE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-26T10:16:45.62+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', '1783699676867', 'Papad', 10, 'Add On (Rice & Roti)', TRUE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-14T08:24:14.806+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', '1784814335945', 'Paneer Manchurian', 80, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":160,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-07-23T13:46:31.549+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-l9zlvk', 'Matar Paneer', 130, 'Paneer', FALSE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-27T11:44:27.995+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-sz46jf', 'Limka', 20, 'Beverages', TRUE, FALSE, '[{"name":"250ml","price":20,"isActive":false,"stockItemId":"s-1781949326546"},{"name":"740ml","price":35,"isActive":true,"stockItemId":"s-1782147557584"}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-12T12:23:01.309+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-53f70k', 'Coca Cola', 15, 'Beverages', TRUE, FALSE, '[{"name":"250ml","price":15,"isActive":false,"stockItemId":"s-1781949260948"},{"name":"250ml 0 Suger","price":10,"isActive":false,"stockItemId":"s-1782742162969"},{"name":"400ml","price":20,"isActive":false,"stockItemId":"s-1784549340984"},{"name":"125ml","price":10,"isActive":true,"stockItemId":"s-1782742162969"}]'::jsonb, '{"stockItemId":"s-1781949260948","stockQtyPerUnit":0}'::jsonb, '2026-09-23T10:22:59.842+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-dxm3t2', 'Lahori Zeera 160ml', 10, 'Beverages', FALSE, FALSE, '[]'::jsonb, '{"stockItemId":"s-1781949316297","stockQtyPerUnit":0}'::jsonb, '2026-06-27T11:47:02.399+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('97497e5c-9036-47dc-8973-035f1a928aa4', '1785327881074', 'Watwer', 20, 'Soup', TRUE, FALSE, '[]'::jsonb, '{"stockItemId":"1785327842557","stockQtyPerUnit":0}'::jsonb, '2026-07-29T12:24:41.09+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-yt4bnu', 'Buttar Roti Tebal', 10, 'Add On (Rice & Roti)', TRUE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-09T06:19:57.903+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-8bwunl', 'Chicken Egg Fried Rice', 90, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":90,"isActive":true},{"name":"Full","price":140,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-19T08:36:25.16+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-z60e3t', 'Dal Fry', 80, 'Veg & Starters', TRUE, TRUE, '[]'::jsonb, '{}'::jsonb, '2026-09-09T15:52:54.888+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-92i9dz', 'Boild Egg', 15, 'Egg', TRUE, FALSE, '[]'::jsonb, '{}'::jsonb, '2026-06-16T12:48:24.099+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-kdvpfu', 'Butter Roti', 10, 'Add On (Rice & Roti)', TRUE, FALSE, '[]'::jsonb, '{}'::jsonb, '2026-06-16T12:48:24.099+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-garakz', 'Chicken', 30, 'Add On (Rice & Roti)', TRUE, FALSE, '[]'::jsonb, '{}'::jsonb, '2026-06-16T12:48:24.099+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-1hh9o8', 'Chicken Fry Biryani', 100, 'Briyani', TRUE, TRUE, '[{"name":"Half","price":100,"isActive":true},{"name":"Full","price":160,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:00:40.221+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-dwtn1j', 'Butter Chicken', 100, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":100,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:48:12.093+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-m3tioh', 'Chicken Dum Biryani', 90, 'Briyani', TRUE, TRUE, '[{"name":"Half","price":90,"isActive":true},{"name":"Full","price":140,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:00:38.818+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-qcq6sz', 'Kadai Paneer', 95, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:04:19.54+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-v2vtio', 'Biriyani Rice', 30, 'Add On (Rice & Roti)', TRUE, FALSE, '[{"name":"Half","price":30,"isActive":true},{"name":"Full","price":50,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:06:09.887+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-f6d5gc', 'Egg Curry', 80, 'Egg', TRUE, TRUE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":110,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:30:55.61+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-dzxftj', 'Chicken Do Pyaza', 95, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":170,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:50:08.534+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-4i2lux', 'Rice Thali', 70, 'Thali', TRUE, TRUE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:31:11.038+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-e0fzgx', 'Egg Masala', 80, 'Egg', TRUE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":110,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:53:08.381+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-sq3ihx', 'Chicken Rice Thali', 110, 'Thali', TRUE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:58:49.72+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-4ux0s0', 'Special Rice Thali', 90, 'Thali', TRUE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:00:53.424+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-bml7gq', 'Chicken Chilli', 100, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":100,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:25:04.192+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-4ixjpq', 'Chicken 65', 90, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":90,"isActive":true},{"name":"Full","price":160,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:25:26.931+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-dkc40t', 'Chicken Masala Fry', 100, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":100,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:26:07.535+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-77hv1k', 'Kadai Chicken', 100, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":100,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:27:00.305+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-7eaqlv', 'Mutton Biryani', 140, 'Briyani', FALSE, FALSE, '[{"name":"Half","price":140,"isActive":true},{"name":"Full","price":230,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-27T11:44:18.451+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-s0nx7y', 'Veg Chilli', 150, 'Veg & Starters', FALSE, FALSE, '[{"name":"Half","price":100},{"name":"Full","price":150}]'::jsonb, '{}'::jsonb, '2026-06-27T11:44:35.245+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-wftotj', 'Roti Thali', 80, 'Thali', TRUE, FALSE, '[]'::jsonb, '{}'::jsonb, '2026-06-16T12:48:24.099+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-p1nvlm', 'Veg Manchurian Dry', 140, 'Veg & Starters', FALSE, FALSE, '[{"name":"Half","price":90},{"name":"Full","price":140}]'::jsonb, '{}'::jsonb, '2026-06-27T11:44:36.864+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-nyozlk', 'Veg Manchurian Gravy', 150, 'Veg & Starters', FALSE, FALSE, '[{"name":"Half","price":95},{"name":"Full","price":150}]'::jsonb, '{}'::jsonb, '2026-06-27T11:44:37.763+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-3iyerb', 'Nimbooz 345ml', 20, 'Beverages', FALSE, FALSE, '[]'::jsonb, '{"stockItemId":"s-1781949387461","stockQtyPerUnit":0}'::jsonb, '2026-06-27T11:45:47.116+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-rxwz2y', 'Mutton Curry', 220, 'Chicken', FALSE, FALSE, '[{"name":"Half","price":130},{"name":"Full","price":220}]'::jsonb, '{}'::jsonb, '2026-07-10T07:06:00.646+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-ifkk3v', 'Thums Up', 10, 'Beverages', TRUE, FALSE, '[{"name":"Xforce","price":10,"isActive":false,"stockItemId":"s-1781949426983"},{"name":"250ml","price":20,"isActive":true,"stockItemId":"s-1781949429613"},{"name":"740ml","price":35,"isActive":false,"stockItemId":"s-1781949431399"},{"name":"2l","price":85,"isActive":false,"stockItemId":"s-1781949434232"}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-23T10:22:41.353+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-qxgz78', 'Shahi Paneer', 95, 'Paneer', TRUE, TRUE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-08-29T07:15:32.222+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-g1oj5n', 'Maza', 10, 'Beverages', TRUE, FALSE, '[{"name":"125ml","price":10,"isActive":true,"stockItemId":"s-1781949359613"},{"name":"600ml","price":40,"isActive":true,"stockItemId":"s-1781949362868"}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-23T10:23:11.818+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-4wmpox', 'Roti Table', 7, 'Add On (Rice & Roti)', TRUE, TRUE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-07-30T09:20:07.817+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-u0h0cq', 'Kinley', 10, 'Beverages', TRUE, TRUE, '[{"name":"500ml","price":10,"isActive":true,"stockItemId":"s-1781949301154"},{"name":"1lt","price":20,"isActive":true,"stockItemId":"s-1781949305193"}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-07-09T08:55:54.434+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-ys9hgv', 'Fenta', 10, 'Beverages', TRUE, FALSE, '[{"name":"250ml","price":10,"isActive":false,"stockItemId":"s-1781949272762"},{"name":"400ml","price":20,"isActive":true,"stockItemId":"s-1790158724815"}]'::jsonb, '{"stockItemId":"s-1781949272762","stockQtyPerUnit":0}'::jsonb, '2026-09-23T10:20:38.939+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-992nqy', 'Paneer Fried Rice', 80, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":150,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:04:50.606+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-kzgkk8', 'Paneer Masala', 90, 'Paneer', TRUE, TRUE, '[{"name":"Half","price":90,"isActive":true},{"name":"Full","price":170,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:31:02.464+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-04byv3', 'Paneer Pyaza', 90, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":90,"isActive":true},{"name":"Full","price":170,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:02:16.826+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-awmy0d', 'Paneer Butter Masala', 95, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:03:04.984+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-kpam7d', 'Paneer Chilli', 95, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:03:42.01+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-qx8rg3', 'Paneer Chilli Dry', 95, 'Paneer', TRUE, FALSE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:05:19.765+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-8npanj', 'Zira Rice', 30, 'Add On (Rice & Roti)', TRUE, FALSE, '[{"name":"Half","price":30,"isActive":true},{"name":"Full","price":50,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:06:50.678+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-io1xtx', 'Egg Biryani', 80, 'Briyani', TRUE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":110,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:47:06.689+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', '1781855484269', 'Chicken Curry', 80, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":140,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:51:58.804+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-77mioq', 'Omelette', 30, 'Egg', TRUE, FALSE, '[{"name":"Half","price":30,"isActive":true},{"name":"Full","price":50,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:53:21.229+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-p0dkq4', 'Chicken Fried Rice', 80, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":130,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:56:59.437+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', '1781855976810', 'Chicken Roti Thali', 120, 'Thali', TRUE, FALSE, '[]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T07:59:36.81+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-llz99t', 'Chicken Masala', 95, 'Chicken', TRUE, TRUE, '[{"name":"Half","price":95,"isActive":true},{"name":"Full","price":170,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:30:33.391+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-m53kra', 'Tawa Roti', 7, 'Add On (Rice & Roti)', TRUE, TRUE, '[]'::jsonb, '{}'::jsonb, '2026-06-19T08:30:37.146+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-zraruc', 'Plain Rice', 40, 'Add On (Rice & Roti)', TRUE, TRUE, '[{"name":"Half","price":20},{"name":"Full","price":40}]'::jsonb, '{}'::jsonb, '2026-06-19T08:30:39.701+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-xu44et', 'Chicken Manchurian', 85, 'Chicken', TRUE, FALSE, '[{"name":"Half","price":85,"isActive":true},{"name":"Full","price":150,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-19T08:24:45.984+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-eidffv', 'Veg 65', 80, 'Veg & Starters', FALSE, FALSE, '[{"name":"Half","price":80,"isActive":true},{"name":"Full","price":130,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-27T11:44:43.221+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-tbjryi', 'Chicken Oil Fry', 100, 'Chicken', FALSE, FALSE, '[{"name":"Half","price":100,"isActive":true},{"name":"Full","price":180,"isActive":true}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-06-27T11:45:01.432+00:00', 'kitchen')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

INSERT INTO public.menu_items ("app_user_id", "id", "name", "price", "category", "is_active", "is_favorite", "variants", "data", "updated_at", "printer_target")
VALUES ('80da6da2-f043-470f-8cd0-c266c2c03117', 'i-z9wept', 'Sprit', 20, 'Beverages', TRUE, FALSE, '[{"name":"250ml","price":20,"isActive":true,"stockItemId":"s-1781950490466"},{"name":"0 suger","price":10,"isActive":false,"stockItemId":"s-1781949413714"},{"name":"740ml","price":35,"isActive":false,"stockItemId":"s-1781949416786"},{"name":"2l","price":85,"isActive":false,"stockItemId":"s-1781949419634"}]'::jsonb, '{"stockQtyPerUnit":0}'::jsonb, '2026-09-23T10:22:42.152+00:00', 'bar')
ON CONFLICT ("app_user_id", "id") DO UPDATE SET "name" = EXCLUDED."name", "price" = EXCLUDED."price", "category" = EXCLUDED."category", "is_active" = EXCLUDED."is_active", "is_favorite" = EXCLUDED."is_favorite", "variants" = EXCLUDED."variants", "data" = EXCLUDED."data", "updated_at" = EXCLUDED."updated_at", "printer_target" = EXCLUDED."printer_target";

