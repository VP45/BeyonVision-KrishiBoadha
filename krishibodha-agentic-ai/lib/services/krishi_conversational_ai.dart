import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/services/ai_voice_service.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider for the Krishi Conversational AI
final krishiConversationalAIProvider = Provider<KrishiConversationalAI>((ref) {
  return KrishiConversationalAI();
});

// Farmer profile data model
class FarmerProfileData {
  final String? name;
  final String? location;
  final String? description;
  final String? goals;
  final List<String> crops;
  final String? aadharNumber;
  final String? phoneNumber;
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? experienceYears;
  final double? farmSize;
  final String? farmingType;

  FarmerProfileData({
    this.name,
    this.location,
    this.description,
    this.goals,
    this.crops = const [],
    this.aadharNumber,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.address,
    this.experienceYears,
    this.farmSize,
    this.farmingType,
  });

  bool get isComplete {
    return name != null &&
        name!.isNotEmpty &&
        location != null &&
        location!.isNotEmpty &&
        crops.isNotEmpty &&
        description != null &&
        description!.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'goals': goals,
      'crops': crops,
      'aadharNumber': aadharNumber,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'experienceYears': experienceYears,
      'farmSize': farmSize,
      'farmingType': farmingType,
      'createdAt': FieldValue.serverTimestamp(),
      'isComplete': isComplete,
    };
  }

  FarmerProfileData copyWith({
    String? name,
    String? location,
    String? description,
    String? goals,
    List<String>? crops,
    String? aadharNumber,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    String? address,
    int? experienceYears,
    double? farmSize,
    String? farmingType,
  }) {
    return FarmerProfileData(
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      goals: goals ?? this.goals,
      crops: crops ?? this.crops,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      experienceYears: experienceYears ?? this.experienceYears,
      farmSize: farmSize ?? this.farmSize,
      farmingType: farmingType ?? this.farmingType,
    );
  }
}

enum OnboardingStage {
  greeting,
  nameCollection,
  locationCollection,
  experienceCollection,
  cropsCollection,
  goalsCollection,
  contactCollection,
  confirmation,
  profileCreation,
  completed,
}

class KrishiConversationalAI {
  static final KrishiConversationalAI _instance =
      KrishiConversationalAI._internal();
  factory KrishiConversationalAI() => _instance;
  KrishiConversationalAI._internal();

  final AIVoiceService _voiceService = AIVoiceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late GenerativeModel _model;
  late ChatSession _chat;

  FarmerProfileData _currentProfile = FarmerProfileData();
  OnboardingStage _currentStage = OnboardingStage.greeting;
  String _currentLanguage = 'hi';
  bool _isInitialized = false;
  bool _isOnboarding = false;
  bool _isSpeaking = false;
  bool _isProcessingResponse = false;
  bool _isWaitingForResponse = false;
  String _lastProcessedInput = '';
  DateTime? _lastSpeechEndTime;
  Timer? _responseTimeoutTimer;
  Timer? _autoListenTimer;

  // Stream controllers
  final StreamController<FarmerProfileData> _profileController =
      StreamController<FarmerProfileData>.broadcast();
  final StreamController<OnboardingStage> _stageController =
      StreamController<OnboardingStage>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();

  // Getters for streams
  Stream<FarmerProfileData> get profileStream => _profileController.stream;
  Stream<OnboardingStage> get stageStream => _stageController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;

