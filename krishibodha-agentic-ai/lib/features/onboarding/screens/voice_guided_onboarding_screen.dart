import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/features/language/providers/language_provider.dart';
import 'package:myapp/services/krishi_conversational_ai.dart';
import 'package:myapp/features/navigation/main_navigation_screen.dart';

class VoiceGuidedOnboardingScreen extends ConsumerStatefulWidget {
  const VoiceGuidedOnboardingScreen({super.key});

  @override
  ConsumerState<VoiceGuidedOnboardingScreen> createState() =>
      _VoiceGuidedOnboardingScreenState();
}

class _VoiceGuidedOnboardingScreenState
    extends ConsumerState<VoiceGuidedOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _avatarController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  KrishiConversationalAI? _krishiAI;
  FarmerProfileData _currentProfile = FarmerProfileData();
  OnboardingStage _currentStage = OnboardingStage.greeting;
  String _currentMessage = '';
  bool _isListening = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeKrishi();
  }

  void _setupAnimations() {
    // Pulse animation for voice feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Avatar scale animation
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _avatarController.forward();
  }

  Future<void> _initializeKrishi() async {
    try {
      final language = ref.read(languageProvider) ?? 'hi';
      _krishiAI = ref.read(krishiConversationalAIProvider);

      await _krishiAI!.initialize(language);

      // Listen to streams
      _krishiAI!.profileStream.listen((profile) {
        if (mounted) {
          setState(() {
            _currentProfile = profile;
          });
        }
      });

      _krishiAI!.stageStream.listen((stage) {
        if (mounted) {
          setState(() {
            _currentStage = stage;
          });

          // Navigate to home when onboarding is completed
          if (stage == OnboardingStage.completed) {
            _navigateToHome();
          }
        }
      });

      _krishiAI!.messageStream.listen((message) {
        if (mounted) {
          setState(() {
            _currentMessage = message;
          });
        }
      });

      _krishiAI!.listeningStream.listen((listening) {
        if (mounted) {
          setState(() {
            _isListening = listening;
          });

          if (listening) {
            _pulseController.repeat(reverse: true);
          } else {
            _pulseController.stop();
            _pulseController.reset();
          }
        }
      });

      setState(() {
        _isInitialized = true;
      });

      // Start onboarding
      await _krishiAI!.startOnboarding();
    } catch (e) {
      debugPrint('Error initializing Krishi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice service initialization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _avatarController.dispose();
    _krishiAI?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // Krishi Avatar
                  Flexible(flex: 2, child: Center(child: _buildKrishiAvatar())),

                  const SizedBox(height: 16),

                  // Current Message
                  Flexible(flex: 1, child: _buildMessageSection()),

                  const SizedBox(height: 16),

                  // Profile Progress
                  _buildProfileProgress(),

                  const SizedBox(height: 20),

                  // Voice Controls
                  _buildVoiceControls(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'कृषि आपका स्वागत करता है',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'आइए मिलकर आपकी प्रोफाइल बनाते हैं',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildKrishiAvatar() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.1),
            border: Border.all(
              color: _isListening ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/KissanAvatar.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  size: 80,
                  color: AppColors.primary,
                );
              },
            ),
          ),
        ),
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnimation.value : 1.0,
            child: child,
          );
        },
      ),
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
    );
  }

  Widget _buildMessageSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isListening ? Icons.mic : Icons.chat_bubble_outline,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                _isListening
                    ? 'आपकी बात सुन रहा हूं...'
                    : (_currentMessage.isEmpty
                        ? 'तैयार हूं...'
                        : _currentMessage),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileProgress() {
    final progress = _getProgressPercentage();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'प्रोफाइल प्रगति',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 12),
          _buildCompletedFields(),
        ],
      ),
    );
  }

  double _getProgressPercentage() {
    int completedFields = 0;
    const totalFields = 6; // name, location, experience, crops, goals, contact

    if (_currentProfile.name != null && _currentProfile.name!.isNotEmpty)
      completedFields++;
    if (_currentProfile.location != null &&
        _currentProfile.location!.isNotEmpty)
      completedFields++;
    if (_currentProfile.experienceYears != null) completedFields++;
    if (_currentProfile.crops.isNotEmpty) completedFields++;
    if (_currentProfile.goals != null && _currentProfile.goals!.isNotEmpty)
      completedFields++;
    if (_currentProfile.phoneNumber != null &&
        _currentProfile.phoneNumber!.isNotEmpty)
      completedFields++;

    return completedFields / totalFields;
  }

  Widget _buildCompletedFields() {
    final fields = <Widget>[];

    if (_currentProfile.name != null && _currentProfile.name!.isNotEmpty) {
      fields.add(_buildFieldChip('नाम: ${_currentProfile.name}', true));
    }

    if (_currentProfile.location != null &&
        _currentProfile.location!.isNotEmpty) {
      fields.add(_buildFieldChip('स्थान: ${_currentProfile.location}', true));
    }

    if (_currentProfile.experienceYears != null) {
      fields.add(
        _buildFieldChip('अनुभव: ${_currentProfile.experienceYears} साल', true),
      );
    }

    if (_currentProfile.crops.isNotEmpty) {
      fields.add(
        _buildFieldChip('फसलें: ${_currentProfile.crops.join(", ")}', true),
      );
    }

    return Wrap(spacing: 8, runSpacing: 4, children: fields);
  }

  Widget _buildFieldChip(String text, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isCompleted ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isCompleted ? AppColors.primary : Colors.grey[400],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? AppColors.primary : Colors.grey[600],
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceControls() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 16,
      children: [
        // Listen Button
        FloatingActionButton.extended(
          onPressed: _isListening ? null : () => _krishiAI?.startListening(),
          backgroundColor: _isListening ? Colors.grey : AppColors.primary,
          icon: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
          ),
          label: Text(
            _isListening ? 'सुन रहा हूं...' : 'बोलें',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),

        // Stop Listening Button
        if (_isListening)
          FloatingActionButton.extended(
            onPressed: () => _krishiAI?.stopListening(),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.stop, color: Colors.white),
            label: const Text(
              'रुकें',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
      ],
    );
  }
}
