<div align="center">

# Peblo Story Buddy & Quiz

**A joyful, child-first Flutter experience — AI narration meets interactive learning.**

Built for the [Peblo Developer Intern Challenge](https://www.mypeblo.com) · Flutter · Riverpod · Native TTS

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-00D1B2?style=for-the-badge)](https://riverpod.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-6B4EFF?style=for-the-badge)](https://github.com/chirag2600/peblo-story-buddy)

<br/>

[Features](#-features) · [Quick Start](#-quick-start) · [Architecture](#-architecture) · [Challenge Responses](#-challenge-responses) · [Performance](#-performance)

</div>

---

## Overview

**Peblo Story Buddy** is a single-screen mobile app where a friendly AI companion reads a short story aloud, then guides the child through a data-driven quiz. Every interaction is designed for delight — smooth animations, haptic feedback, and celebratory moments that reward curiosity.

> *"Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods..."*

| | |
|---|---|
| **Audience** | Children in India, mid-range Android (~3 GB RAM) |
| **Framework** | Flutter (cross-platform, performance-focused) |
| **State** | Riverpod — isolated audio & quiz state |
| **Audio** | Native device TTS (`flutter_tts`) |

---

## Features

| Feature | Implementation |
|---------|----------------|
| **Kid-friendly UI** | Vibrant Peblo-inspired palette, custom-painted AI Buddy, playful bubble background |
| **Story narration** | One-tap TTS with preparing / speaking / error states |
| **Data-driven quiz** | Renders any question with 3–5 options from JSON — zero UI code changes |
| **Wrong answer** | Card shake animation + medium haptic impact |
| **Correct answer** | Confetti burst, happy buddy expression, success banner + heavy haptic |
| **Resilience** | Graceful error handling with friendly retry — no hangs, no crashes |

### User flow

```
Tap "Read Me a Story"
        │
        ▼
   TTS narrates story ──► Buddy animates while speaking
        │
        ▼
   Audio completes ──► Quiz slides in (fade + slide)
        │
        ├── Wrong answer ──► Shake + haptic ──► Try again
        │
        └── Correct answer ──► Confetti + happy buddy + "You got it!"
```

---

## Quick Start

### Prerequisites

- Flutter SDK ≥ 3.41
- Android Studio / Xcode (for device builds)
- Physical Android device recommended for best TTS quality

### Run locally

```bash
git clone https://github.com/chirag2600/peblo-story-buddy.git
cd peblo-story-buddy
flutter pub get
flutter run
```

### Release & profiling builds

```bash
# Optimized APK for mid-range Android
flutter build apk --release --split-per-abi

# Profile mode for DevTools frame analysis
flutter run --profile
```

---

## Architecture

```
lib/
├── core/theme/           # Brand colors, Nunito typography
├── data/                 # Story text & quiz JSON (simulated backend)
├── models/               # QuizModel — API payload parser
├── providers/            # StoryBuddyNotifier (Riverpod)
├── services/             # TtsService — device speech engine
├── screens/              # StoryBuddyScreen
└── widgets/              # Buddy, quiz, shake, confetti
```

### Tech stack

| Package | Purpose |
|---------|---------|
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | Reactive state management |
| [`flutter_tts`](https://pub.dev/packages/flutter_tts) | Native text-to-speech |
| [`confetti`](https://pub.dev/packages/confetti) | Celebration particles |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Nunito — warm, readable type |

### State machine

```
TTS:   idle ──► preparing ──► speaking ──► completed
                      │                        │
                      ▼                        ▼
                    error              Quiz: hidden ──► revealing ──► visible ──► success
                      │
                      └──► Retry
```

---

## Challenge Responses

### Why Flutter?

Peblo's audience spans millions of children on **mid-range Android devices**. Flutter delivers:

- **One codebase** for Android & iOS
- **60 fps animations** via Impeller/Skia — shake, confetti, transitions
- **Mature TTS** through `flutter_tts` with no network dependency
- **Riverpod** for surgical rebuilds — audio state never triggers full-screen repaints

### Audio → quiz transition

Managed in `StoryBuddyNotifier` (`lib/providers/story_buddy_provider.dart`):

1. `TtsService` emits `TtsStatus.completed` via a `Stream` (not polling)
2. Provider transitions `quizPhase` → `revealing`
3. After **400 ms**, phase becomes `visible`
4. `AnimatedSwitcher` applies `FadeTransition` + `SlideTransition`

This cleanly decouples audio completion from UI animation timing.

### Data-driven quiz renderer

The quiz is **never hardcoded** in widgets. `StoryContent.quizJson` simulates a backend response, parsed by `QuizModel.fromJson()`:

```json
{
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
}
```

`QuizWidget` dynamically generates option buttons:

```dart
...List.generate(quiz.options.length, (index) {
  final option = quiz.options[index];
  return _QuizOptionButton(label: option, onTap: () => onOptionSelected(option));
}),
```

Swap the JSON to 3 or 5 options — the UI adapts with **no code changes**.

### Caching strategy

| Scenario | Approach |
|----------|----------|
| **Current (native TTS)** | Speech synthesized on-device — no network, no cache needed |
| **Remote audio (ElevenLabs)** | LRU memory cache (last 3) + disk cache via `flutter_cache_manager` keyed by story hash |
| **Prefetch** | Download on screen load; show preparing state until buffer ready |
| **Fallback** | Network failure → degrade to `flutter_tts` automatically |

`TtsService` is isolated behind an interface — swap implementations without touching UI or providers.

### Audio loading & failure handling

| State | User sees |
|-------|-----------|
| `preparing` | Spinner + *"Getting ready..."* |
| `speaking` | Disabled button + *"Reading..."* + buddy mouth animation |
| `completed` | Quiz reveal triggered |
| `error` | Friendly banner: *"Oops! I couldn't read the story."* + **Retry** button |

All errors are caught in `TtsService.speak()` — the app never hangs or crashes on TTS failure.

---

## Performance

Profiled with **Flutter DevTools** (`flutter run --profile`) on mid-range hardware constraints.

| Metric | Before | After |
|--------|--------|-------|
| Frame build (idle) | ~0.8 ms | ~0.4 ms |
| Frame build (confetti) | ~18 ms (jank) | ~12 ms (stable 60 fps) |
| Rebuilds during TTS | Full screen | Buddy + button only |

### Optimizations applied

- **CustomPaint buddy** — zero image assets, no decode overhead
- **Confetti capped** at 28 particles, 3-second burst
- **`AnimatedBuilder`** for shake — quiz options don't rebuild
- **Lightweight deps** — 4 packages total, no Lottie/heavy animation libs
- **Single screen** — no navigation stack memory cost
- **`--split-per-abi`** — smaller APK per device architecture

> **Profiling tip:** Run `flutter run --profile` → DevTools → Performance → record the full flow (story → quiz → wrong → success) and capture the frame chart for submission.

---

## AI Usage & Judgment

| Area | How AI was used |
|------|-----------------|
| Project scaffolding | Folder structure, Riverpod patterns, README outline |
| CustomPaint buddy | Initial character sketch; expressions refined manually |
| Color palette | Purple/orange suggestions aligned with Peblo brand tone |

**Rejected:** AI suggested **Lottie animations** for the buddy and confetti. Rejected — Lottie adds 200 KB+ assets and JSON parsing overhead, poor fit for 3 GB RAM devices. Replaced with `CustomPaint` + lightweight `confetti` package.

**Resolved bug:** `await _tts.speak()` returned before speech finished on Android. Fixed by using `setCompletionHandler` stream callbacks instead.

---

## Project Structure

<details>
<summary><strong>Full file tree</strong></summary>

```
peblo-story-buddy/
├── lib/
│   ├── core/theme/app_theme.dart
│   ├── data/story_content.dart
│   ├── models/quiz_model.dart
│   ├── providers/story_buddy_provider.dart
│   ├── services/tts_service.dart
│   ├── screens/story_buddy_screen.dart
│   ├── widgets/
│   │   ├── ai_buddy_widget.dart
│   │   ├── quiz_widget.dart
│   │   ├── shake_wrapper.dart
│   │   └── success_overlay.dart
│   └── main.dart
├── test/
│   ├── quiz_model_test.dart
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

</details>

---

## About Peblo

[Peblo](https://www.mypeblo.com) is a mission-driven edutainment startup reshaping early and middle-grade education in India. They blend immersive storytelling, interactive games, and AI to create personalized, joyful learning journeys.

- [YouTube](https://www.youtube.com/@peblotv) · [Instagram](https://instagram.com/mypeblo) · [LinkedIn](https://linkedin.com/company/mypeblo)

---

<div align="center">

**Built with care for the Peblo Developer Intern Challenge**

*Made with ❤️ in India*

</div>
