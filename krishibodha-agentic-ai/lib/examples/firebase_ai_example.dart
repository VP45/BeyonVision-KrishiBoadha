import 'package:firebase_ai/firebase_ai.dart';

/// Example implementation of Firebase AI content generation
/// This shows how to use the generateContent function you provided
class FirebaseAIExample {
  /// Your original generateContent function with some enhancements
  Future<void> generateContent() async {
    final generationConfig = GenerationConfig(
      responseMimeType: 'text/plain',
      temperature: 0.7, // Added for better creativity
      maxOutputTokens: 500, // Added to control response length
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: generationConfig,
      // Added system instruction for farming context
      systemInstruction: Content('system', [
        TextPart(
          'आप एक किसान सहायक हैं। हिंदी में जवाब दें और कृषि संबंधी सलाह दें।',
        ),
      ]),
    );

    final message = Content('user', [
      TextPart(
        'मेरी फसल में कीड़े लग गए हैं, मुझे क्या करना चाहिए?',
      ), // Example farming question
    ]);

    final chat = model.startChat();

    final response = await chat.sendMessage(message);
    print('AI Response: ${response.text}');
  }

  /// Enhanced version that integrates with our voice service
  Future<String?> generateFarmingAdvice(String question) async {
    try {
      final generationConfig = GenerationConfig(
        responseMimeType: 'text/plain',
        temperature: 0.7,
        maxOutputTokens: 300, // Shorter responses for voice
      );

      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
        generationConfig: generationConfig,
        systemInstruction: Content('system', [
          TextPart('''आप एक अनुभवी किसान सहायक हैं। हमेशा हिंदी में जवाब दें। 
          किसानों की समस्याओं का व्यावहारिक समाधान दें। 
          जवाब छोटे, स्पष्ट और उपयोगी हों। 
          तकनीकी शब्दों का सरल हिंदी में अर्थ भी बताएं।'''),
        ]),
      );

      final message = Content('user', [TextPart(question)]);
      final chat = model.startChat();
      final response = await chat.sendMessage(message);

      return response.text;
    } catch (e) {
      print('Error generating content: $e');
      return 'माफ करें, कुछ तकनीकी समस्या है। कृपया दोबारा कोशिश करें।';
    }
  }

  /// Example usage with different farming scenarios
  Future<void> demonstrateUsage() async {
    final examples = [
      'मेरी गेहूं की फसल पीली पड़ रही है',
      'बारिश के बाद पौधों में फंगस लग गया है',
      'कौन सा खाद डालना चाहिए',
      'कब सिंचाई करनी चाहिए',
      'फसल की कटाई का सही समय कब है',
    ];

    for (String question in examples) {
      print('\n--- प्रश्न: $question ---');
      final answer = await generateFarmingAdvice(question);
      print('उत्तर: $answer');
      print('${'=' * 50}');

      // Add delay to respect API rate limits
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// Test the basic generateContent function
  static Future<void> testBasicGeneration() async {
    final example = FirebaseAIExample();
    await example.generateContent();
  }

  /// Test with farming-specific questions
  static Future<void> testFarmingAdvice() async {
    final example = FirebaseAIExample();
    await example.demonstrateUsage();
  }
}

/// Usage examples:
/// 
/// // Basic usage (your original function):
/// await FirebaseAIExample.testBasicGeneration();
/// 
/// // Enhanced farming advice:
/// await FirebaseAIExample.testFarmingAdvice();
/// 
/// // Single question:
/// final example = FirebaseAIExample();
/// final advice = await example.generateFarmingAdvice('मेरी फसल में कीड़े हैं');
/// print(advice);
