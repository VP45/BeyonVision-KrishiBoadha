import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/constants/app_text_styles.dart';
import 'package:myapp/widgets/gradient_button.dart';
import '../../../providers/ai_voice_providers.dart';
import 'chat_screen.dart';

class KisanAvatarScreen extends ConsumerStatefulWidget {
  const KisanAvatarScreen({super.key});

  @override
  ConsumerState<KisanAvatarScreen> createState() => _KisanAvatarScreenState();
}

class _KisanAvatarScreenState extends ConsumerState<KisanAvatarScreen> {
  bool _isVoiceMode = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await ref.read(serviceInitializationProvider.future);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
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

  void _handleVoicePress() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया प्रतीक्षा करें, सेवा शुरू हो रही है...'),
        ),
      );
      return;
    }

    final aiService = ref.read(aiVoiceServiceProvider);

    if (aiService.isListening) {
      await aiService.stopListening();
    } else {
      await aiService.startListening();
    }
  }

  void _navigateToChat() {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया प्रतीक्षा करें, सेवा शुरू हो रही है...'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Watch the various states
    final isListening = ref.watch(isListeningProvider).value ?? false;
    final isSpeaking = ref.watch(isSpeakingProvider).value ?? false;
    final transcription = ref.watch(transcriptionProvider).value ?? '';
    final response = ref.watch(responseProvider).value ?? '';

    // Listen to responses for voice mode
    ref.listen<AsyncValue<String>>(responseProvider, (previous, next) {
      if (_isVoiceMode && next.hasValue && next.value!.isNotEmpty) {
        // Response will be automatically spoken by the service
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Initialization status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isInitialized ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _isInitialized ? 'तैयार' : 'लोड हो रहा है...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Mode toggle
                  ToggleButtons(
                    isSelected: [_isVoiceMode, !_isVoiceMode],
                    onPressed: (index) {
                      setState(() {
                        _isVoiceMode = index == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    selectedBorderColor: AppColors.primaryDark,
                    selectedColor: Colors.white,
                    fillColor: AppColors.primaryDark,
                    color: AppColors.primaryDark,
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 48.0,
                    ),
                    children: const [Icon(Icons.mic), Icon(Icons.text_fields)],
                  ),
                ],
              ),
            ),

            // Center content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar container with speaking animation
                    Container(
                      width: screenWidth * 0.8,
                      height: screenWidth * 1.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppColors.backgroundSecondary,
                        border:
                            isSpeaking
                                ? Border.all(
                                  color: AppColors.primaryDark,
                                  width: 3,
                                )
                                : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          if (isSpeaking)
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.3),
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
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.primaryDark,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    error.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'नमस्ते किसान भाई!',
                        style: AppTextStyles.heading2,
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Dynamic status based on current state
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _getStatusText(isListening, isSpeaking),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        maxLines: 3,
                      ),
                    ),

                    // Transcription display (for voice mode)
                    if (_isVoiceMode && transcription.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'आपने कहा:',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Text(
                                  transcription,
                                  style: AppTextStyles.bodyMedium,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Response display (for voice mode)
                    if (_isVoiceMode &&
                        response.isNotEmpty &&
                        !isListening) ...[
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.smart_toy,
                                  color: AppColors.primaryDark,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'किसान मित्र:',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: SingleChildScrollView(
                                child: Text(
                                  response,
                                  style: AppTextStyles.bodyMedium,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 32.0),
              child:
                  _isVoiceMode
                      ? FloatingActionButton.extended(
                        onPressed: _isInitialized ? _handleVoicePress : null,
                        backgroundColor:
                            isListening ? Colors.red : AppColors.primaryDark,
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
                      )
                      : GradientButton(
                        text: 'चैट शुरू करें',
                        onPressed: _isInitialized ? _navigateToChat : () {},
                        height: 56,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(bool isListening, bool isSpeaking) {
    if (!_isInitialized) {
      return 'सेवा शुरू हो रही है...';
    }

    if (_isVoiceMode) {
      if (isListening) {
        return 'सुन रहा हूं... बोलिए';
      } else if (isSpeaking) {
        return 'जवाब दे रहा हूं...';
      } else {
        return 'माइक बटन दबाकर बोलें';
      }
    } else {
      return 'चैट बटन दबाकर बात करें';
    }
  }
}
