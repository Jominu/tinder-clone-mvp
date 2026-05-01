import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_match_mvp/main.dart';

void main() {
  testWidgets('renders configuration screen when Supabase is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SwipeMatchApp()));
    await tester.pumpAndSettle();

    expect(find.text('Swipe Match'), findsOneWidget);
    expect(find.textContaining('Supabase is not configured'), findsOneWidget);
  });
}
