import 'package:flutter/material.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/features/agmarket/models/crop_model.dart';
import 'package:myapp/features/agmarket/screens/crop_detail_screen.dart';

class AgMarketScreen extends StatefulWidget {
  const AgMarketScreen({super.key});

  @override
  State<AgMarketScreen> createState() => _AgMarketScreenState();
}

class _AgMarketScreenState extends State<AgMarketScreen> {
  int _selectedIndex = 1; // Start with AgMarket tab (index 1)

  // Sample crop data
  final List<Crop> _sampleCrops = [
    Crop(
      name: 'Tomato',
      hindiName: 'टमाटर',
      price: 45,
      unit: 'kg',
      changePercentage: 7.1,
      changeDirection: 'up',
      lastUpdated: 'Updated 2 minutes ago',
      confidence: 87,
      status: 'BULLISH',
      priceTrends: [
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 6)),
          price: 35,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 5)),
          price: 38,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 4)),
          price: 32,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 3)),
          price: 42,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 2)),
          price: 48,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 1)),
          price: 45,
        ),
        PriceTrend(date: DateTime.now(), price: 45),
      ],
    ),
    Crop(
      name: 'Wheat',
      hindiName: 'गेहूं',
      price: 31,
      unit: 'kg',
      changePercentage: 2.5,
      changeDirection: 'up',
      lastUpdated: 'Updated 5 minutes ago',
      confidence: 92,
      status: 'STABLE',
      priceTrends: [
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 6)),
          price: 29,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 5)),
          price: 30,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 4)),
          price: 29,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 3)),
          price: 31,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 2)),
          price: 30,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 1)),
          price: 31,
        ),
        PriceTrend(date: DateTime.now(), price: 31),
      ],
    ),
    Crop(
      name: 'Rice',
      hindiName: 'चावल',
      price: 40,
      unit: 'kg',
      changePercentage: 3.2,
      changeDirection: 'up',
      lastUpdated: 'Updated 1 minute ago',
      confidence: 89,
      status: 'BULLISH',
      priceTrends: [
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 6)),
          price: 38,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 5)),
          price: 37,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 4)),
          price: 39,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 3)),
          price: 38,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 2)),
          price: 39,
        ),
        PriceTrend(
          date: DateTime.now().subtract(const Duration(days: 1)),
          price: 40,
        ),
        PriceTrend(date: DateTime.now(), price: 40),
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildFarmsTab(),
            _buildAgMarketTab(),
            _buildSchemesTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Farms'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'AgMarket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Schemes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryDark.withAlpha((0.8 * 255).toInt()),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withAlpha((0.4 * 255).toInt()),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(10, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to Kisan Avatar (AI Assistant)
            Navigator.pushNamed(context, '/kisanAvatar');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.five_k, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildFarmsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.agriculture, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text(
            'Farms Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Farm management content will go here',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAgMarketTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and Notification Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // App Title with marketplace icon
              Row(children: [const SizedBox(width: 12)]),
              const SizedBox(height: 16),
              // Search and Notification Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 46,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey[800],
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Categories section
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildCategoryItem(
                        'Crop Seeds',
                        Icons.grass,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildCategoryItem(
                        'Micro Nutrients',
                        Icons.science,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildCategoryItem(
                        'Soil Fertilizers',
                        Icons.eco,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildCategoryItem(
                        'Fungicide Lotion',
                        Icons.water_drop,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildCategoryItem(
                        'Crop Seeds',
                        Icons.grass,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildCategoryItem(
                        'Micro Nutrients',
                        Icons.science,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildCategoryItem(
                        'Herbicide Liquid',
                        Icons.water,
                        Colors.white,
                        AppColors.primaryDark,
                      ),
                      _buildSeeMoreItem(),
                    ],
                  ),
                ),

                // Crops section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Crops',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Crop price cards
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _sampleCrops.length,
                    itemBuilder: (context, index) {
                      final crop = _sampleCrops[index];
                      return _buildCropPriceCard(crop);
                    },
                  ),
                ),

                // Fertilizers section
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Fertilizers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fertilizer price cards
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildPriceCard(
                        'Rohin',
                        'Rs. 162/ml',
                        Colors.green[100]!,
                        Colors.green[700]!,
                      ),
                      _buildPriceCard(
                        'Sahib',
                        'Rs. 123/ml',
                        Colors.pink[50]!,
                        Colors.pink[300]!,
                      ),
                      _buildPriceCard(
                        'Villo',
                        'Rs. 145/ml',
                        Colors.orange[50]!,
                        Colors.orange[400]!,
                      ),
                    ],
                  ),
                ),

                // Discount banner - Zepto style for farmers
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green[400]!, Colors.green[600]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withAlpha((0.3 * 255).toInt()),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: CustomPaint(painter: PatternPainter()),
                          ),
                          // Main content
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[600],
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: const Text(
                                          'FARMER SAVER',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Text(
                                            'UPTO ',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '25%',
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.yellow[300],
                                              shadows: const [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Text(
                                        'OFF',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'On Fertilizers & Seeds',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[50],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(
                                        (0.15 * 255).toInt(),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(
                                          (0.3 * 255).toInt(),
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.eco,
                                            size: 28,
                                            color: Colors.yellow[300],
                                          ),
                                          const SizedBox(height: 3),
                                          Icon(
                                            Icons.agriculture,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'SAVE NOW',
                                              style: TextStyle(
                                                fontSize: 6,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Decorative elements
                          Positioned(
                            top: 6,
                            right: 14,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.yellow[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 20,
                            child: Container(
                              width: 2,
                              height: 2,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(
                                  (0.7 * 255).toInt(),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSchemesTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Schemes Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Government schemes content will go here',
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
          Icon(Icons.person, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text(
            'Profile Tab',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'User profile content will go here',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow:
                  bgColor == Colors.white
                      ? [
                        BoxShadow(
                          color: Colors.grey.withAlpha((0.1 * 255).toInt()),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                      : null,
            ),
            child: Icon(icon, size: 36, color: iconColor),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[800]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeMoreItem() {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              'See More',
              style: TextStyle(fontSize: 11, color: Colors.grey[800]),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropPriceCard(Crop crop) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CropDetailScreen(crop: crop)),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crop name
              Text(
                crop.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                crop.hindiName,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),

              // Price
              Row(
                children: [
                  Text(
                    '${crop.formattedPrice}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '/${crop.unit}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Price change
              Row(
                children: [
                  Icon(
                    crop.changeDirection == 'up'
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color:
                        crop.changeDirection == 'up'
                            ? Colors.green
                            : Colors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${crop.changeDirection == 'up' ? '+' : ''}${crop.changePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color:
                          crop.changeDirection == 'up'
                              ? Colors.green
                              : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(
    String name,
    String price,
    Color bgColor,
    Color chartColor,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.15 * 255).toInt()),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 40),
                painter: ChartPainter(chartColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple chart painter to create line chart
class ChartPainter extends CustomPainter {
  final Color lineColor;

  ChartPainter(this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();

    // Creating a simple chart path
    path.moveTo(0, size.height * 0.5);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.4,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.2,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pattern painter for discount banner background
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.white.withAlpha((0.1 * 255).toInt())
          ..style = PaintingStyle.fill;

    // Draw dots pattern
    for (double x = 20; x < size.width; x += 40) {
      for (double y = 20; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }

    // Draw some decorative lines
    final linePaint =
        Paint()
          ..color = Colors.white.withAlpha((0.15 * 255).toInt())
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.3),
      linePaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.7),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
