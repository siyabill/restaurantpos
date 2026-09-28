import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final service = SupabaseService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
