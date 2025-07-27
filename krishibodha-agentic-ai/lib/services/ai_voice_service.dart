import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_ai/firebase_ai.dart';

class AIVoiceService {
  static final AIVoiceService _instance = AIVoiceService._internal();
  factory AIVoiceService() => _instance;
  AIVoiceService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late GenerativeModel _model;
  late ChatSession _chat;

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _lastWords = '';

  // Stream controllers for state management
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _speakingController =
      StreamController<bool>.broadcast();
  final StreamController<String> _transcriptionController =
      StreamController<String>.broadcast();
  final StreamController<String> _responseController =
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<bool> get isListeningStream => _listeningController.stream;
  Stream<bool> get isSpeakingStream => _speakingController.stream;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get responseStream => _responseController.stream;

  // Getters for current state
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechEnabled => _speechEnabled;
  String get lastWords => _lastWords;

  Future<void> initialize() async {
    try {
      debugPrint('Starting AIVoiceService initialization...');

      // Initialize Firebase AI
      final generationConfig = GenerationConfig(
        responseMimeType: 'text/plain',
        temperature: 0.7,
        maxOutputTokens: 1000,
      );

      debugPrint('Creating Firebase AI model...');
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: generationConfig,
        systemInstruction: Content('system', [
          TextPart(
'''आप एक दोस्ताना किसान सहायक हैं जो किसान पंजीकरण की प्रक्रिया में मदद करते हैं। हमेशा हिंदी में जवाब दें। आपका नाम "किसान मित्र" है। छोटे, स्पष्ट और दोस्ताना उत्तर दें।

किसान पंजीकरण के दौरान आप निम्नलिखित जानकारी एकत्र करेंगे:
1. किसान का नाम
2. किसान का स्थान (अक्षांश/देशांतर या पता)
3. किसान का विवरण (अनुभव, खेती की जानकारी)
4. किसान के लक्ष्य (क्या हासिल करना चाहते हैं)
5. किसान की फसलें (कौन सी फसलें उगाते हैं)
6. आधार नंबर

महत्वपूर्ण निर्देश:
- केवल सादा टेक्स्ट में जवाब दें
- कोई मार्कडाउन फॉर्मेटिंग का उपयोग न करें जैसे **bold**, *italic*, या # headings
- कोई विशेष चिह्न या formatting marks का उपयोग न करें
- सरल, साफ हिंदी भाषा में जवाब दें
- कभी भी * (asterisk) चिह्न का उपयोग न करें
- कोई भी formatting या emphasis के लिए विशेष चिह्न न लगाएं
- केवल सामान्य हिंदी शब्दों और वाक्यों का उपयोग करें
- प्रोत्साहित करने वाले और सहायक शब्द इस्तेमाल करें
- किसान को आराम से महसूस कराएं''',
          ),
        ]),
      );

      debugPrint('Starting chat session...');
      _chat = _model.startChat();

      // Test Firebase AI connection with a simple message
      debugPrint('Testing Firebase AI connection...');
      try {
        final testMessage = Content('user', [TextPart('नमस्ते')]);
        final testResponse = await _chat
            .sendMessage(testMessage)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception(
                  'Firebase AI connection timeout after 10 seconds',
                );
              },
            );
        debugPrint('Firebase AI test successful: ${testResponse.text}');
      } catch (e) {
        debugPrint('Firebase AI test failed: $e');
        // Don't throw here - continue with initialization
        // The connection might work later even if test fails
        debugPrint('Continuing with initialization despite test failure...');
      }

      // Initialize Speech-to-Text
      debugPrint('Initializing Speech-to-Text...');
      await _initSpeechToText();

      // Initialize Text-to-Speech
      debugPrint('Initializing Text-to-Speech...');
      await _initTextToSpeech();

      debugPrint('AIVoiceService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing AIVoiceService: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _initSpeechToText() async {
    try {
      // Request microphone permission
      final microphonePermission = await Permission.microphone.request();
      if (microphonePermission != PermissionStatus.granted) {
        throw Exception('Microphone permission denied');
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: ${error.errorMsg}');
          _stopListening();
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            _stopListening();
          }
        },
      );

      debugPrint('Speech recognition initialized: $_speechEnabled');
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      _speechEnabled = false;
    }
  }

  Future<void> _initTextToSpeech() async {
    try {
      await _flutterTts.setLanguage('hi-IN'); // Hindi language
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set up TTS callbacks
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _speakingController.add(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _speakingController.add(false);
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint('TTS Error: $message');
        _isSpeaking = false;
        _speakingController.add(false);
      });

      // For Android, set the speech engine if available
      if (Platform.isAndroid) {
        await _flutterTts.setEngine('com.google.android.tts');
      }

      debugPrint('Text-to-Speech initialized');
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
    }
  }

  Future<void> startListening() async {
    if (!_speechEnabled || _isListening) return;

    try {
      _lastWords = '';
      _transcriptionController.add('');

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'hi-IN', // Hindi locale
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      _isListening = true;
      _listeningController.add(true);
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speechToText.stop();
    _stopListening();
  }

  void _stopListening() {
    _isListening = false;
    _listeningController.add(false);

    // Process the final transcription
    if (_lastWords.isNotEmpty) {
      _processUserInput(_lastWords);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    _transcriptionController.add(_lastWords);

    debugPrint('Speech result: $_lastWords (confidence: ${result.confidence})');
  }

  Future<void> _processUserInput(String userInput) async {
    if (userInput.trim().isEmpty) return;

    try {
      debugPrint('Processing user input: $userInput');

      final message = Content('user', [TextPart(userInput)]);

      final response = await _chat.sendMessage(message);
      String responseText =
          response.text ?? 'माफ करें, मैं आपकी बात समझ नहीं पाया।';

      // Clean up any markdown formatting that might still appear
      responseText = _cleanMarkdownFormatting(responseText);

      debugPrint('AI Response: $responseText');
      _responseController.add(responseText);

      // Speak the response
      await speak(responseText);
    } catch (e, stackTrace) {
      debugPrint('Error processing user input: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorMessage;

      // Provide specific error messages based on error type
      if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        errorMessage =
            'इंटरनेट कनेक्शन की समस्या है। कृपया अपना इंटरनेट चेक करें।';
      } else if (e.toString().contains('firebase') ||
          e.toString().contains('auth')) {
        errorMessage = 'Firebase सेवा में समस्या है। कृपया बाद में कोशिश करें।';
      } else if (e.toString().contains('quota') ||
          e.toString().contains('limit')) {
        errorMessage = 'सेवा की सीमा पूरी हो गई है। कृपया बाद में कोशिश करें।';
      } else {
        errorMessage =
            'माफ करें, कुछ तकनीकी समस्या है। कृपया दोबारा कोशिश करें।';
      }

      _responseController.add(errorMessage);
      await speak(errorMessage);
    }
  }

  /// Clean markdown formatting from AI responses
  String _cleanMarkdownFormatting(String text) {
    // Remove bold formatting **text**
    text = text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');

    // Remove italic formatting *text*
    text = text.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');

    // Remove any remaining asterisks completely
    text = text.replaceAll('*', '');

    // Remove heading markers #
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');

    // Remove backticks `code`
    text = text.replaceAll(RegExp(r'`(.*?)`'), r'$1');

    // Clean up any remaining markdown-like patterns
    text = text.replaceAll(RegExp(r'_{2,}'), '');
    text = text.replaceAll(RegExp(r'\[.*?\]'), '');
    text = text.replaceAll(RegExp(r'\(.*?\)'), '');

    // Clean up excessive spaces and newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.replaceAll(RegExp(r' {2,}'), ' ');

    return text.trim();
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      // Stop any ongoing speech
      await _flutterTts.stop();

      // Speak the text
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      _speakingController.add(false);
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Process the input using the same method as voice input
    await _processUserInput(text);
  }

  /// Debug method to test Firebase AI connectivity
  Future<String> testFirebaseAI() async {
    try {
      debugPrint('Testing Firebase AI with simple query...');

      final testMessage = Content('user', [TextPart('हैलो')]);
      final response = await _chat
          .sendMessage(testMessage)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout after 15 seconds');
            },
          );

      String responseText = response.text ?? 'No response received';
      responseText = _cleanMarkdownFormatting(responseText);
      debugPrint('Test successful. Response: $responseText');
      return 'SUCCESS: $responseText';
    } catch (e, stackTrace) {
      debugPrint('Firebase AI test failed: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorDetails = 'ERROR: $e';

      // Add specific error information
      if (e.toString().contains('timeout')) {
        errorDetails +=
            '\n\nThis might be due to:\n'
            '• Network connectivity issues\n'
            '• Firebase project configuration\n'
            '• API key or service account issues';
      } else if (e.toString().contains('permission') ||
          e.toString().contains('auth')) {
        errorDetails +=
            '\n\nThis might be due to:\n'
            '• Firebase AI not enabled in project\n'
            '• API key permissions\n'
            '• Service account configuration';
      }

      return errorDetails;
    }
  }

  void dispose() {
    _listeningController.close();
    _speakingController.close();
    _transcriptionController.close();
    _responseController.close();
    _speechToText.cancel();
    _flutterTts.stop();
  }
}
