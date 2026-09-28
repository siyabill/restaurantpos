import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'views/auth/login_view.dart';
import 'views/home/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty) {
    supabaseUrl = AppConstants.supabaseUrl;
  }
  if (supabaseAnonKey.isEmpty) {
    supabaseAnonKey = AppConstants.supabaseAnonKey;
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    debugPrint("Supabase Client failed to initialize: $e");
  }

  runApp(
    const ProviderScope(
      child: SiyaAdminApp(),
    ),
  );
}

class SiyaAdminApp extends ConsumerWidget {
  const SiyaAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'SIYA POS Super Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: authState.isAuthenticated ? const AppShell() : const LoginView(),
    );
  }
}
