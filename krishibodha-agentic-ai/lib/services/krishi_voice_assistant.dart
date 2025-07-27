import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/services/ai_voice_service.dart';

enum KrishiNavigationCommand {
  home,
  agmarket,
  schemes,
  profile,
  kisanAvatar,
  settings,
  help,
  onboarding,
  back,
  repeat,
  stop,
}

enum KrishiMode {
  navigation, // General app navigation
  onboarding, // During onboarding process
  chat, // Chat with Kisan Avatar
  assistance, // General help and guidance
}

class KrishiVoiceAssistant {
  static final KrishiVoiceAssistant _instance =
      KrishiVoiceAssistant._internal();
  factory KrishiVoiceAssistant() => _instance;
  KrishiVoiceAssistant._internal();

  final AIVoiceService _aiService = AIVoiceService();

  KrishiMode _currentMode = KrishiMode.navigation;
  String _currentLanguage = 'hi'; // Default to Hindi
  bool _isListening = false;
  bool _isActive = false;

  // Stream controllers
  final StreamController<KrishiNavigationCommand> _commandController =
      StreamController<KrishiNavigationCommand>.broadcast();
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();

  // Getters
  KrishiMode get currentMode => _currentMode;
  String get currentLanguage => _currentLanguage;
  bool get isListening => _isListening;
  bool get isActive => _isActive;

  Stream<KrishiNavigationCommand> get commandStream =>
      _commandController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<bool> get listeningStream => _listeningController.stream;

  // Initialize Krishi
  Future<void> initialize(String language) async {
    _currentLanguage = language;
    _isActive = true;

    await _speak(_getWelcomeMessage());
    await Future.delayed(const Duration(seconds: 2));
    await _speak(_getNavigationHelp());
  }

  // Activate Krishi for navigation assistance
  Future<void> activateForNavigation() async {
    _currentMode = KrishiMode.navigation;
    await _speak(_getNavigationActivationMessage());
    await _startListening();
  }

  // Activate Krishi for onboarding
  Future<void> activateForOnboarding() async {
    _currentMode = KrishiMode.onboarding;
    await _speak(_getOnboardingActivationMessage());
  }

  // Activate Krishi for chat
  Future<void> activateForChat() async {
    _currentMode = KrishiMode.chat;
    await _speak(_getChatActivationMessage());
    await _startListening();
  }

  // Process voice input and convert to navigation commands
  Future<void> processVoiceInput(String input) async {
    debugPrint('Krishi processing voice input: $input');

    String normalizedInput = input.toLowerCase().trim();
    KrishiNavigationCommand? command = _parseNavigationCommand(normalizedInput);

    if (command != null) {
      _commandController.add(command);
      await _confirmCommand(command);
    } else {
      await _handleUnrecognizedCommand(normalizedInput);
    }
  }

  // Parse voice input to navigation commands
  KrishiNavigationCommand? _parseNavigationCommand(String input) {
    // Commands in multiple languages
    Map<String, KrishiNavigationCommand> commands = {
      // Home commands
      'घर': KrishiNavigationCommand.home,
      'होम': KrishiNavigationCommand.home,
      'home': KrishiNavigationCommand.home,
      'मुख्य': KrishiNavigationCommand.home,
      'मुख्य पृष्ठ': KrishiNavigationCommand.home,

      // AgMarket commands
      'बाजार': KrishiNavigationCommand.agmarket,
      'एग मार्केट': KrishiNavigationCommand.agmarket,
      'agmarket': KrishiNavigationCommand.agmarket,
      'मंडी': KrishiNavigationCommand.agmarket,
      'बिक्री': KrishiNavigationCommand.agmarket,

      // Schemes commands
      'योजना': KrishiNavigationCommand.schemes,
      'योजनाएं': KrishiNavigationCommand.schemes,
      'schemes': KrishiNavigationCommand.schemes,
      'सरकारी योजना': KrishiNavigationCommand.schemes,

      // Profile commands
      'प्रोफाइल': KrishiNavigationCommand.profile,
      'profile': KrishiNavigationCommand.profile,
      'मेरी जानकारी': KrishiNavigationCommand.profile,
      'व्यक्तिगत जानकारी': KrishiNavigationCommand.profile,

      // Kisan Avatar commands
      'किसान अवतार': KrishiNavigationCommand.kisanAvatar,
      'कृषि सहायक': KrishiNavigationCommand.kisanAvatar,
      'चैट': KrishiNavigationCommand.kisanAvatar,
      'बात करें': KrishiNavigationCommand.kisanAvatar,
      'सवाल पूछें': KrishiNavigationCommand.kisanAvatar,

      // Control commands
      'पीछे': KrishiNavigationCommand.back,
      'वापस': KrishiNavigationCommand.back,
      'back': KrishiNavigationCommand.back,
      'रुकें': KrishiNavigationCommand.stop,
      'बंद करें': KrishiNavigationCommand.stop,
      'stop': KrishiNavigationCommand.stop,
      'दोहराएं': KrishiNavigationCommand.repeat,
      'फिर से': KrishiNavigationCommand.repeat,
      'repeat': KrishiNavigationCommand.repeat,
      'मदद': KrishiNavigationCommand.help,
      'help': KrishiNavigationCommand.help,
      'सहायता': KrishiNavigationCommand.help,
    };

    // Check for exact matches first
    for (String command in commands.keys) {
      if (input.contains(command)) {
        return commands[command];
      }
    }

    return null;
  }

