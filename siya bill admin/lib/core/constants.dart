class AppConstants {
  // Supabase Configuration
  // Fallbacks to placeholders so application loads without crash even if no keys provided.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://yatzsfzzjoxyhbjrvjms.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlhdHpzZnp6am94eWhianJ2am1zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA0MTIxMTYsImV4cCI6MjEwNTk4ODExNn0.LGCWhSr3cnP2T024rGcdmmL-tb1trg0pFPNiTVZZunY',
  );
  
  static const String adminEmail = 'gudduk483@gmail.com';
}
