import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

enum TtsStatus { idle, preparing, speaking, paused, completed, error }

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

  String? _lastNarrationText;
  bool _userStopped = false;

  void _bindHandlers() {
    _tts.setCompletionHandler(() {
      if (_userStopped) return;
      _emit(TtsStatus.completed);
    });

    _tts.setErrorHandler((message) {
      _emit(TtsStatus.error);
    });

    _tts.setCancelHandler(() {
      if (_userStopped) {
        _userStopped = false;
        return;
      }
      if (_currentStatus == TtsStatus.speaking) {
        _emit(TtsStatus.idle);
      }
    });

    _tts.setPauseHandler(() {
      _emit(TtsStatus.paused);
    });

    _tts.setContinueHandler(() {
      _emit(TtsStatus.speaking);
    });
  }

  void _emit(TtsStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<void> speak(String text) async {
    _lastNarrationText = text;
    _userStopped = false;
    _emit(TtsStatus.preparing);

    try {
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.42);
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

      if (result != 1 && _currentStatus == TtsStatus.speaking) {
        _emit(TtsStatus.error);
      }
    } catch (_) {
      _emit(TtsStatus.error);
    }
  }

  Future<void> pause() async {
    if (_currentStatus != TtsStatus.speaking) return;

    final result = await _tts.pause();
    if (result == 1) {
      _emit(TtsStatus.paused);
    }
  }

  Future<void> resume() async {
    if (_currentStatus != TtsStatus.paused || _lastNarrationText == null) {
      return;
    }

    _userStopped = false;
    _emit(TtsStatus.speaking);
    final result = await _tts.speak(_lastNarrationText!);
    if (result != 1 && _currentStatus == TtsStatus.speaking) {
      _emit(TtsStatus.error);
    }
  }

  Future<void> stop() async {
    _userStopped = true;
    _lastNarrationText = null;
    await _tts.stop();
    _emit(TtsStatus.idle);
  }

  void dispose() {
    _statusController.close();
    _tts.stop();
  }
}
