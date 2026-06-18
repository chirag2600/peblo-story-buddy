import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

enum TtsStatus { idle, preparing, speaking, completed, error }

/// Thin wrapper around the device TTS engine with completion callbacks.
class TtsService {
  TtsService() {
    _tts = FlutterTts();
    _bindHandlers();
  }

  late final FlutterTts _tts;
  final _statusController = StreamController<TtsStatus>.broadcast();

  Stream<TtsStatus> get statusStream => _statusController.stream;
  TtsStatus _currentStatus = TtsStatus.idle;
  TtsStatus get currentStatus => _currentStatus;

  void _bindHandlers() {
    _tts.setCompletionHandler(() {
      _emit(TtsStatus.completed);
    });

    _tts.setErrorHandler((message) {
      _emit(TtsStatus.error);
    });

    _tts.setCancelHandler(() {
      if (_currentStatus == TtsStatus.speaking) {
        _emit(TtsStatus.idle);
      }
    });
  }

  void _emit(TtsStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> speak(String text) async {
    _emit(TtsStatus.preparing);

    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);

      final languages = await _tts.getLanguages;
      if (languages is List && languages.isNotEmpty) {
        final hasIndianEnglish = languages.any(
          (lang) => lang.toString().toLowerCase().contains('en-in'),
        );
        if (!hasIndianEnglish) {
          await _tts.setLanguage('en-US');
        }
      }

      _emit(TtsStatus.speaking);
      final result = await _tts.speak(text);

      if (result != 1) {
        _emit(TtsStatus.error);
      }
    } catch (_) {
      _emit(TtsStatus.error);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _emit(TtsStatus.idle);
  }

  void dispose() {
    _statusController.close();
    _tts.stop();
  }
}
