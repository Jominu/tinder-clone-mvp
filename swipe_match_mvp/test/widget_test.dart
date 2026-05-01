import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_match_mvp/features/auth/auth_view_model.dart';
import 'package:swipe_match_mvp/main.dart';

void main() {
  testWidgets('renders auth screen with default Supabase config', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(null)],
        child: const SwipeMatchApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Swipe Match'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
