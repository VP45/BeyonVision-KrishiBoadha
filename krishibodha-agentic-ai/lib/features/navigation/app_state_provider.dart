import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/language/providers/language_provider.dart';

// Provider to track onboarding completion
class OnboardingStatusNotifier extends StateNotifier<bool> {
  OnboardingStatusNotifier() : super(false) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboarding_completed') ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    state = false;
  }
}

final onboardingStatusProvider =
    StateNotifierProvider<OnboardingStatusNotifier, bool>((ref) {
      return OnboardingStatusNotifier();
    });

// App state provider to determine which screen to show
class AppState {
  final String? selectedLanguage;
  final bool onboardingCompleted;

  AppState({required this.selectedLanguage, required this.onboardingCompleted});

  AppScreenState get screenState {
    if (selectedLanguage == null) {
      return AppScreenState.languageSelection;
    } else if (!onboardingCompleted) {
      return AppScreenState.onboarding;
    } else {
      return AppScreenState.home;
    }
  }
}

enum AppScreenState { languageSelection, onboarding, home }

final appStateProvider = Provider<AppState>((ref) {
  final selectedLanguage = ref.watch(languageProvider);
  final onboardingCompleted = ref.watch(onboardingStatusProvider);

  return AppState(
    selectedLanguage: selectedLanguage,
    onboardingCompleted: onboardingCompleted,
  );
});
