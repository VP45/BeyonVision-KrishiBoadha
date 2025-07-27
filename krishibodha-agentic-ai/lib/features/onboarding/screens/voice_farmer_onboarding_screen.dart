import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/constants/app_text_styles.dart';
import 'package:myapp/providers/ai_voice_providers.dart';
import 'package:myapp/features/onboarding/providers/onboarding_provider.dart';
import 'package:myapp/providers/farmer_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RegistrationStep {
  welcome,
  name,
  location,
  experience,
  goals,
  crops,
  aadhar,
  completed,
}

class VoiceFarmerOnboardingScreen extends ConsumerStatefulWidget {
  const VoiceFarmerOnboardingScreen({super.key});

  @override
  ConsumerState<VoiceFarmerOnboardingScreen> createState() =>
      _VoiceFarmerOnboardingScreenState();
}

class _VoiceFarmerOnboardingScreenState
    extends ConsumerState<VoiceFarmerOnboardingScreen> {
  RegistrationStep _currentStep = RegistrationStep.welcome;
  bool _isProcessing = false;

  // Farmer data
  String _farmerName = '';
  String _farmerLocation = '';
  String _farmerExperience = '';
  String _farmerGoals = '';
  String _farmerCrops = '';
  String _farmerAadhar = '';

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await ref.read(serviceInitializationProvider.future);
      if (mounted) {
        _startWelcome();
      }
    } catch (e) {
      debugPrint('Failed to initialize AI service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('सेवा शुरू करने में समस्या है: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startWelcome() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final aiService = ref.read(aiVoiceServiceProvider);
    await aiService.speak(
      'नमस्ते किसान भाई! मैं आपका किसान मित्र हूँ। आज मैं आपकी पंजीकरण प्रक्रिया में मदद करूँगा। क्या आप तैयार हैं?',
    );

    // Auto proceed to name collection after welcome
    await Future.delayed(const Duration(seconds: 4));
    _moveToNextStep();
  }

  void _moveToNextStep() {
    setState(() {
      _currentStep = RegistrationStep.values[_currentStep.index + 1];
    });
    _askCurrentQuestion();
  }

  Future<void> _askCurrentQuestion() async {
    final aiService = ref.read(aiVoiceServiceProvider);

    String question = '';
    switch (_currentStep) {
      case RegistrationStep.name:
        question = 'कृपया अपना पूरा नाम बताएं';
        break;
      case RegistrationStep.location:
        question = 'अपना स्थान या पता बताएं। आप किस गाँव या शहर से हैं?';
        break;
      case RegistrationStep.experience:
        question = 'आपको खेती का कितना अनुभव है? कृपया अपना अनुभव बताएं';
        break;
      case RegistrationStep.goals:
        question =
            'आप खेती में क्या लक्ष्य हासिल करना चाहते हैं? अपने सपने बताएं';
        break;
      case RegistrationStep.crops:
        question = 'आप कौन सी फसलें उगाते हैं या उगाना चाहते हैं?';
        break;
      case RegistrationStep.aadhar:
        question = 'कृपया अपना आधार नंबर बताएं';
        break;
      case RegistrationStep.completed:
        await _completeRegistration();
        return;
      default:
        return;
    }

    await aiService.speak(question);
    await Future.delayed(const Duration(milliseconds: 1500));
    await aiService.startListening();
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final aiService = ref.read(aiVoiceServiceProvider);
      await aiService.speak(
        'धन्यवाद! आपकी जानकारी सफलतापूर्वक दर्ज कर ली गई है। अब हम आपके खेत की जानकारी लेंगे।',
      );

      // Save farmer data to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('farmers')
          .add({
            'name': _farmerName,
            'location': _farmerLocation,
            'experience': _farmerExperience,
            'goals': _farmerGoals,
            'crops': _farmerCrops,
            'aadhar': _farmerAadhar,
            'timestamp': FieldValue.serverTimestamp(),
          });

      // Update farmer provider
      final farmerData = FarmerData(
        id: docRef.id,
        name: _farmerName,
        location: _farmerLocation,
        experience: _farmerExperience,
        goals: _farmerGoals,
        crops: _farmerCrops,
        aadhar: _farmerAadhar,
      );

      ref.read(farmerProvider.notifier).setFarmerData(farmerData);

      await Future.delayed(const Duration(seconds: 3));

      // Move to map screen
      ref.read(onboardingProvider.notifier).completeFarmerOnboarding();
    } catch (e) {
      debugPrint('Error saving farmer data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('डेटा सेव करने में समस्या: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  String _getCurrentStepText() {
    switch (_currentStep) {
      case RegistrationStep.welcome:
        return 'स्वागत है!';
      case RegistrationStep.name:
        return 'आपका नाम';
      case RegistrationStep.location:
        return 'आपका स्थान';
      case RegistrationStep.experience:
        return 'खेती का अनुभव';
      case RegistrationStep.goals:
        return 'आपके लक्ष्य';
      case RegistrationStep.crops:
        return 'आपकी फसलें';
      case RegistrationStep.aadhar:
        return 'आधार नंबर';
      case RegistrationStep.completed:
        return 'पंजीकरण पूर्ण';
    }
  }

  String _getCurrentData() {
    switch (_currentStep) {
      case RegistrationStep.name:
        return _farmerName;
      case RegistrationStep.location:
        return _farmerLocation;
      case RegistrationStep.experience:
        return _farmerExperience;
      case RegistrationStep.goals:
        return _farmerGoals;
      case RegistrationStep.crops:
        return _farmerCrops;
      case RegistrationStep.aadhar:
        return _farmerAadhar;
      default:
        return '';
    }
  }

  double _getProgress() {
    return (_currentStep.index + 1) / RegistrationStep.values.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isListening = ref.watch(isListeningProvider).value ?? false;
    final isSpeaking = ref.watch(isSpeakingProvider).value ?? false;
    final transcription = ref.watch(transcriptionProvider).value ?? '';

    // Listen to transcription and save data
    ref.listen<AsyncValue<String>>(transcriptionProvider, (previous, next) {
      if (next.hasValue &&
          next.value!.isNotEmpty &&
          next.value != previous?.value) {
        final text = next.value!;

        switch (_currentStep) {
          case RegistrationStep.name:
            _farmerName = text;
            break;
          case RegistrationStep.location:
            _farmerLocation = text;
            break;
          case RegistrationStep.experience:
            _farmerExperience = text;
            break;
          case RegistrationStep.goals:
            _farmerGoals = text;
            break;
          case RegistrationStep.crops:
            _farmerCrops = text;
            break;
          case RegistrationStep.aadhar:
            _farmerAadhar = text;
            break;
          default:
            break;
        }
      }
    });

    // Listen to responses and move to next step
    ref.listen<AsyncValue<String>>(responseProvider, (previous, next) {
      if (next.hasValue &&
          next.value!.isNotEmpty &&
          next.value != previous?.value) {
        // After AI responds, move to next step after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (_currentStep != RegistrationStep.completed &&
              _currentStep != RegistrationStep.welcome) {
            _moveToNextStep();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('किसान पंजीकरण', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getProgress(),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_getProgress() * 100).toInt()}% पूर्ण',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar with animation
                    Container(
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.backgroundSecondary,
                        border:
                            isSpeaking || isListening
                                ? Border.all(
                                  color:
                                      isListening
                                          ? Colors.red
                                          : AppColors.primaryDark,
                                  width: 3,
                                )
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          if (isSpeaking || isListening)
                            BoxShadow(
                              color: (isListening
                                      ? Colors.red
                                      : AppColors.primaryDark)
                                  .withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Image.asset(
                          'assets/images/KissanAvatar.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Current Step
                    Text(
                      _getCurrentStepText(),
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Status Text
                    Text(
                      isListening
                          ? 'सुन रहा हूँ...'
                          : isSpeaking
                          ? 'बोल रहा हूँ...'
                          : _isProcessing
                          ? 'डेटा सेव कर रहा हूँ...'
                          : 'तैयार हूँ',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color:
                            isListening
                                ? Colors.red
                                : isSpeaking
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Current Data Display
                    if (_getCurrentData().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'दर्ज की गई जानकारी:',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getCurrentData(),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                    // Transcription Display
                    if (transcription.isNotEmpty && isListening)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'आप बोल रहे हैं:',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              transcription,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Control Panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(top: BorderSide(color: Colors.green[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Voice Status
                  Icon(
                    isListening
                        ? Icons.mic
                        : isSpeaking
                        ? Icons.volume_up
                        : Icons.mic_none,
                    color:
                        isListening
                            ? Colors.red
                            : isSpeaking
                            ? Colors.orange
                            : Colors.green,
                    size: 32,
                  ),

                  // Manual Next Button (for testing)
                  if (_currentStep != RegistrationStep.welcome &&
                      _currentStep != RegistrationStep.completed)
                    ElevatedButton(
                      onPressed:
                          _getCurrentData().isNotEmpty ? _moveToNextStep : null,
                      child: const Text('अगला'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
