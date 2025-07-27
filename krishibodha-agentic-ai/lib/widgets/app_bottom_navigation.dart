import 'package:flutter/material.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/constants/app_text_styles.dart';
import 'package:myapp/router/app_router.dart';

class AppBottomNavigation extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavigation({Key? key, required this.currentRoute})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.home,
            'Farms',
            currentRoute == AppRouter.home,
            () => _navigateToRoute(context, AppRouter.home),
          ),
          _buildNavItem(
            Icons.bar_chart,
            'AgMarket',
            currentRoute == AppRouter.agmarket,
            () => _navigateToRoute(context, AppRouter.agmarket),
          ),
          const SizedBox(width: 40), // Space for floating action button
          _buildNavItem(
            Icons.account_balance,
            'Schemes',
            currentRoute == AppRouter.schemes,
            () => _navigateToRoute(context, AppRouter.schemes),
          ),
          _buildNavItem(
            Icons.person,
            'Profile',
            currentRoute == AppRouter.profile,
            () => _navigateToRoute(context, AppRouter.profile),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color:
                    isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    if (currentRoute != route) {
      if (route == AppRouter.home) {
        // If going to home, pop all routes and push home
        Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, route);
      }
    }
  }
}

class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRouter.kisanAvatar);
      },
      backgroundColor: Colors.transparent,
      elevation: 8,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            'assets/images/Ai_button_icon.png',
            color: AppColors.textOnPrimary,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.psychology,
                color: AppColors.textOnPrimary,
                size: 24,
              );
            },
          ),
        ),
      ),
    );
  }
}
