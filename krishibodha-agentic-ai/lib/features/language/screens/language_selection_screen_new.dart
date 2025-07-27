import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/features/language/providers/language_provider.dart';
import 'package:myapp/features/onboarding/providers/onboarding_provider.dart';
import 'package:myapp/providers/ai_voice_providers.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  bool _hasGivenWelcome = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _giveWelcomeMessage();
    });
  }

  Future<void> _giveWelcomeMessage() async {
    if (_hasGivenWelcome) return;

    try {
      // Initialize and give welcome
      await ref.read(serviceInitializationProvider.future);
      final aiService = ref.read(aiVoiceServiceProvider);
      await Future.delayed(const Duration(milliseconds: 1000));
      await aiService.speak(
        'नमस्ते! कृषिबोधा में आपका स्वागत है। कृपया अपनी भाषा का चयन करें।',
      );
      _hasGivenWelcome = true;
    } catch (e) {
      debugPrint('Error giving welcome message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // App Logo/Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/KissanAvatar.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.agriculture,
                          size: 60,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Heading Text
              const Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'अपनी भाषा चुनें',
                style: TextStyle(fontSize: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),

              // Language Options
              Expanded(
                child: ListView(
                  children: [
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'hi',
                      languageName: 'हिन्दी',
                      englishName: 'Hindi',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'hi',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'en',
                      languageName: 'English',
                      englishName: 'English',
                      flag: '🇺🇸',
                      isSelected: selectedLanguage == 'en',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'mr',
                      languageName: 'मराठी',
                      englishName: 'Marathi',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'mr',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'gu',
                      languageName: 'ગુજરાતી',
                      englishName: 'Gujarati',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'gu',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'te',
                      languageName: 'తెలుగు',
                      englishName: 'Telugu',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'te',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'ta',
                      languageName: 'தமிழ்',
                      englishName: 'Tamil',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'ta',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'bn',
                      languageName: 'বাংলা',
                      englishName: 'Bengali',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'bn',
                    ),
                    const SizedBox(height: 16),
                    _buildLanguageOption(
                      context: context,
                      ref: ref,
                      languageCode: 'pa',
                      languageName: 'ਪੰਜਾਬੀ',
                      englishName: 'Punjabi',
                      flag: '🇮🇳',
                      isSelected: selectedLanguage == 'pa',
                    ),
                  ],
                ),
              ),

              // Continue Button
              if (selectedLanguage != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Voice confirmation
                      try {
                        final aiService = ref.read(aiVoiceServiceProvider);
                        await aiService.speak(
                          'बहुत बढ़िया! अब हम आपकी व्यक्तिगत जानकारी लेंगे।',
                        );
                      } catch (e) {
                        debugPrint('Error speaking confirmation: $e');
                      }

                      ref
                          .read(onboardingProvider.notifier)
                          .completeLanguageSelection();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continue / जारी रखें',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String languageCode,
    required String languageName,
    required String englishName,
    required String flag,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        ref.read(languageProvider.notifier).setLanguage(languageCode);

        // Voice feedback for language selection
        try {
          final aiService = ref.read(aiVoiceServiceProvider);
          String message = '';
          switch (languageCode) {
            case 'hi':
              message = 'आपने हिन्दी भाषा चुनी है।';
              break;
            case 'en':
              message = 'You have selected English language.';
              break;
            case 'mr':
              message = 'तुम्ही मराठी भाषा निवडली आहे.';
              break;
            case 'gu':
              message = 'તમે ગુજરાતી ભાષા પસંદ કરી છે.';
              break;
            case 'te':
              message = 'మీరు తెలుగు భాషను ఎంచుకున్నారు.';
              break;
            case 'ta':
              message = 'நீங்கள் தமிழ் மொழியைத் தேர்ந்தெடுத்துள்ளீர்கள்.';
              break;
            case 'bn':
              message = 'আপনি বাংলা ভাষা নির্বাচন করেছেন।';
              break;
            case 'pa':
              message = 'ਤੁਸੀਂ ਪੰਜਾਬੀ ਭਾਸ਼ਾ ਚੁਣੀ ਹੈ।';
              break;
            default:
              message = 'Language selected.';
          }
          await aiService.speak(message);
        } catch (e) {
          debugPrint('Error speaking language selection: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(flag, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    englishName,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isSelected
                              ? AppColors.primary.withOpacity(0.7)
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
