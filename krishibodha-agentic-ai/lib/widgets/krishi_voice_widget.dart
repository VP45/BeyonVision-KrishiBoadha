import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';

class KrishiVoiceWidget extends ConsumerStatefulWidget {
  final Widget child;

  const KrishiVoiceWidget({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<KrishiVoiceWidget> createState() => _KrishiVoiceWidgetState();
}

class _KrishiVoiceWidgetState extends ConsumerState<KrishiVoiceWidget>
    with TickerProviderStateMixin {
  bool _isListening = false;
  bool _showVoiceOverlay = false;
  String _currentMessage = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleVoiceAssistant() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _pulseController.repeat(reverse: true);
      _showMessage('आप क्या करना चाहते हैं? बोलिए...');
      // Here you would start voice recognition
    } else {
      _pulseController.stop();
      _hideMessage();
      // Here you would stop voice recognition
    }
  }

  void _showMessage(String message) {
    setState(() {
      _currentMessage = message;
      _showVoiceOverlay = true;
    });

    // Auto-hide message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideMessage();
      }
    });
  }

  void _hideMessage() {
    setState(() {
      _showVoiceOverlay = false;
      _currentMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        widget.child,

        // Voice message overlay
        if (_showVoiceOverlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.record_voice_over,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _hideMessage,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Floating voice button
        Positioned(
          bottom: 100, // Above bottom navigation
          right: 20,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _toggleVoiceAssistant,
                  onLongPress: _showVoiceHelp,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient:
                          _isListening
                              ? const LinearGradient(
                                colors: [Colors.orange, Colors.deepOrange],
                              )
                              : AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? Colors.orange
                                  : AppColors.primaryDark)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showVoiceHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.record_voice_over,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Voice Commands',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'आप ये कमांड बोल सकते हैं:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildVoiceCommands(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('समझ गया'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  List<Widget> _buildVoiceCommands() {
    final commands = [
      {'hindi': 'घर जाओ', 'english': 'Go Home'},
      {'hindi': 'बाजार दिखाओ', 'english': 'Show Market'},
      {'hindi': 'योजनाएं', 'english': 'Schemes'},
      {'hindi': 'प्रोफाइल', 'english': 'Profile'},
      {'hindi': 'मदद', 'english': 'Help'},
    ];

    return commands
        .map(
          (cmd) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: '"${cmd['hindi']}"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        TextSpan(
                          text: ' - ${cmd['english']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}
