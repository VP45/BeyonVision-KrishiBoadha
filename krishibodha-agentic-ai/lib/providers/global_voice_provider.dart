import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/ai_voice_service.dart';

// Global voice state provider for app-wide voice functionality
class GlobalVoiceState {
  final bool isInitialized;
  final bool isListening;
  final bool isSpeaking;
  final String currentTranscription;
  final String lastResponse;
  final bool voiceEnabled;

  const GlobalVoiceState({
    this.isInitialized = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.currentTranscription = '',
    this.lastResponse = '',
    this.voiceEnabled = true,
  });

  GlobalVoiceState copyWith({
    bool? isInitialized,
    bool? isListening,
    bool? isSpeaking,
    String? currentTranscription,
    String? lastResponse,
    bool? voiceEnabled,
  }) {
    return GlobalVoiceState(
      isInitialized: isInitialized ?? this.isInitialized,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentTranscription: currentTranscription ?? this.currentTranscription,
      lastResponse: lastResponse ?? this.lastResponse,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    );
  }
}

class GlobalVoiceNotifier extends StateNotifier<GlobalVoiceState> {
  final AIVoiceService _voiceService;

  GlobalVoiceNotifier(this._voiceService) : super(const GlobalVoiceState()) {
    _initializeVoiceService();
    _listenToVoiceStreams();
  }

  Future<void> _initializeVoiceService() async {
    try {
      debugPrint('Initializing global voice service...');
      await _voiceService.initialize();
      state = state.copyWith(isInitialized: true);
      debugPrint('Global voice service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize global voice service: $e');
      state = state.copyWith(isInitialized: false);
    }
  }

  void _listenToVoiceStreams() {
    // Listen to voice service streams and update state
    _voiceService.isListeningStream.listen((isListening) {
      state = state.copyWith(isListening: isListening);
    });

    _voiceService.isSpeakingStream.listen((isSpeaking) {
      state = state.copyWith(isSpeaking: isSpeaking);
    });

    _voiceService.transcriptionStream.listen((transcription) {
      state = state.copyWith(currentTranscription: transcription);
    });

    _voiceService.responseStream.listen((response) {
      state = state.copyWith(lastResponse: response);
    });
  }

  // Voice interaction methods
  Future<void> startListening() async {
    if (!state.isInitialized || !state.voiceEnabled) return;

    try {
      await _voiceService.startListening();
    } catch (e) {
      debugPrint('Error starting voice listening: $e');
    }
  }

  Future<void> stopListening() async {
    if (!state.isInitialized) return;

    try {
      await _voiceService.stopListening();
    } catch (e) {
      debugPrint('Error stopping voice listening: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!state.isInitialized || !state.voiceEnabled) return;

    try {
      await _voiceService.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  Future<void> stopSpeaking() async {
    if (!state.isInitialized) return;

    try {
      await _voiceService.stopSpeaking();
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (!state.isInitialized || !state.voiceEnabled) return;

    try {
      await _voiceService.sendTextMessage(text);
    } catch (e) {
      debugPrint('Error sending text message: $e');
    }
  }

  void toggleVoice() {
    state = state.copyWith(voiceEnabled: !state.voiceEnabled);
    if (!state.voiceEnabled) {
      stopListening();
      stopSpeaking();
    }
  }

  // Context-specific voice prompts
  Future<void> welcomeUser() async {
    await speak(
      'नमस्ते! मैं आपका किसान मित्र हूँ। आज मैं आपकी पूरी पंजीकरण प्रक्रिया में मदद करूँगा।',
    );
  }

  Future<void> guideLanguageSelection() async {
    await speak(
      'कृपया अपनी भाषा चुनें। आप Hindi, English या अपनी क्षेत्रीय भाषा का चयन कर सकते हैं।',
    );
  }

  Future<void> guideFarmerRegistration() async {
    await speak(
      'अब मैं आपकी व्यक्तिगत जानकारी लूँगा। आप बोलकर भी जानकारी दे सकते हैं या टाइप कर सकते हैं।',
    );
  }

  Future<void> guideMapSelection() async {
    await speak(
      'अब आपको अपने खेत की सीमा मैप पर दिखानी होगी। स्क्रीन पर टैप करके अपने खेत के कोने-कोने को चिह्नित करें।',
    );
  }

  Future<void> congratulateCompletion() async {
    await speak(
      'बधाई हो! आपका पंजीकरण सफलतापूर्वक पूरा हो गया है। अब आप सभी सुविधाओं का उपयोग कर सकते हैं।',
    );
  }

  Future<void> provideFieldGuidance(String fieldName) async {
    String guidance = '';
    switch (fieldName.toLowerCase()) {
      case 'name':
        guidance = 'कृपया अपना पूरा नाम बताएं';
        break;
      case 'location':
        guidance = 'अपना स्थान या पता बताएं';
        break;
      case 'experience':
        guidance = 'अपना खेती का अनुभव बताएं';
        break;
      case 'goals':
        guidance = 'आप खेती में क्या लक्ष्य हासिल करना चाहते हैं';
        break;
      case 'crops':
        guidance = 'आप कौन सी फसलें उगाते हैं';
        break;
      case 'aadhar':
        guidance = 'अपना आधार नंबर बताएं';
        break;
      default:
        guidance = 'कृपया $fieldName की जानकारी दें';
    }
    await speak(guidance);
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }
}

// Global provider for voice functionality
final globalVoiceProvider =
    StateNotifierProvider<GlobalVoiceNotifier, GlobalVoiceState>((ref) {
      final voiceService = AIVoiceService();
      return GlobalVoiceNotifier(voiceService);
    });

// Convenience providers for specific states
final isVoiceInitializedProvider = Provider<bool>((ref) {
  return ref.watch(globalVoiceProvider).isInitialized;
});

final isVoiceListeningProvider = Provider<bool>((ref) {
  return ref.watch(globalVoiceProvider).isListening;
});

final isVoiceSpeakingProvider = Provider<bool>((ref) {
  return ref.watch(globalVoiceProvider).isSpeaking;
});

final voiceTranscriptionProvider = Provider<String>((ref) {
  return ref.watch(globalVoiceProvider).currentTranscription;
});

final voiceEnabledProvider = Provider<bool>((ref) {
  return ref.watch(globalVoiceProvider).voiceEnabled;
});
