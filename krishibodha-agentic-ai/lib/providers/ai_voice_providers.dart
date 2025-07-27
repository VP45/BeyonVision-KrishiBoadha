import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_voice_service.dart';

// Provider for the AI Voice Service instance
final aiVoiceServiceProvider = Provider<AIVoiceService>((ref) {
  return AIVoiceService();
});

// Provider for listening state
final isListeningProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(aiVoiceServiceProvider);
  return service.isListeningStream;
});

// Provider for speaking state
final isSpeakingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(aiVoiceServiceProvider);
  return service.isSpeakingStream;
});

// Provider for transcription
final transcriptionProvider = StreamProvider<String>((ref) {
  final service = ref.watch(aiVoiceServiceProvider);
  return service.transcriptionStream;
});

// Provider for AI responses
final responseProvider = StreamProvider<String>((ref) {
  final service = ref.watch(aiVoiceServiceProvider);
  return service.responseStream;
});

// Provider for service initialization
final serviceInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(aiVoiceServiceProvider);
  await service.initialize();
});
