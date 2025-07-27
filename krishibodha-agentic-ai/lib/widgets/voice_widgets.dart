import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_voice_provider.dart';

class VoiceFloatingButton extends ConsumerWidget {
  final VoidCallback? onVoiceInput;
  final bool showTranscription;
  final EdgeInsets margin;

  const VoiceFloatingButton({
    super.key,
    this.onVoiceInput,
    this.showTranscription = true,
    this.margin = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(globalVoiceProvider);
    final voiceNotifier = ref.watch(globalVoiceProvider.notifier);

    if (!voiceState.isInitialized || !voiceState.voiceEnabled) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: margin.bottom,
      right: margin.right,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Transcription display
          if (showTranscription && voiceState.currentTranscription.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                voiceState.currentTranscription,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

          // Voice button
          FloatingActionButton(
            onPressed: () async {
              if (voiceState.isListening) {
                await voiceNotifier.stopListening();
              } else if (voiceState.isSpeaking) {
                await voiceNotifier.stopSpeaking();
              } else {
                await voiceNotifier.startListening();
                onVoiceInput?.call();
              }
            },
            backgroundColor:
                voiceState.isListening
                    ? Colors.red
                    : voiceState.isSpeaking
                    ? Colors.orange
                    : Colors.green,
            child: Icon(
              voiceState.isListening
                  ? Icons.mic
                  : voiceState.isSpeaking
                  ? Icons.volume_up
                  : Icons.mic_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceControlBar extends ConsumerWidget {
  final bool showToggle;
  final VoidCallback? onVoiceToggle;

  const VoiceControlBar({
    super.key,
    this.showToggle = true,
    this.onVoiceToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(globalVoiceProvider);
    final voiceNotifier = ref.watch(globalVoiceProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border(top: BorderSide(color: Colors.green.shade200)),
      ),
      child: Row(
        children: [
          // Voice status indicator
          Icon(
            voiceState.isListening
                ? Icons.mic
                : voiceState.isSpeaking
                ? Icons.volume_up
                : Icons.mic_none,
            color:
                voiceState.isListening
                    ? Colors.red
                    : voiceState.isSpeaking
                    ? Colors.orange
                    : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),

          // Status text
          Expanded(
            child: Text(
              voiceState.isListening
                  ? 'सुन रहा हूँ...'
                  : voiceState.isSpeaking
                  ? 'बोल रहा हूँ...'
                  : 'आवाज़ सहायता उपलब्ध है',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Voice toggle button
          if (showToggle)
            Switch(
              value: voiceState.voiceEnabled,
              onChanged: (value) {
                voiceNotifier.toggleVoice();
                onVoiceToggle?.call();
              },
              activeColor: Colors.green,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}

class VoiceGuidanceCard extends ConsumerWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final IconData icon;

  const VoiceGuidanceCard({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.icon = Icons.help_outline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceNotifier = ref.watch(globalVoiceProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up, color: Colors.green),
          onPressed: () async {
            await voiceNotifier.speak(description);
          },
        ),
        onTap: onTap,
      ),
    );
  }
}

// Voice-enabled text field
class VoiceTextField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String fieldName;
  final bool required;
  final TextInputType keyboardType;
  final int? maxLines;

  const VoiceTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.fieldName,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  ConsumerState<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends ConsumerState<VoiceTextField> {
  bool _isListeningForThisField = false;

  @override
  void initState() {
    super.initState();
    // Listen to voice transcription and populate field if listening for this field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(voiceTranscriptionProvider, (previous, next) {
        if (_isListeningForThisField && next.isNotEmpty) {
          widget.controller.text = next;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(globalVoiceProvider);
    final voiceNotifier = ref.watch(globalVoiceProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label + (widget.required ? ' *' : ''),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            suffixIcon:
                voiceState.isInitialized && voiceState.voiceEnabled
                    ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Voice input button
                        IconButton(
                          icon: Icon(
                            _isListeningForThisField && voiceState.isListening
                                ? Icons.mic
                                : Icons.mic_none,
                            color:
                                _isListeningForThisField &&
                                        voiceState.isListening
                                    ? Colors.red
                                    : Colors.green,
                          ),
                          onPressed: () async {
                            if (_isListeningForThisField &&
                                voiceState.isListening) {
                              setState(() {
                                _isListeningForThisField = false;
                              });
                              await voiceNotifier.stopListening();
                            } else {
                              setState(() {
                                _isListeningForThisField = true;
                              });
                              await voiceNotifier.provideFieldGuidance(
                                widget.fieldName,
                              );
                              await Future.delayed(
                                const Duration(milliseconds: 1500),
                              );
                              await voiceNotifier.startListening();
                            }
                          },
                        ),
                        // Help button
                        IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await voiceNotifier.provideFieldGuidance(
                              widget.fieldName,
                            );
                          },
                        ),
                      ],
                    )
                    : null,
          ),
          validator:
              widget.required
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '${widget.label} आवश्यक है';
                    }
                    return null;
                  }
                  : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
