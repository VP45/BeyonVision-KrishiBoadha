import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends StateNotifier<String?> {
  LanguageNotifier() : super(null) {
    // Always start with no language selected for fresh onboarding flow
    _resetLanguage();
  }

  Future<void> _resetLanguage() async {
    // Clear any saved language data and start fresh
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_language');
    state = null;
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    state = languageCode;
  }

  Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_language');
    state = null;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String?>((
  ref,
) {
  return LanguageNotifier();
});

// Localization map for different languages
class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'KrishiBodha AI',
      'welcome': 'Welcome',
      'select_language': 'Select Language',
      'continue': 'Continue',
      'name': 'Name',
      'phone_number': 'Phone Number',
      'village': 'Village',
      'district': 'District',
      'state': 'State',
      'farm_size': 'Farm Size (in acres)',
      'crops_grown': 'Crops Grown',
      'farming_experience': 'Farming Experience (in years)',
      'next': 'Next',
      'submit': 'Submit',
      'farmer_details': 'Farmer Details',
      'farm_information': 'Farm Information',
      'complete_profile': 'Complete Your Profile',
      'enter_your_details': 'Please enter your details to get started',
      'required_field': 'This field is required',
      'invalid_phone': 'Please enter a valid phone number',
      'invalid_number': 'Please enter a valid number',
    },
    'hi': {
      'app_name': 'कृषिबोध AI',
      'welcome': 'स्वागत है',
      'select_language': 'भाषा चुनें',
      'continue': 'जारी रखें',
      'name': 'नाम',
      'phone_number': 'फोन नंबर',
      'village': 'गांव',
      'district': 'जिला',
      'state': 'राज्य',
      'farm_size': 'खेत का आकार (एकड़ में)',
      'crops_grown': 'उगाई गई फसलें',
      'farming_experience': 'कृषि अनुभव (वर्षों में)',
      'next': 'अगला',
      'submit': 'सबमिट करें',
      'farmer_details': 'किसान विवरण',
      'farm_information': 'खेत की जानकारी',
      'complete_profile': 'अपनी प्रोफाइल पूरी करें',
      'enter_your_details': 'कृपया शुरू करने के लिए अपना विवरण दर्ज करें',
      'required_field': 'यह फील्ड आवश्यक है',
      'invalid_phone': 'कृपया एक वैध फोन नंबर दर्ज करें',
      'invalid_number': 'कृपया एक वैध संख्या दर्ज करें',
    },
    'mr': {
      'app_name': 'कृषिबोध AI',
      'welcome': 'स्वागत',
      'select_language': 'भाषा निवडा',
      'continue': 'सुरू ठेवा',
      'name': 'नाव',
      'phone_number': 'फोन नंबर',
      'village': 'गाव',
      'district': 'जिल्हा',
      'state': 'राज्य',
      'farm_size': 'शेताचा आकार (एकरात)',
      'crops_grown': 'पिकवलेली पिके',
      'farming_experience': 'शेती अनुभव (वर्षांत)',
      'next': 'पुढे',
      'submit': 'सबमिट करा',
      'farmer_details': 'शेतकरी तपशील',
      'farm_information': 'शेत माहिती',
      'complete_profile': 'तुमची प्रोफाइल पूर्ण करा',
      'enter_your_details': 'कृपया सुरू करण्यासाठी तुमचे तपशील प्रविष्ट करा',
      'required_field': 'हे फील्ड आवश्यक आहे',
      'invalid_phone': 'कृपया वैध फोन नंबर प्रविष्ट करा',
      'invalid_number': 'कृपया वैध संख्या प्रविष्ट करा',
    },
    'gu': {
      'app_name': 'કૃષિબોધ AI',
      'welcome': 'સ્વાગત',
      'select_language': 'ભાષા પસંદ કરો',
      'continue': 'ચાલુ રાખો',
      'name': 'નામ',
      'phone_number': 'ફોન નંબર',
      'village': 'ગામ',
      'district': 'જિલ્લો',
      'state': 'રાજ્ય',
      'farm_size': 'ખેતરનું કદ (એકરમાં)',
      'crops_grown': 'ઉગાડવામાં આવેલા પાક',
      'farming_experience': 'ખેતીનો અનુભવ (વર્ષોમાં)',
      'next': 'આગળ',
      'submit': 'સબમિટ કરો',
      'farmer_details': 'ખેડૂત વિગતો',
      'farm_information': 'ખેતર માહિતી',
      'complete_profile': 'તમારી પ્રોફાઇલ પૂર્ણ કરો',
      'enter_your_details': 'કૃપા કરીને શરૂ કરવા માટે તમારી વિગતો દાખલ કરો',
      'required_field': 'આ ફીલ્ડ આવશ્યક છે',
      'invalid_phone': 'કૃપા કરીને માન્ય ફોન નંબર દાખલ કરો',
      'invalid_number': 'કૃપા કરીને માન્ય નંબર દાખલ કરો',
    },
    'pa': {
      'app_name': 'ਕ੍ਰਿਸ਼ਿਬੋਧ AI',
      'welcome': 'ਸੁਆਗਤ',
      'select_language': 'ਭਾਸ਼ਾ ਚੁਣੋ',
      'continue': 'ਜਾਰੀ ਰੱਖੋ',
      'name': 'ਨਾਮ',
      'phone_number': 'ਫੋਨ ਨੰਬਰ',
      'village': 'ਪਿੰਡ',
      'district': 'ਜ਼ਿਲ੍ਹਾ',
      'state': 'ਰਾਜ',
      'farm_size': 'ਖੇਤ ਦਾ ਆਕਾਰ (ਏਕੜ ਵਿੱਚ)',
      'crops_grown': 'ਉਗਾਈਆਂ ਫਸਲਾਂ',
      'farming_experience': 'ਖੇਤੀ ਦਾ ਤਜਰਬਾ (ਸਾਲਾਂ ਵਿੱਚ)',
      'next': 'ਅਗਲਾ',
      'submit': 'ਸਬਮਿਟ ਕਰੋ',
      'farmer_details': 'ਕਿਸਾਨ ਵੇਰਵੇ',
      'farm_information': 'ਖੇਤ ਦੀ ਜਾਣਕਾਰੀ',
      'complete_profile': 'ਆਪਣੀ ਪ੍ਰੋਫਾਈਲ ਪੂਰੀ ਕਰੋ',
      'enter_your_details': 'ਕਿਰਪਾ ਕਰਕੇ ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਆਪਣੇ ਵੇਰਵੇ ਦਰਜ ਕਰੋ',
      'required_field': 'ਇਹ ਫੀਲਡ ਲਾਜ਼ਮੀ ਹੈ',
      'invalid_phone': 'ਕਿਰਪਾ ਕਰਕੇ ਇੱਕ ਵੈਧ ਫੋਨ ਨੰਬਰ ਦਰਜ ਕਰੋ',
      'invalid_number': 'ਕਿਰਪਾ ਕਰਕੇ ਇੱਕ ਵੈਧ ਨੰਬਰ ਦਰਜ ਕਰੋ',
    },
    'kn': {
      'app_name': 'ಕೃಷಿಬೋಧ AI',
      'welcome': 'ಸ್ವಾಗತ',
      'select_language': 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'continue': 'ಮುಂದುವರಿಸಿ',
      'name': 'ಹೆಸರು',
      'phone_number': 'ಫೋನ್ ಸಂಖ್ಯೆ',
      'village': 'ಗ್ರಾಮ',
      'district': 'ಜಿಲ್ಲೆ',
      'state': 'ರಾಜ್ಯ',
      'farm_size': 'ಭೂಮಿಯ ಗಾತ್ರ (ಎಕರೆಗಳಲ್ಲಿ)',
      'crops_grown': 'ಬೆಳೆಸಿದ ಬೆಳೆಗಳು',
      'farming_experience': 'ಕೃಷಿ ಅನುಭವ (ವರ್ಷಗಳಲ್ಲಿ)',
      'next': 'ಮುಂದೆ',
      'submit': 'ಸಲ್ಲಿಸಿ',
      'farmer_details': 'ರೈತ ವಿವರಗಳು',
      'farm_information': 'ಭೂಮಿಯ ಮಾಹಿತಿ',
      'complete_profile': 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಪೂರ್ಣಗೊಳಿಸಿ',
      'enter_your_details': 'ದಯವಿಟ್ಟು ಪ್ರಾರಂಭಿಸಲು ನಿಮ್ಮ ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ',
      'required_field': 'ಈ ಕ್ಷೇತ್ರ ಅಗತ್ಯವಾಗಿದೆ',
      'invalid_phone': 'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಫೋನ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'invalid_number': 'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
    },
  };

  static String? translate(String key, String? languageCode) {
    if (languageCode == null) return _localizedValues['en']?[key] ?? key;
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}
