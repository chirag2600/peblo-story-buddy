import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'screens/story_buddy_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PebloStoryBuddyApp()));
}

class PebloStoryBuddyApp extends StatelessWidget {
  const PebloStoryBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const StoryBuddyScreen(),
    );
  }
}
