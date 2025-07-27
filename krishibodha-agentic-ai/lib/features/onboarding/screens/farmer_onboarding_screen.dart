import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/constants/app_text_styles.dart';
import 'package:myapp/widgets/gradient_button.dart';
import '../../../models/farmer_profile.dart';
import '../../../services/onboarding_service.dart';
import '../../../providers/ai_voice_providers.dart';
import 'farmer_profile_summary_screen.dart';

class FarmerOnboardingScreen extends ConsumerStatefulWidget {
  const FarmerOnboardingScreen({super.key});

  @override
  ConsumerState<FarmerOnboardingScreen> createState() =>
      _FarmerOnboardingScreenState();
}

class _FarmerOnboardingScreenState
    extends ConsumerState<FarmerOnboardingScreen> {
  late OnboardingService _onboardingService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      // Initialize AI service first
      await ref.read(serviceInitializationProvider.future);

      _onboardingService = ref.read(onboardingServiceProvider);

      // Listen to voice transcriptions and process them
      ref.read(aiVoiceServiceProvider).transcriptionStream.listen((
        transcription,
      ) {
        if (transcription.isNotEmpty) {
          _onboardingService.processVoiceInput(transcription);
        }
      });

      setState(() {
        _isInitialized = true;
      });

      // Start onboarding
      await _onboardingService.startOnboarding();
    } catch (e) {
      debugPrint('Failed to initialize onboarding: $e');
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

  void _handleVoicePress() async {
    if (!_isInitialized) return;

    final aiService = ref.read(aiVoiceServiceProvider);
    if (aiService.isListening) {
      await aiService.stopListening();
    } else {
      await aiService.startListening();
    }
  }

  void _navigateToSummary(FarmerProfile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FarmerProfileSummaryScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(currentStepProvider);
    final farmerProfile = ref.watch(farmerProfileProvider);
    final onboardingMessage = ref.watch(onboardingMessageProvider);
    final isListening = ref.watch(isListeningProvider).value ?? false;
    final isSpeaking = ref.watch(isSpeakingProvider).value ?? false;
    final transcription = ref.watch(transcriptionProvider).value ?? '';

    // Handle completion
    if (currentStep.hasValue &&
        currentStep.value == OnboardingStep.completed &&
        farmerProfile.hasValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSummary(farmerProfile.value!);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'किसान पंजीकरण',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            if (currentStep.hasValue && farmerProfile.hasValue)
              _buildProgressIndicator(
                currentStep.value!,
                farmerProfile.value!.completionPercentage,
              ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar and speaking indicator
                    _buildAvatarSection(isSpeaking),

                    const SizedBox(height: 24),

                    // Current step info
                    if (currentStep.hasValue)
                      _buildStepInfo(currentStep.value!),

                    const SizedBox(height: 16),

                    // Current message
                    if (onboardingMessage.hasValue &&
                        onboardingMessage.value!.isNotEmpty)
                      _buildMessageCard(onboardingMessage.value!),

                    const SizedBox(height: 16),

                    // Transcription display
                    if (transcription.isNotEmpty)
                      _buildTranscriptionCard(transcription),

                    const SizedBox(height: 16),

                    // Profile summary (only on summary step)
                    if (currentStep.hasValue &&
                        currentStep.value == OnboardingStep.summary &&
                        farmerProfile.hasValue)
                      _buildProfileSummary(farmerProfile.value!),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom controls
            _buildBottomControls(isListening, currentStep.value),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(OnboardingStep step, double percentage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step.title,
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
              Text(
                '${percentage.toInt()}%',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(bool isSpeaking) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundSecondary,
        border:
            isSpeaking ? Border.all(color: AppColors.primary, width: 4) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          if (isSpeaking)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/KissanAvatar.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 80, color: AppColors.primary);
          },
        ),
      ),
    );
  }

  Widget _buildStepInfo(OnboardingStep step) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStepIcon(step), color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(step.prompt, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.volume_up, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionCard(String transcription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'आपने कहा:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(transcription, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(FarmerProfile profile) {
    return Card(
      elevation: 4,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'आपकी जानकारी का सारांश',
              style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            if (profile.hasBasicInfo) ...[
              _buildSummaryItem('नाम', profile.name!, Icons.person),
              const SizedBox(height: 12),
            ],

            if (profile.hasLocation) ...[
              _buildSummaryItem(
                'स्थान',
                'अक्षांश: ${profile.latitude!.toStringAsFixed(4)}, देशांतर: ${profile.longitude!.toStringAsFixed(4)}',
                Icons.location_on,
              ),
              const SizedBox(height: 12),
            ],

            if (profile.hasDescription) ...[
              _buildSummaryItem(
                'विवरण',
                profile.description!,
                Icons.description,
              ),
              const SizedBox(height: 12),
            ],

            if (profile.hasGoals) ...[
              _buildSummaryItem('लक्ष्य', profile.goals!, Icons.flag),
              const SizedBox(height: 12),
            ],

            if (profile.hasCrops) ...[
              _buildSummaryItem('फसलें', profile.crops.join(', '), Icons.grass),
              const SizedBox(height: 12),
            ],

            if (profile.hasAadhar) ...[
              _buildSummaryItem(
                'आधार नंबर',
                '**** **** ${profile.aadharNumber!.substring(8)}',
                Icons.credit_card,
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: GradientButton(
                    text: 'सही है',
                    onPressed:
                        () => _onboardingService.processVoiceInput('सही है'),
                    height: 48,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showEditDialog(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('बदलें'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(bool isListening, OnboardingStep? currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice button
          FloatingActionButton.extended(
            onPressed: _isInitialized ? _handleVoicePress : null,
            backgroundColor: isListening ? Colors.red : AppColors.primary,
            elevation: 4.0,
            icon: Icon(
              isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 24,
            ),
            label: Text(
              isListening ? 'बंद करें' : 'बोलें',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Status text
          Text(
            _getStatusText(isListening, currentStep),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return Icons.waving_hand;
      case OnboardingStep.name:
        return Icons.person;
      case OnboardingStep.location:
        return Icons.location_on;
      case OnboardingStep.description:
        return Icons.description;
      case OnboardingStep.goals:
        return Icons.flag;
      case OnboardingStep.crops:
        return Icons.grass;
      case OnboardingStep.aadhar:
        return Icons.credit_card;
      case OnboardingStep.summary:
        return Icons.summarize;
      case OnboardingStep.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText(bool isListening, OnboardingStep? currentStep) {
    if (!_isInitialized) {
      return 'सेवा शुरू हो रही है...';
    }

    if (isListening) {
      return 'सुन रहा हूं... बोलिए';
    }

    if (currentStep == OnboardingStep.completed) {
      return 'पंजीकरण पूरा हो गया!';
    }

    return 'माइक बटन दबाकर बोलें';
  }

  void _showEditDialog() {
    // TODO: Implement edit dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('संपादन'),
            content: const Text('संपादन सुविधा जल्द ही उपलब्ध होगी।'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ठीक है'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _onboardingService.dispose();
    super.dispose();
  }
}