  // Getters for current state
  FarmerProfileData get currentProfile => _currentProfile;
  OnboardingStage get currentStage => _currentStage;
  bool get isOnboarding => _isOnboarding;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String language) async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing Krishi Conversational AI...');
      _currentLanguage = language;

      // Initialize voice service first
      await _voiceService.initialize();

      // Initialize Gemini AI with conversational context
      final generationConfig = GenerationConfig(
        responseMimeType: 'text/plain',
        temperature: 0.8,
        maxOutputTokens: 1000,
      );

      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: generationConfig,
        systemInstruction: Content('system', [TextPart(_getSystemPrompt())]),
      );

      _chat = _model.startChat();

      // Listen to voice service streams with enhanced handling
      _voiceService.transcriptionStream.listen(_handleUserSpeech);
      _voiceService.responseStream.listen(_handleAIResponse);
      _voiceService.isListeningStream.listen((listening) {
        _listeningController.add(listening);

        // If user starts speaking while AI is talking, interrupt the AI
        if (listening && _isSpeaking) {
          _voiceService.stopSpeaking();
        }
      });
      _voiceService.isSpeakingStream.listen((speaking) {
        _isSpeaking = speaking;
        if (!speaking) {
          _lastSpeechEndTime = DateTime.now();
          // Auto-start listening after AI finishes speaking
          _scheduleAutoListen();
        }
      });

      _isInitialized = true;
      debugPrint('Krishi Conversational AI initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Krishi Conversational AI: $e');
      rethrow;
    }
  }

  String _getSystemPrompt() {
    final Map<String, String> prompts = {
      'hi':
          '''आप कृषि हैं, एक दोस्ताना और बुद्धिमान किसान सहायक। आपका काम है किसानों की मदद करना और उनकी प्रोफाइल बनाना।

महत्वपूर्ण निर्देश:
- केवल सादा हिंदी में जवाब दें, कोई मार्कडाउन फॉर्मेटिंग नहीं
- कोई * या # का इस्तेमाल न करें
- बहुत छोटे, स्पष्ट और दोस्ताना उत्तर दें (अधिकतम 1-2 वाक्य)
- हमेशा प्रोत्साहित करें और सम्मान से बात करें
- जरूरी जानकारी को याद रखें और वापस न पूछें
- यदि किसान ने पहले से जानकारी दी है तो "धन्यवाद" कहें और अगला सवाल पूछें
- संवाद को प्राकृतिक और तेज़ रखें

आप किसान की निम्नलिखित जानकारी एकत्र करेंगे:
1. नाम
2. स्थान/पता 
3. खेती का अनुभव (कितने साल)
4. कौन सी फसलें उगाते हैं
5. खेती के लक्ष्य
6. संपर्क जानकारी (फोन नंबर)

हर बार केवल एक सवाल पूछें। जानकारी मिलने पर तुरंत अगला सवाल पूछें। लंबे जवाब न दें।''',

      'en':
          '''You are Krishi, a friendly and intelligent farmer assistant. Your job is to help farmers and create their profiles.

Important instructions:
- Reply only in simple English, no markdown formatting
- Don't use * or # symbols
- Give short, clear and friendly answers
- Always encourage and speak respectfully
- Remember important information and don't ask again

You will collect the following farmer information:
1. Name
2. Location/Address
3. Farming experience (how many years)
4. What crops they grow
5. Farming goals
6. Contact information (phone number)
7. Farm size (if known)

Ask one question at a time and wait for the farmer's response. Be patient and make the farmer feel comfortable.''',
    };

    return prompts[_currentLanguage] ?? prompts['hi']!;
  }

  Future<void> startOnboarding() async {
    if (!_isInitialized) {
      throw Exception('Krishi AI not initialized');
    }

    try {
      _isOnboarding = true;
      _currentStage = OnboardingStage.greeting;
      _currentProfile = FarmerProfileData();
      _isWaitingForResponse = false;

      _stageController.add(_currentStage);
      _profileController.add(_currentProfile);

      // Start with greeting and auto-flow
      await _handleGreetingFlow();
    } catch (e) {
      debugPrint('Error starting onboarding: $e');
      rethrow;
    }
  }

  Future<void> _handleGreetingFlow() async {
    final greetingMessage = _getGreetingMessage();
    await _voiceService.speak(greetingMessage);

    // Wait for greeting to complete, then move to name collection
    await Future.delayed(const Duration(milliseconds: 2000));
    await _moveToNextStageWithFlow();
  }

  void _scheduleAutoListen() {
    _autoListenTimer?.cancel();

    if (_isOnboarding &&
        !_isWaitingForResponse &&
        _currentStage != OnboardingStage.completed) {
      _autoListenTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!_isSpeaking && _isOnboarding && !_isProcessingResponse) {
          startListening();
        }
      });
    }
  }

  String _getGreetingMessage() {
    final Map<String, String> greetings = {
      'hi':
          'नमस्ते! मैं कृषि हूं, आपका किसान मित्र। मैं आपकी मदद करने के लिए यहां हूं। आइए मिलकर आपकी प्रोफाइल बनाते हैं।',
      'en':
          'Hello! I am Krishi, your farmer friend. I am here to help you. Let\'s create your profile together.',
    };
    return greetings[_currentLanguage] ?? greetings['hi']!;
  }

  Future<void> _handleUserSpeech(String transcription) async {
    if (!_isOnboarding || transcription.trim().isEmpty) return;

    // Prevent processing AI's own speech or duplicate inputs
    if (_isSpeaking || _isProcessingResponse) {
      debugPrint(
        'Ignoring input while AI is speaking or processing: $transcription',
      );
      return;
    }

    // Check if we just finished speaking (give 2 second buffer)
    if (_lastSpeechEndTime != null) {
      final timeSinceLastSpeech = DateTime.now().difference(
        _lastSpeechEndTime!,
      );
      if (timeSinceLastSpeech.inSeconds < 2) {
        debugPrint('Ignoring input too soon after AI speech: $transcription');
        return;
      }
    }

    // Prevent duplicate processing of same input
    if (_lastProcessedInput == transcription.trim()) {
      debugPrint('Ignoring duplicate input: $transcription');
      return;
    }

    _lastProcessedInput = transcription.trim();
    _isProcessingResponse = true;
    _responseTimeoutTimer?.cancel(); // Cancel timeout as we got response

    try {
      debugPrint('Processing user speech: $transcription');

      // Use direct pattern matching instead of AI for efficiency
      // and to avoid quota issues
      await _processAIResponseWithFlow(transcription, '');
    } catch (e) {
      debugPrint('Error processing speech: $e');
      await _voiceService.speak(
        'माफ करें, कुछ तकनीकी समस्या है। कृपया दोबारा कहें।',
      );

      // Restart listening after error
      if (_isWaitingForResponse) {
        await Future.delayed(const Duration(milliseconds: 1000));
        await startListening();
      }
    } finally {
      _isProcessingResponse = false;
    }
  }

  // Enhanced AI response processing with conversation flow
  Future<void> _processAIResponseWithFlow(
    String userInput,
    String aiResponse,
  ) async {
    // Extract information from user input based on current stage
    bool informationExtracted = false;

    switch (_currentStage) {
      case OnboardingStage.nameCollection:
        final name = _extractNameDirect(userInput);
        if (name != null) {
          _currentProfile = _currentProfile.copyWith(name: name);
          informationExtracted = true;
        }
        break;
      case OnboardingStage.locationCollection:
        final location = _extractLocationDirect(userInput);
        if (location != null) {
          _currentProfile = _currentProfile.copyWith(location: location);
          informationExtracted = true;
        }
        break;
      case OnboardingStage.experienceCollection:
        final experience = _extractExperienceDirect(userInput);
        if (experience != null) {
          _currentProfile = _currentProfile.copyWith(
            experienceYears: experience,
          );
          informationExtracted = true;
        }
        break;
      case OnboardingStage.cropsCollection:
        final crops = _extractCropsDirect(userInput);
        if (crops.isNotEmpty) {
          _currentProfile = _currentProfile.copyWith(crops: crops);
          informationExtracted = true;
        }
        break;
      case OnboardingStage.goalsCollection:
        final goals = _extractGoalsDirect(userInput);
        if (goals != null) {
          // Create a description from collected data
          final description = _generateProfileDescription();
          _currentProfile = _currentProfile.copyWith(
            goals: goals,
            description: description,
          );
          informationExtracted = true;
        }
        break;
      case OnboardingStage.contactCollection:
        final phone = _extractPhoneNumberDirect(userInput);
        if (phone != null) {
          _currentProfile = _currentProfile.copyWith(phoneNumber: phone);
          informationExtracted = true;
        }
        break;
      case OnboardingStage.confirmation:
        await _handleConfirmationResponse(userInput);
        return;
      default:
        break;
    }

    _profileController.add(_currentProfile);

    if (informationExtracted) {
      // Information successfully extracted, acknowledge and move to next stage
      final acknowledgment = _getStageAcknowledgment();
      await _voiceService.speak(acknowledgment);

      _isWaitingForResponse = false;

      // Wait a moment then move to next stage
      await Future.delayed(const Duration(milliseconds: 1500));
      await _moveToNextStageWithFlow();
    } else {
      // Information not extracted, provide helpful prompt
      final helpMessage = _getHelpMessageForStage();
      await _voiceService.speak(helpMessage);

      // Continue waiting for proper response
      await Future.delayed(const Duration(milliseconds: 1000));
      await startListening();

      // Reset timeout for clarification
      _responseTimeoutTimer?.cancel();
      _responseTimeoutTimer = Timer(const Duration(seconds: 15), () async {
        if (_isWaitingForResponse) {
          await _handleResponseTimeout();
        }
      });
    }
  }

  String _getStageAcknowledgment() {
    switch (_currentStage) {
      case OnboardingStage.nameCollection:
        return 'धन्यवाद ${_currentProfile.name}!';
      case OnboardingStage.locationCollection:
        return 'समझ गया, ${_currentProfile.location}।';
      case OnboardingStage.experienceCollection:
        return '${_currentProfile.experienceYears} साल का अनुभव, बहुत अच्छा!';
      case OnboardingStage.cropsCollection:
        return 'अच्छी फसलें हैं।';
      case OnboardingStage.goalsCollection:
        return 'बेहतरीन लक्ष्य हैं।';
      case OnboardingStage.contactCollection:
        return 'संपर्क जानकारी मिल गई।';
      default:
        return 'समझ गया।';
    }
  }

  Future<void> _handleConfirmationResponse(String userInput) async {
    final input = userInput.toLowerCase();

    if (input.contains('हां') ||
        input.contains('सही') ||
        input.contains('ठीक') ||
        input.contains('yes') ||
        input.contains('correct')) {
      // Profile confirmed, save it
      _isWaitingForResponse = false;
      await _voiceService.speak('बहुत अच्छा! आपकी जानकारी सेव हो गई है।');
      await _saveProfile();
    } else if (input.contains('नहीं') ||
        input.contains('गलत') ||
        input.contains('बदल') ||
        input.contains('no') ||
        input.contains('wrong') ||
        input.contains('change')) {
      // User wants to make changes
      _isWaitingForResponse = false;
      await _voiceService.speak(
        'कोई बात नहीं। आप कौन सी जानकारी बदलना चाहते हैं?',
      );

      // Handle editing flow (to be implemented)
      await Future.delayed(const Duration(milliseconds: 1000));
      await startListening();
    } else {
      // Unclear response, ask again
      await _voiceService.speak(
        'कृपया स्पष्ट रूप से बताएं - क्या यह जानकारी सही है?',
      );
      await Future.delayed(const Duration(milliseconds: 1000));
      await startListening();
    }
  }

  // Direct pattern matching methods (no AI dependency)
  String? _extractNameDirect(String input) {
    final cleanInput = input.toLowerCase().trim();

    // Remove common prefixes
    final prefixes = ['मेरा नाम', 'मैं', 'my name is', 'i am', 'name is'];
    String nameText = cleanInput;

    for (final prefix in prefixes) {
      if (nameText.contains(prefix)) {
        nameText = nameText.replaceAll(prefix, '').trim();
      }
    }

    // Extract potential name (first meaningful word after cleaning)
    final words = nameText.split(' ').where((word) => word.isNotEmpty).toList();

    if (words.isNotEmpty) {
      // Take first 1-2 words as name
      final name = words.take(2).join(' ').trim();
      if (name.length > 1) {
        return name;
      }
    }

    return null;
  }

  String? _extractLocationDirect(String input) {
    final cleanInput = input.trim();

    // Remove common prefixes
    final prefixes = [
      'मैं रहता हूं',
      'मैं',
      'i live in',
      'from',
      'रहता हूं',
      'में रहता हूं',
    ];
    String locationText = cleanInput;

    for (final prefix in prefixes) {
      locationText = locationText.replaceAll(prefix, '').trim();
    }

    if (locationText.length > 2) {
      return locationText;
    }

    return null;
  }

  int? _extractExperienceDirect(String input) {
    final cleanInput = input.toLowerCase();

    // Look for numbers in the text
    final numberRegex = RegExp(r'\d+');
    final matches = numberRegex.allMatches(cleanInput);

    for (final match in matches) {
      final number = int.tryParse(match.group(0) ?? '');
      if (number != null && number >= 0 && number <= 100) {
        return number;
      }
    }

    // Look for written numbers in Hindi
    final hindiNumbers = {
      'एक': 1,
      'दो': 2,
      'तीन': 3,
      'चार': 4,
      'पांच': 5,
      'छह': 6,
      'सात': 7,
      'आठ': 8,
      'नौ': 9,
      'दस': 10,
      'बीस': 20,
      'तीस': 30,
      'चालीस': 40,
      'पचास': 50,
    };

    for (final entry in hindiNumbers.entries) {
      if (cleanInput.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  List<String> _extractCropsDirect(String input) {
    final cleanInput = input.toLowerCase();
    final crops = <String>[];

    // Common crop names in Hindi and English
    final cropMap = {
      'धान': 'धान',
      'चावल': 'धान',
      'rice': 'धान',
      'गेहूं': 'गेहूं',
      'wheat': 'गेहूं',
      'मक्का': 'मक्का',
      'corn': 'मक्का',
      'maize': 'मक्का',
      'बाजरा': 'बाजरा',
      'millet': 'बाजरा',
      'ज्वार': 'ज्वार',
      'sorghum': 'ज्वार',
      'दाल': 'दाल',
      'lentils': 'दाल',
      'pulses': 'दाल',
      'सरसों': 'सरसों',
      'mustard': 'सरसों',
      'आलू': 'आलू',
      'potato': 'आलू',
      'प्याज': 'प्याज',
      'onion': 'प्याज',
      'टमाटर': 'टमाटर',
      'tomato': 'टमाटर',
      'गन्ना': 'गन्ना',
      'sugarcane': 'गन्ना',
      'कपास': 'कपास',
      'cotton': 'कपास',
    };

    for (final entry in cropMap.entries) {
      if (cleanInput.contains(entry.key)) {
        if (!crops.contains(entry.value)) {
          crops.add(entry.value);
        }
      }
    }

    return crops;
  }

  String? _extractGoalsDirect(String input) {
    final cleanInput = input.trim();

    if (cleanInput.length > 5) {
      return cleanInput;
    }

    return null;
  }

  String? _extractPhoneNumberDirect(String input) {
    final cleanInput = input.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanInput.length == 10 && cleanInput.startsWith(RegExp(r'[6-9]'))) {
      return cleanInput;
    }

    return null;
  }

  String _getHelpMessageForStage() {
    switch (_currentStage) {
      case OnboardingStage.nameCollection:
        return 'कृपया अपना नाम बताएं। जैसे "मेरा नाम राम है"';
      case OnboardingStage.locationCollection:
        return 'आप कहां रहते हैं? अपना गांव या शहर का नाम बताएं।';
      case OnboardingStage.experienceCollection:
        return 'आपको कितने साल का खेती का अनुभव है? संख्या में बताएं।';
      case OnboardingStage.cropsCollection:
        return 'आप कौन सी फसलें उगाते हैं? जैसे गेहूं, धान, मक्का आदि।';
      case OnboardingStage.goalsCollection:
        return 'खेती में आपका क्या लक्ष्य है? आप क्या चाहते हैं?';
      case OnboardingStage.contactCollection:
        return 'आपका 10 अंकों का फोन नंबर क्या है?';
      default:
        return 'कृपया दोबारा कहें।';
    }
  }

  String _buildContextPrompt(String userInput) {
    final stageContext = _getStageContext();
    final profileContext = _getProfileContext();

    return '''वर्तमान स्थिति: $stageContext

उपयोगकर्ता ने कहा: "$userInput"

वर्तमान प्रोफाइल: $profileContext

कृपया उपयोगकर्ता के इनपुट को समझें और उचित जवाब दें। यदि जानकारी मिली है तो उसे स्वीकार करें और अगला सवाल पूछें।''';
  }

  String _getStageContext() {
    switch (_currentStage) {
      case OnboardingStage.greeting:
        return 'अभी greeting हो रही है';
      case OnboardingStage.nameCollection:
        return 'किसान का नाम पूछ रहे हैं';
      case OnboardingStage.locationCollection:
        return 'किसान का स्थान/पता पूछ रहे हैं';
      case OnboardingStage.experienceCollection:
        return 'खेती का अनुभव पूछ रहे हैं';
      case OnboardingStage.cropsCollection:
        return 'कौन सी फसलें उगाते हैं पूछ रहे हैं';
      case OnboardingStage.goalsCollection:
        return 'खेती के लक्ष्य पूछ रहे हैं';
      case OnboardingStage.contactCollection:
        return 'संपर्क जानकारी पूछ रहे हैं';
      case OnboardingStage.confirmation:
        return 'जानकारी की पुष्टि कर रहे हैं';
      default:
        return 'सामान्य बातचीत';
    }
  }

  String _getProfileContext() {
    final parts = <String>[];
    if (_currentProfile.name != null) parts.add('नाम: ${_currentProfile.name}');
    if (_currentProfile.location != null)
      parts.add('स्थान: ${_currentProfile.location}');
    if (_currentProfile.experienceYears != null)
      parts.add('अनुभव: ${_currentProfile.experienceYears} साल');
    if (_currentProfile.crops.isNotEmpty)
      parts.add('फसलें: ${_currentProfile.crops.join(", ")}');
    if (_currentProfile.goals != null)
      parts.add('लक्ष्य: ${_currentProfile.goals}');

    return parts.isEmpty ? 'कोई जानकारी नहीं' : parts.join(', ');
  }

  Future<void> _saveProfile() async {
    try {
      _currentStage = OnboardingStage.profileCreation;
      _stageController.add(_currentStage);

      await _voiceService.speak('बहुत अच्छा! आपकी प्रोफाइल बना रहे हैं...');

      // Ensure description is set for completeness
      if (_currentProfile.description == null ||
          _currentProfile.description!.isEmpty) {
        final description = _generateProfileDescription();
        _currentProfile = _currentProfile.copyWith(description: description);
      }

      debugPrint('Profile data before saving: ${_currentProfile.toJson()}');
      debugPrint('Profile isComplete: ${_currentProfile.isComplete}');

      // Save to Firestore
      final docRef = await _firestore
          .collection('farmers')
          .add(_currentProfile.toJson());

      debugPrint('Farmer profile saved with ID: ${docRef.id}');

      _currentStage = OnboardingStage.completed;
      _stageController.add(_currentStage);
      _isOnboarding = false;

      await _voiceService.speak(
        'बधाई हो! आपकी प्रोफाइल सफलतापूर्वक बन गई है। अब आप ऐप का उपयोग कर सकते हैं।',
      );
    } catch (e) {
      debugPrint('Error saving profile: $e');
      await _voiceService.speak(
        'माफ करें, प्रोफाइल सेव करने में समस्या है। कृपया दोबारा कोशिश करें।',
      );
    }
  }

  String _generateProfileDescription() {
    final parts = <String>[];

    if (_currentProfile.name != null && _currentProfile.name!.isNotEmpty) {
      parts.add('किसान ${_currentProfile.name}');
    }

    if (_currentProfile.location != null &&
        _currentProfile.location!.isNotEmpty) {
      parts.add('${_currentProfile.location} से');
    }

    if (_currentProfile.experienceYears != null) {
      parts.add('${_currentProfile.experienceYears} साल का अनुभव');
    }

    if (_currentProfile.crops.isNotEmpty) {
      parts.add('मुख्य फसलें: ${_currentProfile.crops.join(', ')}');
    }

    if (_currentProfile.goals != null && _currentProfile.goals!.isNotEmpty) {
      parts.add('लक्ष्य: ${_currentProfile.goals}');
    }

    return parts.isEmpty ? 'कृषि प्रोफाइल' : parts.join(' - ');
  }

  // Information extraction methods
  String? _extractName(String input) {
    input = input.toLowerCase().trim();

    // Remove common prefixes
    final prefixes = [
      'मेरा नाम',
      'मैं',
      'मुझे',
      'my name is',
      'i am',
      'name is',
    ];
    for (String prefix in prefixes) {
      if (input.contains(prefix)) {
        input = input.replaceAll(prefix, '').trim();
      }
    }

    // Remove common words
    final wordsToRemove = ['है', 'हूं', 'हूँ', 'is', 'am'];
    for (String word in wordsToRemove) {
      input = input.replaceAll(word, '').trim();
    }

    return input.isNotEmpty ? input : null;
  }

  String? _extractLocation(String input) {
    input = input.toLowerCase().trim();

    // Remove common prefixes
    final prefixes = [
      'मैं रहता हूं',
      'मैं',
      'रहता हूं',
      'पता है',
      'i live in',
      'i am from',
    ];
    for (String prefix in prefixes) {
      if (input.contains(prefix)) {
        input = input.replaceAll(prefix, '').trim();
      }
    }

    return input.isNotEmpty ? input : null;
  }

  int? _extractExperience(String input) {
    // Look for numbers in the input
    final numbers =
        RegExp(
          r'\d+',
        ).allMatches(input).map((m) => int.parse(m.group(0)!)).toList();

    if (numbers.isNotEmpty) {
      return numbers.first;
    }

    // Check for written numbers in Hindi
    final Map<String, int> hindiNumbers = {
      'एक': 1,
      'दो': 2,
      'तीन': 3,
      'चार': 4,
      'पांच': 5,
      'पाँच': 5,
      'छह': 6,
      'सात': 7,
      'आठ': 8,
      'नौ': 9,
      'दस': 10,
      'बीस': 20,
      'तीस': 30,
      'चालीस': 40,
      'पचास': 50,
    };

    for (String word in hindiNumbers.keys) {
      if (input.contains(word)) {
        return hindiNumbers[word];
      }
    }

    return null;
  }

  List<String> _extractCrops(String input) {
    final crops = <String>[];
    input = input.toLowerCase();

    // Common crops in Hindi
    final Map<String, String> cropNames = {
      'गेहूं': 'गेहूं',
      'धान': 'धान',
      'चावल': 'चावल',
      'मक्का': 'मक्का',
      'बाजरा': 'बाजरा',
      'ज्वार': 'ज्वार',
      'दाल': 'दाल',
      'चना': 'चना',
      'मूंग': 'मूंग',
      'तिल': 'तिल',
      'सरसों': 'सरसों',
      'आलू': 'आलू',
      'प्याज': 'प्याज',
      'लहसुन': 'लहसुन',
      'टमाटर': 'टमाटर',
      'wheat': 'गेहूं',
      'rice': 'चावल',
      'corn': 'मक्का',
      'potato': 'आलू',
    };

    for (String crop in cropNames.keys) {
      if (input.contains(crop)) {
        crops.add(cropNames[crop]!);
      }
    }

    return crops;
  }

  String? _extractGoals(String input) {
    return input.trim().isNotEmpty ? input.trim() : null;
  }

  String? _extractPhoneNumber(String input) {
    // Extract phone number from input
    final phoneRegex = RegExp(r'\d{10}');
    final match = phoneRegex.firstMatch(input.replaceAll(' ', ''));
    return match?.group(0);
  }

  String _cleanResponse(String text) {
    // Remove markdown formatting
    text = text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
    text = text.replaceAll('*', '');
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    text = text.replaceAll(RegExp(r'`(.*?)`'), r'$1');
    text = text.replaceAll(RegExp(r'_{2,}'), '');
    text = text.replaceAll(RegExp(r'\[.*?\]'), '');
    text = text.replaceAll(RegExp(r'\(.*?\)'), '');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.replaceAll(RegExp(r' {2,}'), ' ');

    return text.trim();
  }

  void _handleAIResponse(String response) {
    _messageController.add(response);
  }

  // Core conversation management method
  Future<void> _speakAndWaitForResponse(String message) async {
    try {
      _isWaitingForResponse = true;

      // Speak the message
      await _voiceService.speak(message);

      // Wait a moment for speech to complete
      await Future.delayed(const Duration(milliseconds: 1000));

      // Start listening automatically
      await startListening();

      // Set up response timeout
      _responseTimeoutTimer?.cancel();
      _responseTimeoutTimer = Timer(const Duration(seconds: 15), () async {
        if (_isWaitingForResponse) {
          await _handleResponseTimeout();
        }
      });
    } catch (e) {
      print('Error in _speakAndWaitForResponse: $e');
      _isWaitingForResponse = false;
      _responseTimeoutTimer?.cancel();
    }
  }

  Future<void> _handleResponseTimeout() async {
    _responseTimeoutTimer?.cancel();
    _isWaitingForResponse = false;

    await stopListening();
    await _voiceService.speak(
      'माफ़ करिए, मैंने आपकी आवाज़ नहीं सुनी। कृपया दोबारा बोलिए।',
    );

    // Restart listening after timeout message
    await Future.delayed(const Duration(milliseconds: 1000));
    await startListening();

    // Reset timeout
    _responseTimeoutTimer = Timer(const Duration(seconds: 15), () async {
      if (_isWaitingForResponse) {
        await _handleResponseTimeout();
      }
    });
  }

  // Enhanced conversation flow methods
  Future<void> _moveToNextStageWithFlow() async {
    switch (_currentStage) {
      case OnboardingStage.greeting:
        _currentStage = OnboardingStage.nameCollection;
        await _speakAndWaitForResponse('आपका नाम क्या है?');
        break;
      case OnboardingStage.nameCollection:
        _currentStage = OnboardingStage.locationCollection;
        await _speakAndWaitForResponse('आप कहां रहते हैं? आपका पता क्या है?');
        break;
      case OnboardingStage.locationCollection:
        _currentStage = OnboardingStage.experienceCollection;
        await _speakAndWaitForResponse('आपको खेती का कितने साल का अनुभव है?');
        break;
      case OnboardingStage.experienceCollection:
        _currentStage = OnboardingStage.cropsCollection;
        await _speakAndWaitForResponse('आप कौन सी फसलें उगाते हैं?');
        break;
      case OnboardingStage.cropsCollection:
        _currentStage = OnboardingStage.goalsCollection;
        await _speakAndWaitForResponse('खेती में आपके क्या लक्ष्य हैं?');
        break;
      case OnboardingStage.goalsCollection:
        _currentStage = OnboardingStage.contactCollection;
        await _speakAndWaitForResponse('आपका फोन नंबर क्या है?');
        break;
      case OnboardingStage.contactCollection:
        _currentStage = OnboardingStage.confirmation;
        await _confirmProfileWithEdit();
        break;
      case OnboardingStage.confirmation:
        await _saveProfile();
        break;
      default:
        break;
    }

    _stageController.add(_currentStage);
  }

  Future<void> _confirmProfileWithEdit() async {
    final confirmation = '''
बहुत अच्छा! आपकी जानकारी:
नाम: ${_currentProfile.name}
स्थान: ${_currentProfile.location}
अनुभव: ${_currentProfile.experienceYears} साल
फसलें: ${_currentProfile.crops.join(", ")}
लक्ष्य: ${_currentProfile.goals}
फोन: ${_currentProfile.phoneNumber}

क्या यह जानकारी सही है? यदि कुछ बदलना है तो बताएं।
''';

    await _speakAndWaitForResponse(confirmation);
  }

  Future<void> startListening() async {
    if (!_isOnboarding) return;

    // Stop any ongoing speech before starting to listen
    await _voiceService.stopSpeaking();
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Give time for speech to stop

    await _voiceService.startListening();
  }

  Future<void> stopListening() async {
    await _voiceService.stopListening();
  }

  void dispose() {
    _responseTimeoutTimer?.cancel();
    _autoListenTimer?.cancel();
    _profileController.close();
    _stageController.close();
    _messageController.close();
    _listeningController.close();
  }
}
