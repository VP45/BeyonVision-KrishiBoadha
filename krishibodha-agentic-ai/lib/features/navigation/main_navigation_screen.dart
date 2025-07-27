import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/features/home/screens/home_screen_new.dart';
import 'package:myapp/features/agmarket/screens/agmarket_screen.dart';
import 'package:myapp/widgets/krishi_voice_widget.dart';
import 'package:myapp/services/krishi_voice_assistant.dart';
import 'package:myapp/features/language/providers/language_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0; // Start with Farms tab (index 0)

  @override
  void initState() {
    super.initState();

    // Initialize Krishi voice assistant when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeKrishiAssistant();
    });
  }

  Future<void> _initializeKrishiAssistant() async {
    final language = ref.read(languageProvider) ?? 'hi';
    final krishiAssistant = ref.read(krishiVoiceAssistantProvider);
    await krishiAssistant.initialize(language);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for navigation commands from Krishi
    ref.listen<AsyncValue<KrishiNavigationCommand>>(krishiCommandProvider, (
      previous,
      next,
    ) {
      next.whenData((command) {
        _handleKrishiCommand(command);
      });
    });

    return KrishiVoiceWidget(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              const HomeScreen(), // Farms tab
              const AgMarketScreen(), // AgMarket tab
              _buildSchemesTab(),
              _buildProfileTab(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: BottomAppBar(
            height: 70,
            notchMargin: 6.0,
            shape: const CircularNotchedRectangle(),
            color: Colors.white,
            elevation: 8,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildNavItem(Icons.home, 'Farms', 0)),
                Expanded(child: _buildNavItem(Icons.bar_chart, 'AgMarket', 1)),
                const SizedBox(
                  width: 32,
                ), // Space for the floating action button
                Expanded(
                  child: _buildNavItem(Icons.account_balance, 'Schemes', 2),
                ),
                Expanded(child: _buildNavItem(Icons.person, 'Profile', 3)),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/kisanAvatar');
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: ClipOval(
              child: Image.asset(
                'assets/images/KissanAvatar.png',
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.mic, color: Colors.white, size: 24);
                },
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  void _handleKrishiCommand(KrishiNavigationCommand command) {
    switch (command) {
      case KrishiNavigationCommand.home:
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case KrishiNavigationCommand.agmarket:
        setState(() {
          _selectedIndex = 1;
        });
        break;
      case KrishiNavigationCommand.schemes:
        setState(() {
          _selectedIndex = 2;
        });
        break;
      case KrishiNavigationCommand.profile:
        setState(() {
          _selectedIndex = 3;
        });
        break;
      case KrishiNavigationCommand.kisanAvatar:
        Navigator.pushNamed(context, '/kisan-avatar');
        break;
      default:
        break;
    }
  }

  Widget _buildSchemesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 64, color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Government Schemes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 64, color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage your profile',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryDark : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? AppColors.primaryDark : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
