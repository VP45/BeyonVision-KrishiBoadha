// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:myapp/features/navigation/main_navigation_screen.dart';
import 'package:myapp/features/agmarket/screens/agmarket_screen.dart';
import 'package:myapp/features/kisan_avatar/screens/kisan_avatar_screen.dart';
import 'package:myapp/features/onboarding/screens/farmer_onboarding_screen.dart';
import 'package:myapp/features/onboarding/screens/multilingual_farmer_onboarding_screen.dart';
import 'package:myapp/features/language/screens/language_selection_screen_new.dart';
import 'package:myapp/features/farm/screens/farm_detail_screen.dart';
import 'package:myapp/features/map_screen/screens/map_screen.dart';
import 'package:myapp/features/common/placeholder_screens.dart';
import 'package:myapp/models/farm_model.dart';

class AppRouter {
  static const String languageSelection = '/language-selection';
  static const String home = '/';
  static const String agmarket = '/agmarket';
  static const String schemes = '/schemes';
  static const String profile = '/profile';
  static const String aiAssistant = '/ai-assistant';
  static const String kisanAvatar = '/kisanAvatar';
  static const String farmerOnboarding = '/farmer-onboarding';
  static const String multilingualFarmerOnboarding =
      '/multilingual-farmer-onboarding';
  static const String farmDetail = '/farm-detail';
  static const String cropDiseaseDetection = '/crop-disease-detection';
  static const String mapScreen = '/map-screen';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case languageSelection:
        return MaterialPageRoute(
          builder: (_) => const LanguageSelectionScreen(),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case agmarket:
        return MaterialPageRoute(builder: (_) => const AgMarketScreen());
      case schemes:
        return MaterialPageRoute(builder: (_) => const SchemesScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case aiAssistant:
        return MaterialPageRoute(builder: (_) => const AIAssistantScreen());
      case kisanAvatar:
        return MaterialPageRoute(builder: (_) => const KisanAvatarScreen());
      case farmerOnboarding:
        return MaterialPageRoute(
          builder: (_) => const FarmerOnboardingScreen(),
        );
      case multilingualFarmerOnboarding:
        return MaterialPageRoute(
          builder: (_) => const MultilingualFarmerOnboardingScreen(),
        );
      case mapScreen:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case cropDiseaseDetection:
        return MaterialPageRoute(
          builder: (_) => const CropDiseaseDetectionScreen(),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}

// Placeholder screens for navigation
class SchemesScreen extends StatelessWidget {
  const SchemesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schemes')),
      body: const Center(child: Text('Schemes Screen')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}

class AIAssistantScreen extends StatelessWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: const Center(child: Text('AI Assistant Screen')),
    );
  }
}

class CropDiseaseDetectionScreen extends StatelessWidget {
  const CropDiseaseDetectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('फसल रोग पहचान')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Crop Disease Detection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'AI-powered crop health analysis',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
