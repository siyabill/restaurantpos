import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://yatzsfzzjoxyhbjrvjms.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhdHpzZnp6am94eWhianJ2am1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0MTIxMTYsImV4cCI6MjEwNTk4ODExNn0.LGCWhSr3cnP2T024rGcdmmL-tb1trg0pFPNiTVZZunY';

let supabaseClient: SupabaseClient | null = null;

try {
  if (supabaseUrl && supabaseUrl.startsWith('http') && supabaseAnonKey) {
    supabaseClient = createClient(supabaseUrl, supabaseAnonKey);
  }
} catch (error) {
  console.error("Failed to initialize Supabase:", error);
}

export const supabase = supabaseClient;

// Helper to check if Supabase is properly configured
export const isSupabaseConfigured = () => {
  return supabase !== null;
};