  // Confirm navigation command
  Future<void> _confirmCommand(KrishiNavigationCommand command) async {
    String confirmation = _getCommandConfirmation(command);
    await _speak(confirmation);
  }

  // Handle unrecognized commands
  Future<void> _handleUnrecognizedCommand(String input) async {
    await _speak(_getUnrecognizedCommandMessage());
    await Future.delayed(const Duration(seconds: 1));
    await _speak(_getNavigationHelp());
  }

  // Start listening for voice commands
  Future<void> _startListening() async {
    if (_isListening) return;

    _isListening = true;
    _listeningController.add(true);

    try {
      // Listen to AI service transcription stream
      _aiService.transcriptionStream.listen((transcription) {
        if (transcription.isNotEmpty) {
          processVoiceInput(transcription);
        }
      });

      await _aiService.startListening();
    } catch (e) {
      debugPrint('Krishi start listening error: $e');
      _stopListening();
    }
  }

  // Stop listening
  void _stopListening() {
    _isListening = false;
    _listeningController.add(false);
    _aiService.stopListening();
  }

  // Toggle listening state
  Future<void> toggleListening() async {
    if (_isListening) {
      _stopListening();
      await _speak(_getListeningStoppedMessage());
    } else {
      await _speak(_getListeningStartedMessage());
      await _startListening();
    }
  }

  // Provide contextual help
  Future<void> provideHelp() async {
    switch (_currentMode) {
      case KrishiMode.navigation:
        await _speak(_getNavigationHelp());
        break;
      case KrishiMode.onboarding:
        await _speak(_getOnboardingHelp());
        break;
      case KrishiMode.chat:
        await _speak(_getChatHelp());
        break;
      case KrishiMode.assistance:
        await _speak(_getGeneralHelp());
        break;
    }
  }

  // Speak text using AI service
  Future<void> _speak(String text) async {
    _messageController.add(text);
    await _aiService.speak(text);
  }

  // Update language
  void updateLanguage(String newLanguage) {
    _currentLanguage = newLanguage;
  }

  // Clear current message
  void clearMessage() {
    _messageController.add('');
  }

  // Deactivate Krishi
  Future<void> deactivate() async {
    _isActive = false;
    _stopListening();
    await _speak(_getDeactivationMessage());
  }

