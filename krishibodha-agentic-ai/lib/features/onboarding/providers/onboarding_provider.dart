import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingStep {
  languageSelection,
  farmerOnboarding,
  mapFarmDetails,
  completed,
}

class OnboardingNotifier extends StateNotifier<OnboardingStep> {
  OnboardingNotifier() : super(OnboardingStep.languageSelection) {
    // Always start from language selection - don't load previous progress
    _resetToLanguageSelection();
  }

  Future<void> _resetToLanguageSelection() async {
    // Always reset to language selection on app start
    state = OnboardingStep.languageSelection;
  }

  Future<void> setOnboardingStep(OnboardingStep step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onboarding_step', step.index);
    state = step;
  }

  Future<void> completeLanguageSelection() async {
    await setOnboardingStep(OnboardingStep.farmerOnboarding);
  }

  Future<void> completeFarmerOnboarding() async {
    await setOnboardingStep(OnboardingStep.mapFarmDetails);
  }

  Future<void> completeMapFarmDetails() async {
    await setOnboardingStep(OnboardingStep.completed);
  }

  Future<void> resetOnboarding() async {
    await setOnboardingStep(OnboardingStep.languageSelection);
  }

  Future<void> clearAllOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_step');
    state = OnboardingStep.languageSelection;
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingStep>((ref) {
      return OnboardingNotifier();
    });
