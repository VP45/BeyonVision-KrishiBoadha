import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/constants/app_theme.dart';
import 'package:myapp/router/app_router.dart';
import 'package:myapp/features/language/providers/language_provider.dart';
import 'package:myapp/features/language/screens/language_selection_screen_new.dart';
import 'package:myapp/features/navigation/main_navigation_screen.dart';
import 'package:myapp/features/onboarding/providers/onboarding_provider.dart';
import 'package:myapp/features/onboarding/screens/voice_farmer_onboarding_screen.dart';
import 'package:myapp/features/map_screen/screens/map_screen.dart';
import 'package:myapp/providers/global_voice_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Krishibodha',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(languageProvider);
    final onboardingStep = ref.watch(onboardingProvider);

    // Initialize voice service early
    ref.watch(globalVoiceProvider);

    // Step 1: Language Selection
    if (selectedLanguage == null ||
        onboardingStep == OnboardingStep.languageSelection) {
      return const LanguageSelectionScreen();
    }

    // Step 2: Farmer Onboarding
    if (onboardingStep == OnboardingStep.farmerOnboarding) {
      return const VoiceFarmerOnboardingScreen();
    }

    // Step 3: Map Farm Details
    if (onboardingStep == OnboardingStep.mapFarmDetails) {
      return const MapScreen();
    }

    // Step 4: Main App (Onboarding Completed)
    return const MainNavigationScreen();
  }
}
