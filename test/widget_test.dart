import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_story_buddy/main.dart';

void main() {
  testWidgets('renders story buddy screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PebloStoryBuddyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Peblo Story Buddy'), findsOneWidget);
    expect(find.text('Read Me a Story'), findsOneWidget);
    expect(find.textContaining('clever little robot'), findsOneWidget);
  });
}
