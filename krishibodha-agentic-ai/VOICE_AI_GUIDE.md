# Kisan Avatar AI Voice Integration Guide

## Overview

This implementation integrates Firebase AI (Gemini 2.0 Flash) with Speech-to-Text and Text-to-Speech functionality to create an interactive Hindi-speaking Kisan Avatar for farmers.

## Features Implemented

### 1. AI Voice Service (`lib/services/ai_voice_service.dart`)

- **Firebase AI Integration**: Uses Gemini 2.0 Flash model with Hindi system instructions
- **Speech-to-Text**: Recognizes Hindi speech input from farmers
- **Text-to-Speech**: Responds in Hindi voice
- **Permission Handling**: Manages microphone permissions
- **State Management**: Tracks listening, speaking, transcription, and response states

### 2. State Management (`lib/providers/ai_voice_providers.dart`)

- Riverpod providers for reactive state management
- Streams for real-time updates of voice states
- Service initialization provider

### 3. Enhanced Kisan Avatar Screen

- **Voice Mode**:
  - Tap microphone to start/stop listening
  - Real-time transcription display
  - Visual feedback with speaking animations
  - Hindi voice responses
- **Text Mode**:
  - Navigate to chat screen for text conversations
- **Status Indicators**: Shows service initialization and current state

### 4. Chat Screen (`lib/features/kisan_avatar/screens/chat_screen.dart`)

- Text-based chat interface in Hindi
- Message bubbles with user and AI avatars
- Real-time AI responses
- Auto-scroll to latest messages

## Key Components

### AI Service Configuration

```dart
// System instruction for Hindi farming assistant
systemInstruction: Content('system', [
  TextPart('''आप एक दोस्ताना किसान सहायक हैं। हमेशा हिंदी में जवाब दें।
  किसानों की समस्याओं का समाधान करें, कृषि संबंधी सलाह दें, और उनकी मदद करें।
  आपका नाम "किसान मित्र" है। छोटे और स्पष्ट उत्तर दें।'''),
]),
```

### Voice Configuration

- **Language**: Hindi (hi-IN)
- **Speech Rate**: 0.8 (slightly slower for clarity)
- **Recognition**: Supports partial results and confirmation mode
- **Timeout**: 30 seconds listening, 3 seconds pause detection

### Permissions Required

- `RECORD_AUDIO`: For speech recognition
- `MICROPHONE`: For microphone access
- `SPEECH_RECOGNITION`: For speech processing
- `INTERNET`: For Firebase AI API calls

## Usage Flow

### Voice Interaction

1. User taps voice mode toggle
2. Service initializes (if not already done)
3. User taps microphone button
4. App starts listening and shows "सुन रहा हूं... बोलिए"
5. User speaks in Hindi
6. Real-time transcription appears
7. After speech ends, question is sent to Firebase AI
8. AI responds in Hindi text
9. TTS speaks the response aloud
10. Response text is displayed

### Text Interaction

1. User taps text mode toggle
2. User taps "चैट शुरू करें" button
3. Chat screen opens
4. User types question in Hindi/English
5. AI responds in Hindi
6. Conversation continues with message history

## Testing the Implementation

### Prerequisites

1. Ensure Firebase project is configured with AI services
2. Android device/emulator with microphone access
3. Internet connection for AI API calls

### Testing Voice Mode

1. Run the app
2. Wait for "तैयार" status indicator
3. Toggle to voice mode (microphone icon)
4. Tap the microphone button
5. Say something like: "मेरी फसल में कीड़े लग गए हैं, क्या करूं?"
6. Observe transcription and listen to Hindi response

### Testing Text Mode

1. Toggle to text mode (text icon)
2. Tap "चैट शुरू करें"
3. Type a farming question
4. Receive Hindi response

## Troubleshooting

### Common Issues

1. **Microphone Permission Denied**: Check Android settings
2. **No Speech Recognition**: Ensure device has Google Speech Services
3. **No Voice Output**: Check device volume and TTS settings
4. **AI Not Responding**: Verify Firebase configuration and internet

### Debug Information

- Check console logs for service initialization
- Monitor stream states in debug mode
- Verify Firebase AI quota and usage

## Customization Options

### AI Personality

Modify the system instruction in `ai_voice_service.dart` to change the AI's personality or expertise.

### Voice Settings

Adjust TTS parameters:

- `setSpeechRate()`: Change speaking speed
- `setPitch()`: Modify voice pitch
- `setVolume()`: Adjust volume level

### UI Customization

- Modify colors in `constants/app_colors.dart`
- Update text styles in `constants/app_text_styles.dart`
- Change animations and visual feedback

## Future Enhancements

1. **Multiple Languages**: Add support for regional Indian languages
2. **Offline Mode**: Implement basic offline responses
3. **Voice Training**: Personalized voice recognition
4. **Conversation History**: Save and recall past conversations
5. **Multimedia Responses**: Include images and videos in responses
6. **Location-Based Advice**: Use GPS for region-specific farming advice