  // Get localized messages based on current language
  String _getWelcomeMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'नमस्कार! मैं कृषि हूं, आपका व्यक्तिगत कृषि सहायक। मैं आपको इस ऐप में कहीं भी जाने में मदद कर सकता हूं।';
      case 'mr':
        return 'नमस्कार! मी कृषी आहे, तुमचा वैयक्तिक कृषी सहायक। मी तुम्हाला या अॅपमध्ये कुठेही जाण्यास मदत करू शकतो।';
      case 'gu':
        return 'નમસ્તે! હું કૃષિ છું, તમારો વ્યક્તિગત કૃષિ સહાયક. હું તમને આ એપ્લિકેશનમાં ક્યાંય પણ જવામાં મદદ કરી શકું છું.';
      case 'pa':
        return 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਕ੍ਰਿਸ਼ੀ ਹਾਂ, ਤੁਹਾਡਾ ਨਿੱਜੀ ਖੇਤੀ ਸਹਾਇਕ। ਮੈਂ ਤੁਹਾਨੂੰ ਇਸ ਐਪ ਵਿੱਚ ਕਿਤੇ ਵੀ ਜਾਣ ਵਿੱਚ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ।';
      case 'kn':
        return 'ನಮಸ್ಕಾರ! ನಾನು ಕೃಷಿ, ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಕೃಷಿ ಸಹಾಯಕ. ಈ ಅಪ್ಲಿಕೇಶನ್‌ನಲ್ಲಿ ಎಲ್ಲಿ ಬೇಕಾದರೂ ಹೋಗಲು ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡಬಹುದು.';
      default:
        return 'Hello! I am Krishi, your personal farming assistant. I can help you navigate anywhere in this app.';
    }
  }

  String _getNavigationHelp() {
    switch (_currentLanguage) {
      case 'hi':
        return 'आप कह सकते हैं: "घर जाओ", "बाजार दिखाओ", "योजनाएं", "प्रोफाइल", या "किसान अवतार से बात करें"।';
      case 'mr':
        return 'तुम्ही म्हणू शकता: "घर जा", "बाजार दाखवा", "योजना", "प्रोफाइल", किंवा "किसान अवतारशी बोला"।';
      case 'gu':
        return 'તમે કહી શકો છો: "ઘર જાઓ", "બજાર બતાવો", "યોજનાઓ", "પ્રોફાઇલ", અથવા "કિસાન અવતાર સાથે વાત કરો"।';
      case 'pa':
        return 'ਤੁਸੀਂ ਕਹਿ ਸਕਦੇ ਹੋ: "ਘਰ ਜਾਓ", "ਬਾਜ਼ਾਰ ਦਿਖਾਓ", "ਯੋਜਨਾਵਾਂ", "ਪ੍ਰੋਫਾਈਲ", ਜਾਂ "ਕਿਸਾਨ ਅਵਤਾਰ ਨਾਲ ਗੱਲ ਕਰੋ"।';
      case 'kn':
        return 'ನೀವು ಹೇಳಬಹುದು: "ಮನೆಗೆ ಹೋಗಿ", "ಮಾರುಕಟ್ಟೆ ತೋರಿಸಿ", "ಯೋಜನೆಗಳು", "ಪ್ರೊಫೈಲ್", ಅಥವಾ "ಕಿಸಾನ್ ಅವತಾರ್ ನೊಂದಿಗೆ ಮಾತನಾಡಿ"।';
      default:
        return 'You can say: "Go home", "Show market", "Schemes", "Profile", or "Talk to Kisan Avatar".';
    }
  }

  String _getNavigationActivationMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'कृषि नेविगेशन सक्रिय है। अब आप अपनी आवाज से ऐप में कहीं भी जा सकते हैं।';
      case 'mr':
        return 'कृषी नेव्हिगेशन सक्रिय आहे. आता तुम्ही तुमच्या आवाजाने अॅपमध्ये कुठेही जाऊ शकता.';
      case 'gu':
        return 'કૃષિ નેવિગેશન સક્રિય છે. હવે તમે તમારા અવાજથી એપ્લિકેશનમાં ક્યાંય પણ જઈ શકો છો.';
      case 'pa':
        return 'ਕ੍ਰਿਸ਼ੀ ਨੈਵੀਗੇਸ਼ਨ ਸਰਗਰਮ ਹੈ। ਹੁਣ ਤੁਸੀਂ ਆਪਣੀ ਆਵਾਜ਼ ਨਾਲ ਐਪ ਵਿੱਚ ਕਿਤੇ ਵੀ ਜਾ ਸਕਦੇ ਹੋ।';
      case 'kn':
        return 'ಕೃಷಿ ನ್ಯಾವಿಗೇಶನ್ ಸಕ್ರಿಯವಾಗಿದೆ. ಈಗ ನೀವು ನಿಮ್ಮ ಧ್ವನಿಯಿಂದ ಅಪ್ಲಿಕೇಶನ್‌ನಲ್ಲಿ ಎಲ್ಲಿ ಬೇಕಾದರೂ ಹೋಗಬಹುದು.';
      default:
        return 'Krishi navigation is active. Now you can navigate anywhere in the app using your voice.';
    }
  }

  String _getOnboardingActivationMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'आइए आपकी प्रोफाइल बनाते हैं। मैं आपका हर कदम में मार्गदर्शन करूंगा।';
      case 'mr':
        return 'चला तुमची प्रोफाइल तयार करूया. मी तुमच्या प्रत्येक पायरीत मार्गदर्शन करेन.';
      case 'gu':
        return 'ચાલો તમારી પ્રોફાઇલ બનાવીએ. હું તમારા દરેક પગલામાં માર્ગદર્શન આપીશ.';
      case 'pa':
        return 'ਚਲੋ ਤੁਹਾਡੀ ਪ੍ਰੋਫਾਈਲ ਬਣਾਈਏ। ਮੈਂ ਤੁਹਾਡੇ ਹਰ ਕਦਮ ਵਿੱਚ ਮਾਰਗਦਰਸ਼ਨ ਕਰਾਂਗਾ।';
      case 'kn':
        return 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಮಾಡೋಣ. ನಿಮ್ಮ ಪ್ರತಿಯೊಂದು ಹಂತದಲ್ಲೂ ನಾನು ಮಾರ್ಗದರ್ಶನ ಮಾಡುತ್ತೇನೆ.';
      default:
        return 'Let\'s create your profile. I will guide you through every step.';
    }
  }

  String _getChatActivationMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'मैं आपकी बात सुनने के लिए तैयार हूं। आप खेती के बारे में कुछ भी पूछ सकते हैं।';
      case 'mr':
        return 'मी तुमचे बोलणे ऐकण्यासाठी तयार आहे. तुम्ही शेतीबद्दल काहीही विचारू शकता.';
      case 'gu':
        return 'હું તમારી વાત સાંભળવા માટે તૈયાર છું. તમે ખેતી વિશે કંઈપણ પૂછી શકો છો.';
      case 'pa':
        return 'ਮੈਂ ਤੁਹਾਡੀ ਗੱਲ ਸੁਣਨ ਲਈ ਤਿਆਰ ਹਾਂ। ਤੁਸੀਂ ਖੇਤੀ ਬਾਰੇ ਕੁਝ ਵੀ ਪੁੱਛ ਸਕਦੇ ਹੋ।';
      case 'kn':
        return 'ನಿಮ್ಮ ಮಾತನ್ನು ಕೇಳಲು ನಾನು ಸಿದ್ಧನಿದ್ದೇನೆ. ಕೃಷಿಯ ಬಗ್ಗೆ ನೀವು ಏನು ಬೇಕಾದರೂ ಕೇಳಬಹುದು.';
      default:
        return 'I am ready to listen to you. You can ask me anything about farming.';
    }
  }

  String _getCommandConfirmation(KrishiNavigationCommand command) {
    String commandName = '';

    switch (command) {
      case KrishiNavigationCommand.home:
        commandName = _currentLanguage == 'hi' ? 'घर' : 'home';
        break;
      case KrishiNavigationCommand.agmarket:
        commandName = _currentLanguage == 'hi' ? 'बाजार' : 'market';
        break;
      case KrishiNavigationCommand.schemes:
        commandName = _currentLanguage == 'hi' ? 'योजनाएं' : 'schemes';
        break;
      case KrishiNavigationCommand.profile:
        commandName = _currentLanguage == 'hi' ? 'प्रोफाइल' : 'profile';
        break;
      case KrishiNavigationCommand.kisanAvatar:
        commandName = _currentLanguage == 'hi' ? 'किसान अवतार' : 'Kisan Avatar';
        break;
      default:
        commandName = _currentLanguage == 'hi' ? 'कमांड' : 'command';
    }

    switch (_currentLanguage) {
      case 'hi':
        return '$commandName पर जा रहे हैं...';
      case 'mr':
        return '$commandName वर जात आहे...';
      case 'gu':
        return '$commandName પર જઈ રહ્યા છીએ...';
      case 'pa':
        return '$commandName ਤੇ ਜਾ ਰਹੇ ਹਾਂ...';
      case 'kn':
        return '$commandName ಗೆ ಹೋಗುತ್ತಿದ್ದೇವೆ...';
      default:
        return 'Going to $commandName...';
    }
  }

  String _getUnrecognizedCommandMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'माफ करें, मैं आपकी बात समझ नहीं पाया। कृपया दोबारा कोशिश करें।';
      case 'mr':
        return 'माफ करा, मला तुमचे बोलणे समजले नाही. कृपया पुन्हा प्रयत्न करा.';
      case 'gu':
        return 'માફ કરશો, હું તમારી વાત સમજી શક્યો નથી. કૃપા કરીને ફરીથી પ્રયાસ કરો.';
      case 'pa':
        return 'ਮਾਫ਼ ਕਰਨਾ, ਮੈਂ ਤੁਹਾਡੀ ਗੱਲ ਸਮਝ ਨਹੀਂ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';
      case 'kn':
        return 'ಕ್ಷಮಿಸಿ, ನಿಮ್ಮ ಮಾತು ನನಗೆ ಅರ್ಥವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.';
      default:
        return 'Sorry, I didn\'t understand that. Please try again.';
    }
  }

  String _getListeningStartedMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'अब मैं सुन रहा हूं। कृपया बोलें।';
      case 'mr':
        return 'आता मी ऐकत आहे. कृपया बोला.';
      case 'gu':
        return 'હવે હું સાંભળી રહ્યો છું. કૃપા કરીને બોલો.';
      case 'pa':
        return 'ਹੁਣ ਮੈਂ ਸੁਣ ਰਿਹਾ ਹਾਂ। ਕਿਰਪਾ ਕਰਕੇ ਬੋਲੋ।';
      case 'kn':
        return 'ಈಗ ನಾನು ಕೇಳುತ್ತಿದ್ದೇನೆ. ದಯವಿಟ್ಟು ಮಾತನಾಡಿ.';
      default:
        return 'Now I am listening. Please speak.';
    }
  }

  String _getListeningStoppedMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'सुनना बंद कर दिया। फिर से शुरू करने के लिए बटन दबाएं।';
      case 'mr':
        return 'ऐकणे बंद केले. पुन्हा सुरू करण्यासाठी बटण दाबा.';
      case 'gu':
        return 'સાંભળવાનું બંધ કર્યું. ફરીથી શરૂ કરવા માટે બટન દબાવો.';
      case 'pa':
        return 'ਸੁਣਨਾ ਬੰਦ ਕਰ ਦਿੱਤਾ। ਦੁਬਾਰਾ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਬਟਨ ਦਬਾਓ।';
      case 'kn':
        return 'ಕೇಳುವುದನ್ನು ನಿಲ್ಲಿಸಿದೆ. ಮತ್ತೆ ಪ್ರಾರಂಭಿಸಲು ಬಟನ್ ಒತ್ತಿ.';
      default:
        return 'Stopped listening. Press button to start again.';
    }
  }

  String _getDeactivationMessage() {
    switch (_currentLanguage) {
      case 'hi':
        return 'कृषि सहायक निष्क्रिय। जरूरत पड़ने पर मुझे फिर से बुलाएं।';
      case 'mr':
        return 'कृषी सहायक निष्क्रिय. गरज पडल्यास मला पुन्हा बोलावा.';
      case 'gu':
        return 'કૃષિ સહાયક નિષ્ક્રિય. જરૂર પડે ત્યારે મને ફરીથી બોલાવો.';
      case 'pa':
        return 'ਕ੍ਰਿਸ਼ੀ ਸਹਾਇਕ ਨਿਸ਼ਕਿਰਿਆ। ਲੋੜ ਪੈਣ ਤੇ ਮੈਨੂੰ ਦੁਬਾਰਾ ਬੁਲਾਉਣਾ।';
      case 'kn':
        return 'ಕೃಷಿ ಸಹಾಯಕ ನಿಷ್ಕ್ರಿಯ. ಅಗತ್ಯವಿದ್ದಾಗ ನನ್ನನ್ನು ಮತ್ತೆ ಕರೆಯಿರಿ.';
      default:
        return 'Krishi assistant deactivated. Call me again when needed.';
    }
  }

  String _getOnboardingHelp() {
    switch (_currentLanguage) {
      case 'hi':
        return 'अपना नाम, खेत की जानकारी, और फसलों के बारे में बताएं। मैं हर कदम में आपकी मदद करूंगा।';
      case 'mr':
        return 'तुमचे नाव, शेताची माहिती आणि पिकांबद्दल सांगा. मी प्रत्येक पायरीत तुमची मदत करेन.';
      case 'gu':
        return 'તમારું નામ, ખેતરની માહિતી અને પાકો વિશે કહો. હું દરેક પગલામાં તમારી મદદ કરીશ.';
      case 'pa':
        return 'ਆਪਣਾ ਨਾਮ, ਖੇਤ ਦੀ ਜਾਣਕਾਰੀ ਅਤੇ ਫਸਲਾਂ ਬਾਰੇ ਦੱਸੋ। ਮੈਂ ਹਰ ਕਦਮ ਵਿੱਚ ਤੁਹਾਡੀ ਮਦਦ ਕਰਾਂਗਾ।';
      case 'kn':
        return 'ನಿಮ್ಮ ಹೆಸರು, ಹೊಲದ ಮಾಹಿತಿ ಮತ್ತು ಬೆಳೆಗಳ ಬಗ್ಗೆ ಹೇಳಿ. ಪ್ರತಿಯೊಂದು ಹಂತದಲ್ಲೂ ನಾನು ನಿಮಗೆ ಸಹಾಯ ಮಾಡುತ್ತೇನೆ.';
      default:
        return 'Tell me your name, farm information, and about your crops. I will help you at every step.';
    }
  }

  String _getChatHelp() {
    switch (_currentLanguage) {
      case 'hi':
        return 'आप मुझसे खेती, फसल, मौसम, या कोई भी कृषि संबंधी सवाल पूछ सकते हैं।';
      case 'mr':
        return 'तुम्ही माझ्याकडे शेती, पीक, हवामान किंवा कोणताही कृषी संबंधित प्रश्न विचारू शकता.';
      case 'gu':
        return 'તમે મને ખેતી, પાક, હવામાન અથવા કોઈપણ કૃષિ સંબંધિત પ્રશ્ન પૂછી શકો છો.';
      case 'pa':
        return 'ਤੁਸੀਂ ਮੈਨੂੰ ਖੇਤੀ, ਫਸਲ, ਮੌਸਮ ਜਾਂ ਕੋਈ ਵੀ ਖੇਤੀਬਾੜੀ ਸੰਬੰਧੀ ਸਵਾਲ ਪੁੱਛ ਸਕਦੇ ਹੋ।';
      case 'kn':
        return 'ನೀವು ನನ್ನಿಂದ ಕೃಷಿ, ಬೆಳೆ, ಹವಾಮಾನ ಅಥವಾ ಯಾವುದೇ ಕೃಷಿ ಸಂಬಂಧಿತ ಪ್ರಶ್ನೆಯನ್ನು ಕೇಳಬಹುದು.';
      default:
        return 'You can ask me about farming, crops, weather, or any agriculture-related questions.';
    }
  }

  String _getGeneralHelp() {
    switch (_currentLanguage) {
      case 'hi':
        return 'मैं आपका कृषि सहायक हूं। नेविगेशन, सवाल-जवाब, या सामान्य मदद के लिए मुझसे बात करें।';
      case 'mr':
        return 'मी तुमचा कृषी सहायक आहे. नेव्हिगेशन, प्रश्न-उत्तर किंवा सामान्य मदतीसाठी माझ्याशी बोला.';
      case 'gu':
        return 'હું તમારો કૃષિ સહાયક છું. નેવિગેશન, પ્રશ્ન-જવાબ અથવા સામાન્ય મદદ માટે મારી સાથે વાત કરો.';
      case 'pa':
        return 'ਮੈਂ ਤੁਹਾਡਾ ਕ੍ਰਿਸ਼ੀ ਸਹਾਇਕ ਹਾਂ। ਨੈਵੀਗੇਸ਼ਨ, ਸਵਾਲ-ਜਵਾਬ ਜਾਂ ਆਮ ਮਦਦ ਲਈ ਮੇਰੇ ਨਾਲ ਗੱਲ ਕਰੋ।';
      case 'kn':
        return 'ನಾನು ನಿಮ್ಮ ಕೃಷಿ ಸಹಾಯಕ. ನ್ಯಾವಿಗೇಶನ್, ಪ್ರಶ್ನೆ-ಉತ್ತರ ಅಥವಾ ಸಾಮಾನ್ಯ ಸಹಾಯಕ್ಕಾಗಿ ನನ್ನೊಂದಿಗೆ ಮಾತನಾಡಿ.';
      default:
        return 'I am your farming assistant. Talk to me for navigation, Q&A, or general help.';
    }
  }

  void dispose() {
    _commandController.close();
    _messageController.close();
    _listeningController.close();
    _aiService.dispose();
  }
}

// Riverpod providers for Krishi Voice Assistant
final krishiVoiceAssistantProvider = Provider<KrishiVoiceAssistant>((ref) {
  return KrishiVoiceAssistant();
});

final krishiCommandProvider = StreamProvider<KrishiNavigationCommand>((ref) {
  return ref.watch(krishiVoiceAssistantProvider).commandStream;
});

final krishiMessageProvider = StreamProvider<String>((ref) {
  return ref.watch(krishiVoiceAssistantProvider).messageStream;
});

final krishiListeningProvider = StreamProvider<bool>((ref) {
  return ref.watch(krishiVoiceAssistantProvider).listeningStream;
});
