import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:story_spark/core/constants/app_branding.dart';
import 'package:story_spark/screens/story_buddy_screen.dart';

void main() {
  testWidgets('renders StorySpark home screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: StoryBuddyScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppBranding.name), findsOneWidget);
    expect(find.text('Read Me a Story'), findsOneWidget);
    expect(find.text('Pip and the Whispering Woods'), findsOneWidget);
    expect(find.textContaining('clever little robot'), findsOneWidget);
  });
}
