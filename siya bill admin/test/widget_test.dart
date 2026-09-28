import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:siya_bill_admin/main.dart';
import 'package:siya_bill_admin/providers/supabase_provider.dart';
import 'package:siya_bill_admin/services/supabase_service.dart';

void main() {
  testWidgets('App loads check', (WidgetTester tester) async {
    // Build our app and trigger a frame with mock provider override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWith((ref) {
            final svc = SupabaseService(useMock: true);
            ref.onDispose(() => svc.dispose());
            return svc;
          }),
        ],
        child: const SiyaAdminApp(),
      ),
    );

    // Verify that the login screen is loaded by checking for the access button
    expect(find.text('Access Dashboard'), findsOneWidget);
    expect(find.text('Super Admin Portal'), findsOneWidget);
  });
}
