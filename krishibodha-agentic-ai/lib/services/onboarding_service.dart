import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/farmer_profile.dart';
import '../services/ai_voice_service.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  final AIVoiceService _aiService = AIVoiceService();

  OnboardingStep _currentStep = OnboardingStep.welcome;
  FarmerProfile _profile = const FarmerProfile();

  // Retry counters for each step
  final Map<OnboardingStep, int> _retryCount = {};
  static const int maxRetries = 3;

  // Stream controllers
  final StreamController<OnboardingStep> _stepController =
      StreamController<OnboardingStep>.broadcast();
  final StreamController<FarmerProfile> _profileController =
      StreamController<FarmerProfile>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  // Getters
  OnboardingStep get currentStep => _currentStep;
  FarmerProfile get profile => _profile;

  Stream<OnboardingStep> get stepStream => _stepController.stream;
  Stream<FarmerProfile> get profileStream => _profileController.stream;
  Stream<String> get messageStream => _messageController.stream;

  Future<void> startOnboarding() async {
    _currentStep = OnboardingStep.welcome;
    _profile = const FarmerProfile();

    // Reset retry counts
    _retryCount.clear();

    _stepController.add(_currentStep);
    _profileController.add(_profile);

    // Start with welcome message
    await _speakCurrentPrompt();
  }

  Future<void> processVoiceInput(String input) async {
    debugPrint('Processing voice input for step ${_currentStep.name}: $input');

    switch (_currentStep) {
      case OnboardingStep.welcome:
        await _handleWelcomeResponse(input);
        break;
      case OnboardingStep.name:
        await _handleNameResponse(input);
        break;
      case OnboardingStep.location:
        await _handleLocationResponse(input);
        break;
      case OnboardingStep.description:
        await _handleDescriptionResponse(input);
        break;
      case OnboardingStep.goals:
        await _handleGoalsResponse(input);
        break;
      case OnboardingStep.crops:
        await _handleCropsResponse(input);
        break;
      case OnboardingStep.aadhar:
        await _handleAadharResponse(input);
        break;
      case OnboardingStep.summary:
        await _handleSummaryResponse(input);
        break;
      case OnboardingStep.completed:
        break;
    }
  }

  Future<void> _handleWelcomeResponse(String input) async {
    // Give a moment to process, then move to name collection
    await Future.delayed(const Duration(seconds: 2));
    _currentStep = OnboardingStep.name;
    _stepController.add(_currentStep);
    await _speakCurrentPrompt();
  }

  Future<void> _handleNameResponse(String input) async {
    if (input.trim().isNotEmpty && input.trim().length >= 2) {
      _profile = _profile.copyWith(name: input.trim());
      _profileController.add(_profile);

      // Reset retry count for this step
      _retryCount[OnboardingStep.name] = 0;

      // Confirm the name and give positive feedback
      await _speak(
        'बहुत अच्छा ${_profile.name} जी! आपका नाम सहेज लिया गया है।',
      );
      await Future.delayed(const Duration(seconds: 2));

      // Move to location with a smooth transition
      await _speak('अब मुझे आपका स्थान चाहिए।');
      await Future.delayed(const Duration(seconds: 1));

      _currentStep = OnboardingStep.location;
      _stepController.add(_currentStep);

      // Try to get location automatically
      await _requestLocation();
    } else {
      // Increment retry count
      _retryCount[OnboardingStep.name] =
          (_retryCount[OnboardingStep.name] ?? 0) + 1;

      if (_retryCount[OnboardingStep.name]! >= maxRetries) {
        await _speak(
          'कोई बात नहीं, हम बाद में आपका नाम पूछ सकते हैं। आगे बढ़ते हैं।',
        );
        await Future.delayed(const Duration(seconds: 2));
        _currentStep = OnboardingStep.location;
        _stepController.add(_currentStep);
        await _requestLocation();
      } else {
        String retryMessage = _getRetryMessage(
          OnboardingStep.name,
          _retryCount[OnboardingStep.name]!,
        );
        await _speak(retryMessage);
      }
    }
  }

  Future<void> _handleLocationResponse(String input) async {
    // If location is already obtained, move to next step
    if (_profile.hasLocation) {
      await _speak('बहुत बढ़िया! आपका स्थान मिल गया है।');
      await Future.delayed(const Duration(seconds: 2));
      await _speak('अब मुझे आपके खेती के अनुभव के बारे में बताइए।');
      await Future.delayed(const Duration(seconds: 1));

      _currentStep = OnboardingStep.description;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
      return;
    }

    // Try to parse location from speech or request GPS
    await _speak('स्थान की जानकारी प्राप्त करने की कोशिश कर रहा हूं...');
    await Future.delayed(const Duration(seconds: 2));
    await _requestLocation();
  }

  Future<void> _handleDescriptionResponse(String input) async {
    if (input.trim().isNotEmpty && input.trim().length >= 5) {
      _profile = _profile.copyWith(description: input.trim());
      _profileController.add(_profile);

      // Reset retry count for this step
      _retryCount[OnboardingStep.description] = 0;

      // Confirm and give positive feedback
      await _speak('अच्छा! आपका अनुभव समझ आ गया।');
      await Future.delayed(const Duration(seconds: 2));
      await _speak('अब मुझे आपके खेती के लक्ष्य के बारे में बताइए।');
      await Future.delayed(const Duration(seconds: 1));

      _currentStep = OnboardingStep.goals;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    } else {
      // Increment retry count
      _retryCount[OnboardingStep.description] =
          (_retryCount[OnboardingStep.description] ?? 0) + 1;

      if (_retryCount[OnboardingStep.description]! >= maxRetries) {
        await _speak(
          'कोई बात नहीं, हम बाद में आपका विवरण पूछ सकते हैं। आगे बढ़ते हैं।',
        );
        await Future.delayed(const Duration(seconds: 2));
        _currentStep = OnboardingStep.goals;
        _stepController.add(_currentStep);
        await _speakCurrentPrompt();
      } else {
        String retryMessage = _getRetryMessage(
          OnboardingStep.description,
          _retryCount[OnboardingStep.description]!,
        );
        await _speak(retryMessage);
      }
    }
  }

  Future<void> _handleGoalsResponse(String input) async {
    if (input.trim().isNotEmpty && input.trim().length >= 3) {
      _profile = _profile.copyWith(goals: input.trim());
      _profileController.add(_profile);

      // Reset retry count for this step
      _retryCount[OnboardingStep.goals] = 0;

      // Confirm and give positive feedback
      await _speak('बहुत बढ़िया! आपके लक्ष्य समझ आ गए।');
      await Future.delayed(const Duration(seconds: 2));
      await _speak('अब मुझे बताइए कि आप कौन सी फसलें उगाते हैं।');
      await Future.delayed(const Duration(seconds: 1));

      _currentStep = OnboardingStep.crops;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    } else {
      // Increment retry count
      _retryCount[OnboardingStep.goals] =
          (_retryCount[OnboardingStep.goals] ?? 0) + 1;

      if (_retryCount[OnboardingStep.goals]! >= maxRetries) {
        await _speak(
          'कोई बात नहीं, हम बाद में आपके लक्ष्य पूछ सकते हैं। आगे बढ़ते हैं।',
        );
        await Future.delayed(const Duration(seconds: 2));
        _currentStep = OnboardingStep.crops;
        _stepController.add(_currentStep);
        await _speakCurrentPrompt();
      } else {
        String retryMessage = _getRetryMessage(
          OnboardingStep.goals,
          _retryCount[OnboardingStep.goals]!,
        );
        await _speak(retryMessage);
      }
    }
  }

  Future<void> _handleCropsResponse(String input) async {
    if (input.trim().isNotEmpty && input.trim().length >= 2) {
      // Parse crops from input (split by common separators)
      List<String> crops =
          input
              .split(RegExp(r'[,और\s]+'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e.length >= 2)
              .toList();

      if (crops.isNotEmpty) {
        _profile = _profile.copyWith(crops: [..._profile.crops, ...crops]);
        _profileController.add(_profile);

        // Reset retry count for this step
        _retryCount[OnboardingStep.crops] = 0;

        // Confirm crops and give positive feedback
        await _speak('बहुत अच्छा! आपकी फसलों की जानकारी मिल गई।');
        await Future.delayed(const Duration(seconds: 2));
        await _speak('अब अंत में, मुझे आपका आधार नंबर चाहिए।');
        await Future.delayed(const Duration(seconds: 1));

        _currentStep = OnboardingStep.aadhar;
        _stepController.add(_currentStep);
        await _speakCurrentPrompt();
      } else {
        await _handleInvalidCropsInput();
      }
    } else {
      await _handleInvalidCropsInput();
    }
  }

  Future<void> _handleInvalidCropsInput() async {
    // Increment retry count
    _retryCount[OnboardingStep.crops] =
        (_retryCount[OnboardingStep.crops] ?? 0) + 1;

    if (_retryCount[OnboardingStep.crops]! >= maxRetries) {
      await _speak(
        'कोई बात नहीं, हम बाद में आपकी फसलों के बारे में पूछ सकते हैं। आगे बढ़ते हैं।',
      );
      await Future.delayed(const Duration(seconds: 2));
      _currentStep = OnboardingStep.aadhar;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    } else {
      String retryMessage = _getRetryMessage(
        OnboardingStep.crops,
        _retryCount[OnboardingStep.crops]!,
      );
      await _speak(retryMessage);
    }
  }

  Future<void> _handleAadharResponse(String input) async {
    // Extract numbers from input
    String aadharNumber = input.replaceAll(RegExp(r'[^\d]'), '');

    if (aadharNumber.length == 12) {
      _profile = _profile.copyWith(aadharNumber: aadharNumber);
      _profileController.add(_profile);

      // Reset retry count for this step
      _retryCount[OnboardingStep.aadhar] = 0;

      // Confirm Aadhar and celebrate completion
      await _speak('बहुत बढ़िया! आपका आधार नंबर सहेज लिया गया है।');
      await Future.delayed(const Duration(seconds: 2));
      await _speak(
        'अब आपकी सभी जानकारी पूरी हो गई है। मैं सारी जानकारी दिखा रहा हूं।',
      );
      await Future.delayed(const Duration(seconds: 2));

      _currentStep = OnboardingStep.summary;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    } else {
      // Increment retry count
      _retryCount[OnboardingStep.aadhar] =
          (_retryCount[OnboardingStep.aadhar] ?? 0) + 1;

      if (_retryCount[OnboardingStep.aadhar]! >= maxRetries) {
        await _speak(
          'कोई बात नहीं, हम बाद में आपका आधार नंबर पूछ सकते हैं। आगे बढ़ते हैं।',
        );
        await Future.delayed(const Duration(seconds: 2));
        _currentStep = OnboardingStep.summary;
        _stepController.add(_currentStep);
        await _speakCurrentPrompt();
      } else {
        String retryMessage = _getRetryMessage(
          OnboardingStep.aadhar,
          _retryCount[OnboardingStep.aadhar]!,
        );
        await _speak(retryMessage);

        // Provide additional guidance for Aadhar
        if (_retryCount[OnboardingStep.aadhar] == 2) {
          await Future.delayed(const Duration(seconds: 2));
          await _speak('उदाहरण: 1234 5678 9012 - इस तरह 12 अंक होते हैं।');
        }
      }
    }
  }

  Future<void> _handleSummaryResponse(String input) async {
    if (input.toLowerCase().contains('सही') ||
        input.toLowerCase().contains('ठीक') ||
        input.toLowerCase().contains('हां') ||
        input.toLowerCase().contains('yes') ||
        input.toLowerCase().contains('ok')) {
      _profile = _profile.copyWith(isComplete: true);
      _profileController.add(_profile);

      // Final confirmation and celebration
      await _speak('बहुत बढ़िया! आपकी प्रोफाइल तैयार हो गई है।');
      await Future.delayed(const Duration(seconds: 2));

      _currentStep = OnboardingStep.completed;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    } else if (input.toLowerCase().contains('नहीं') ||
        input.toLowerCase().contains('गलत') ||
        input.toLowerCase().contains('बदल') ||
        input.toLowerCase().contains('no')) {
      await _speak(
        'कौन सी जानकारी बदलनी है? नाम, स्थान, विवरण, लक्ष्य, फसलें या आधार नंबर?',
      );
      await Future.delayed(const Duration(seconds: 2));
    } else {
      // Increment retry count
      _retryCount[OnboardingStep.summary] =
          (_retryCount[OnboardingStep.summary] ?? 0) + 1;

      if (_retryCount[OnboardingStep.summary]! >= maxRetries) {
        await _speak('ठीक है, आपकी जानकारी सहेजी जा रही है।');
        await Future.delayed(const Duration(seconds: 2));
        _profile = _profile.copyWith(isComplete: true);
        _profileController.add(_profile);
        _currentStep = OnboardingStep.completed;
        _stepController.add(_currentStep);
        await _speakCurrentPrompt();
      } else {
        String retryMessage;
        switch (_retryCount[OnboardingStep.summary]!) {
          case 1:
            retryMessage =
                'कृपया "हां" कहें अगर जानकारी सही है, या "नहीं" कहें अगर कुछ बदलना है।';
            break;
          case 2:
            retryMessage =
                'क्या आपकी सभी जानकारी सही है? हां या नहीं में जवाब दें।';
            break;
          default:
            retryMessage = 'क्या यह जानकारी सही है?';
        }
        await _speak(retryMessage);
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _requestLocation() async {
    try {
      await _speak(
        'स्थान की सेवा अभी उपलब्ध नहीं है। कृपया अपना पता बताएं या आगे बढ़ें।',
      );

      // For now, skip location and move to next step
      // TODO: Add proper location service later
      await Future.delayed(const Duration(seconds: 3));

      await _speak('ठीक है, स्थान के बिना आगे बढ़ते हैं।');
      await Future.delayed(const Duration(seconds: 2));

      _currentStep = OnboardingStep.description;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    } catch (e) {
      debugPrint('Location error: $e');
      await _speak('स्थान प्राप्त करने में समस्या हुई। आगे बढ़ते हैं।');

      await Future.delayed(const Duration(seconds: 2));
      _currentStep = OnboardingStep.description;
      _stepController.add(_currentStep);
      await _speakCurrentPrompt();
    }
  }

  Future<void> editField(String fieldName, String newValue) async {
    switch (fieldName.toLowerCase()) {
      case 'name':
      case 'नाम':
        _profile = _profile.copyWith(name: newValue);
        break;
      case 'description':
      case 'विवरण':
        _profile = _profile.copyWith(description: newValue);
        break;
      case 'goals':
      case 'लक्ष्य':
        _profile = _profile.copyWith(goals: newValue);
        break;
      case 'crops':
      case 'फसलें':
        List<String> crops =
            newValue
                .split(RegExp(r'[,और\s]+'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
        _profile = _profile.copyWith(crops: crops);
        break;
      case 'aadhar':
      case 'आधार':
        String aadhar = newValue.replaceAll(RegExp(r'[^\d]'), '');
        if (aadhar.length == 12) {
          _profile = _profile.copyWith(aadharNumber: aadhar);
        }
        break;
    }
    _profileController.add(_profile);
  }

  Future<void> goToStep(OnboardingStep step) async {
    _currentStep = step;
    _stepController.add(_currentStep);

    // Reset retry count for the step we're going to
    _retryCount[step] = 0;

    await _speakCurrentPrompt();
  }

  Future<void> _speakCurrentPrompt() async {
    await _speak(_currentStep.prompt);
  }

  Future<void> _speak(String text) async {
    _messageController.add(text);
    await _aiService.speak(text);
  }

  String _getRetryMessage(OnboardingStep step, int retryCount) {
    switch (step) {
      case OnboardingStep.name:
        switch (retryCount) {
          case 1:
            return 'कोई बात नहीं। कृपया अपना पूरा नाम धीरे-धीरे और साफ आवाज में बताएं।';
          case 2:
            return 'ठीक है, मैं फिर से सुन रहा हूं। कृपया अपना नाम स्पष्ट रूप से बोलें। जैसे: राम कुमार या सुनीता देवी।';
          default:
            return 'कृपया अपना नाम बताएं।';
        }
      case OnboardingStep.description:
        switch (retryCount) {
          case 1:
            return 'कोई जल्दी नहीं है। कृपया अपने खेती के अनुभव के बारे में थोड़ा विस्तार से बताएं। आप कितने साल से खेती कर रहे हैं?';
          case 2:
            return 'समझ गया। अगर आप चाहें तो कुछ इस तरह बता सकते हैं: मैं 10 साल से खेती कर रहा हूं, या मैं नया किसान हूं। आराम से बताएं।';
          default:
            return 'कृपया अपने बारे में कुछ बताएं।';
        }
      case OnboardingStep.goals:
        switch (retryCount) {
          case 1:
            return 'बिल्कुल ठीक है। आप खेती से क्या चाहते हैं? जैसे अधिक पैसा कमाना, बेहतर फसल उगाना, या कुछ और?';
          case 2:
            return 'कोई दिक्कत नहीं। उदाहरण के लिए: मैं अपनी आय बढ़ाना चाहता हूं, या मैं जैविक खेती करना चाहता हूं। आराम से बताएं।';
          default:
            return 'कृपया अपने लक्ष्य बताएं।';
        }
      case OnboardingStep.crops:
        switch (retryCount) {
          case 1:
            return 'धैर्य रखें। कृपया उन फसलों के नाम बताएं जो आप उगाते हैं। एक या कई फसलों के नाम बता सकते हैं।';
          case 2:
            return 'समझ गया। उदाहरण: गेहूं धान, या टमाटर प्याज आलू। इस तरह अपनी फसलों के नाम बताएं। जल्दी नहीं है।';
          default:
            return 'कृपया अपनी फसलों के नाम बताएं।';
        }
      case OnboardingStep.aadhar:
        switch (retryCount) {
          case 1:
            return 'कोई बात नहीं। कृपया धीरे-धीरे 12 अंकों का आधार नंबर बताएं। सिर्फ नंबर बोलें, कोई और शब्द नहीं।';
          case 2:
            return 'ठीक है, मैं समझ गया। आधार कार्ड में 12 नंबर होते हैं। कृपया आराम से एक-एक करके सभी 12 अंक बताएं।';
          default:
            return 'कृपया 12 अंकों का सही आधार नंबर बताएं।';
        }
      default:
        return 'कोई बात नहीं। कृपया दोबारा कोशिश करें।';
    }
  }

  void dispose() {
    _stepController.close();
    _profileController.close();
    _messageController.close();
  }
}

// Riverpod providers
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final currentStepProvider = StreamProvider<OnboardingStep>((ref) {
  return ref.watch(onboardingServiceProvider).stepStream;
});

final farmerProfileProvider = StreamProvider<FarmerProfile>((ref) {
  return ref.watch(onboardingServiceProvider).profileStream;
});

final onboardingMessageProvider = StreamProvider<String>((ref) {
  return ref.watch(onboardingServiceProvider).messageStream;
});
