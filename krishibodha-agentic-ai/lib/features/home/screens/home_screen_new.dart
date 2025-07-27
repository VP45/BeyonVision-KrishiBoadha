import 'package:flutter/material.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/constants/app_text_styles.dart';
import 'package:myapp/models/farm_model.dart';
import 'package:myapp/features/farm/screens/farm_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Sample farm data
  List<Farm> get _sampleFarms => [
    Farm(
      id: '1',
      name: 'Farm 1',
      crops: ['Sugarcane', 'Wheat'], // Multiple crops support
      harvestTime: '~4 Months',
      latitude: 23.0225,
      longitude: 72.5714,
      area: 1.2,
      status: 'Good',
      boundaries: ['23.0225,72.5714', '23.0235,72.5724'],
      description: 'Main sugarcane field with drip irrigation system',
      imageUrl: 'assets/images/farm_image.png', // Using Farm_image as requested
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Farm(
      id: '2',
      name: 'Farm 2',
      crops: ['Wheat', 'Mustard'], // Multiple crops
      harvestTime: '~3 Months',
      latitude: 23.0235,
      longitude: 72.5724,
      area: 1.6,
      status: 'Need Water',
      boundaries: ['23.0235,72.5724', '23.0245,72.5734'],
      description: 'Wheat field requiring immediate irrigation',
      imageUrl: 'assets/images/farm_image.png',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Farm(
      id: '3',
      name: 'Farm 3',
      crops: ['Rice', 'Cotton', 'Soybean'], // Multiple crops
      harvestTime: '~5 Months',
      latitude: 23.0245,
      longitude: 72.5734,
      area: 2.6,
      status: 'Good',
      boundaries: ['23.0245,72.5734', '23.0255,72.5744'],
      description: 'Paddy field with excellent growth conditions',
      imageUrl: 'assets/images/farm_image.png',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grey background for top 45% of the screen with light effect
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, AppColors.backgroundSecondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
        // Main content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header with location and notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Madavar, Bengaluru',
                            style: AppTextStyles.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/crop-disease-detection',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Color(0xFF4CAF50),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/map-screen');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.map_outlined,
                              color: AppColors.primaryDark,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Weather Section
                Center(
                  child: Column(
                    children: [
                      // Weather Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.orange[200]!, Colors.blue[200]!],
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/cloud_sun.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.wb_sunny_outlined,
                              size: 40,
                              color: Colors.orange,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Temperature
                      Text(
                        '24°',
                        style: AppTextStyles.counterLarge.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Weather Description
                      Text(
                        'Today is partly sunny day!',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      // Weather Stats Container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeatherStat('77%', 'Humidity'),
                            _buildWeatherStat('< 0.01 in', 'Precipitation'),
                            _buildWeatherStat('6 mph/s', 'Wind Speed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // AI Recommendation Card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/Ai_button_icon.png',
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check our AI recommendation',
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: AppColors.textOnPrimary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'for your fields!',
                              style: AppTextStyles.buttonLarge.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // My Fields Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Fields', style: AppTextStyles.heading2),
                    Text(
                      'See All',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fields Grid
                SizedBox(
                  height: 180, // Reduced height from 240 to 200
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sampleFarms.length,
                    itemBuilder: (context, index) {
                      final farm = _sampleFarms[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < _sampleFarms.length - 1 ? 16 : 0,
                        ),
                        child: _buildFieldCard(
                          context,
                          farm,
                          farm.status == 'Good'
                              ? AppColors.primaryDark
                              : Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard(BuildContext context, Farm farm, Color statusColor) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FarmDetailScreen(farm: farm)),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withAlpha((0.12 * 255).toInt()),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Use farm image if available, otherwise fallback
                    farm.imageUrl != null
                        ? Image.asset(
                          farm.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.green[100]!,
                                    Colors.green[300]!,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.agriculture,
                                size: 40,
                                color: Colors.green,
                              ),
                            );
                          },
                        )
                        : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.green[100]!, Colors.green[300]!],
                            ),
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          farm.status,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Farm Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      farm.name,
                      style: AppTextStyles.heading3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${farm.area} Ha',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
