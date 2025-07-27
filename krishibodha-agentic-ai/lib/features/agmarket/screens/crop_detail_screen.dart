import 'package:flutter/material.dart';
import 'package:myapp/constants/app_colors.dart';
import 'package:myapp/features/agmarket/models/crop_model.dart';

class CropDetailScreen extends StatefulWidget {
  final Crop crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  String selectedTimeframe = '7D';
  int selectedTabIndex =
      0; // 0: Trends, 1: Markets, 2: Analysis, 3: AI Insights
  final TextEditingController _questionController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.crop.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Implement more options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Header Card
            _buildCropHeaderCard(),
            const SizedBox(height: 16),

            // Ask Market AI Section
            _buildAskMarketAICard(),
            const SizedBox(height: 16),

            // Tab Bar
            _buildTabBar(),
            const SizedBox(height: 16),

            // Dynamic content based on selected tab
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCropHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crop Name and Hindi Name with better styling
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.grey[100],
                    child: Icon(
                      widget.crop.name == 'Tomato'
                          ? Icons.local_florist
                          : widget.crop.name == 'Wheat'
                          ? Icons.grass
                          : Icons.rice_bowl,
                      color:
                          widget.crop.name == 'Tomato'
                              ? Colors.red[400]
                              : widget.crop.name == 'Wheat'
                              ? Colors.amber[700]
                              : Colors.brown[400],
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.crop.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.crop.hindiName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.crop.lastUpdated,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price and Change with improved styling
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${widget.crop.price.toInt()}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ' /${widget.crop.unit}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      widget.crop.status == 'BULLISH'
                          ? const Color(0xFF00C853)
                          : widget.crop.status == 'BEARISH'
                          ? Colors.red[500]
                          : Colors.orange[500],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.crop.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Price Change and Confidence with improved styling
          Row(
            children: [
              Icon(
                widget.crop.changeDirection == 'up'
                    ? Icons.trending_up
                    : Icons.trending_down,
                color:
                    widget.crop.changeDirection == 'up'
                        ? const Color(0xFF00C853)
                        : Colors.red[500],
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.crop.changeDirection == 'up' ? '+' : ''}${widget.crop.changePercentage.toStringAsFixed(1)}% from yesterday',
                style: TextStyle(
                  color:
                      widget.crop.changeDirection == 'up'
                          ? const Color(0xFF00C853)
                          : Colors.red[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Confidence: ${widget.crop.confidence}%',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAskMarketAICard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ask Market AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText:
                          'Ask about prices, trends, or market insights...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.grey),
                  onPressed: () {
                    // Implement voice input
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement AI query
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Ask',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Trends', 'Markets', 'Analysis', 'AI Insights'];

    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedTabIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTabIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0: // Trends
        return Column(
          children: [
            _buildPriceTrendsCard(),
            const SizedBox(height: 16),
            _buildMarketAnalysisCards(),
          ],
        );
      case 1: // Markets
        return _buildMarketsContent();
      case 2: // Analysis
        return _buildAnalysisContent();
      case 3: // AI Insights
        return _buildAIInsightsContent();
      default:
        return Column(
          children: [
            _buildPriceTrendsCard(),
            const SizedBox(height: 16),
            _buildMarketAnalysisCards(),
          ],
        );
    }
  }

  Widget _buildMarketsContent() {
    return Column(
      children: [
        _buildMarketComparisonCard(),
        const SizedBox(height: 16),
        _buildTransportationAnalysisCard(),
      ],
    );
  }

  Widget _buildMarketComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Market Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Market comparison list
          _buildMarketItem(
            'Delhi APMC',
            '280 km',
            '₹45',
            '+7.1%',
            Colors.green,
          ),
          _buildMarketItem(
            'Mumbai APMC',
            '320 km',
            '₹48',
            '+4.3%',
            Colors.green,
          ),
          _buildMarketItem('Pune APMC', '160 km', '₹42', '-2.1%', Colors.red),
          _buildMarketItem(
            'Nashik APMC',
            '150 km',
            '₹46',
            '+5.7%',
            Colors.green,
          ),
          _buildMarketItem(
            'Kolhapur APMC',
            '90 km',
            '₹44',
            '+2.3%',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(
    String name,
    String distance,
    String price,
    String change,
    Color changeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  distance,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transportation Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // Transport cost card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₹8-12',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
                Text(
                  'per kg transport cost',
                  style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Delivery time card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '2-3 days',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                Text(
                  'average delivery time',
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Wastage card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '5-8%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
                Text(
                  'typical wastage',
                  style: TextStyle(fontSize: 12, color: Colors.orange[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent() {
    return Column(
      children: [
        _buildSeasonalAnalysisCard(),
        const SizedBox(height: 16),
        _buildWeatherImpactAnalysisCard(),
      ],
    );
  }

  Widget _buildSeasonalAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Seasonal Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Seasonal chart
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: SeasonalChartPainter(),
              size: const Size.fromHeight(200),
            ),
          ),

          // Month labels
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec',
                      ]
                      .map(
                        (month) => Text(
                          month,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherImpactAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather Impact Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // Current Weather Factors
          Text(
            'Current Weather Factors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          _buildWeatherFactor('Temperature', '28°C (Optimal)', Colors.green),
          _buildWeatherFactor('Rainfall', '45mm (Good)', Colors.blue),
          _buildWeatherFactor('Humidity', '65% (Normal)', Colors.orange),

          const SizedBox(height: 20),

          // Price Impact Prediction
          Text(
            'Price Impact Prediction',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          _buildPredictionItem(
            'Good weather conditions may stabilize prices',
            Icons.check_circle,
            Colors.green,
          ),
          _buildPredictionItem(
            'Monsoon arrival may affect supply chains',
            Icons.warning,
            Colors.orange,
          ),
          _buildPredictionItem(
            'Temperature rise may increase demand',
            Icons.trending_up,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherFactor(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsContent() {
    return Column(
      children: [
        _buildAIInsightCard(
          '1',
          'Price Expected to Rise',
          'HIGH Impact',
          'Based on weather patterns and demand analysis, prices may increase by 9-12% in the next 2 weeks.',
          '89%',
          Colors.red,
        ),
        const SizedBox(height: 16),
        _buildAIInsightCard(
          '2',
          'Best Selling Window',
          'MEDIUM Impact',
          'Current market conditions suggest selling within the next 3-5 days for optimal returns.',
          '92%',
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildAIInsightCard(
          '3',
          'Supply Shortage Expected',
          'HIGH Impact',
          'Reduced supply from major producing regions may drive prices up by 15-20%.',
          '76%',
          Colors.red,
        ),
        const SizedBox(height: 20),
        _buildRecommendedActionsCard(),
      ],
    );
  }

  Widget _buildAIInsightCard(
    String number,
    String title,
    String impact,
    String description,
    String confidence,
    Color impactColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: impactColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        impact,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[600]),
                    const SizedBox(width: 4),
                    Text(
                      confidence,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lightbulb,
                  size: 20,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recommended Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionItem(
            'Optimal Selling Time',
            'Sell within the next 3-5 days to maximize returns based on current market trends.',
            Icons.schedule,
            Colors.green,
          ),
          _buildActionItem(
            'Best Markets',
            'Consider Delhi APMC or Mumbai APMC for better prices, factoring in transportation costs.',
            Icons.location_on,
            Colors.blue,
          ),
          _buildActionItem(
            'Quality Maintenance',
            'Ensure proper storage and handling to minimize wastage during transportation.',
            Icons.security,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTrendsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Trends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              DropdownButton<String>(
                value: selectedTimeframe,
                underline: Container(),
                items:
                    ['1D', '7D', '1M', '3M', '1Y'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTimeframe = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: _buildPriceChart()),
        ],
      ),
    );
  }

  Widget _buildPriceChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CustomPaint(
        painter: PriceChartPainter(widget.crop.priceTrends),
        size: const Size.fromHeight(200),
      ),
    );
  }

  Widget _buildMarketAnalysisCards() {
    return Column(
      children: [
        _buildAnalysisCard(
          'Market Sentiment',
          'Positive outlook for ${widget.crop.name} prices',
          Icons.trending_up,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          'Supply Analysis',
          'Current supply levels are moderate',
          Icons.inventory,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAnalysisCard(
          'Demand Forecast',
          'High demand expected next week',
          Icons.show_chart,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final List<PriceTrend> priceTrends;

  PriceChartPainter(this.priceTrends);

  @override
  void paint(Canvas canvas, Size size) {
    if (priceTrends.isEmpty) return;

    final paint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = Colors.green.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final maxPrice = priceTrends
        .map((e) => e.price)
        .reduce((a, b) => a > b ? a : b);
    final minPrice = priceTrends
        .map((e) => e.price)
        .reduce((a, b) => a < b ? a : b);
    final priceRange = maxPrice - minPrice;

    for (int i = 0; i < priceTrends.length; i++) {
      final x = (i / (priceTrends.length - 1)) * size.width;
      final y =
          size.height -
          ((priceTrends[i].price - minPrice) / priceRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill;

    for (int i = 0; i < priceTrends.length; i++) {
      final x = (i / (priceTrends.length - 1)) * size.width;
      final y =
          size.height -
          ((priceTrends[i].price - minPrice) / priceRange) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SeasonalChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Sample data for 12 months
    final priceData = [
      2000.0,
      2100.0,
      2300.0,
      2400.0,
      2200.0,
      2000.0,
      1900.0,
      1800.0,
      1900.0,
      2100.0,
      2300.0,
      2200.0,
    ];
    final rainfallData = [
      20.0,
      15.0,
      25.0,
      80.0,
      120.0,
      180.0,
      200.0,
      160.0,
      120.0,
      60.0,
      30.0,
      25.0,
    ];

    // Price line (Green)
    final pricePaint =
        Paint()
          ..color = Colors.green
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final pricePath = Path();

    for (int i = 0; i < priceData.length; i++) {
      final x = (i / (priceData.length - 1)) * width;
      final normalizedPrice = (priceData[i] - 1800) / (2400 - 1800);
      final y = height - (normalizedPrice * height);

      if (i == 0) {
        pricePath.moveTo(x, y);
      } else {
        pricePath.lineTo(x, y);
      }

      // Draw price points
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.green);
    }
    canvas.drawPath(pricePath, pricePaint);

    // Rainfall bars (Light blue)
    final rainfallPaint =
        Paint()
          ..color = Colors.lightBlue.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final barWidth = width / rainfallData.length * 0.6;

    for (int i = 0; i < rainfallData.length; i++) {
      final x = (i / (rainfallData.length - 1)) * width - barWidth / 2;
      final normalizedRainfall = rainfallData[i] / 200; // Max 200mm
      final barHeight = normalizedRainfall * height;

      canvas.drawRect(
        Rect.fromLTWH(x, height - barHeight, barWidth, barHeight),
        rainfallPaint,
      );
    }

    // Legend
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Price legend
    textPainter.text = TextSpan(
      text: '— Price (₹/quintal)',
      style: TextStyle(color: Colors.green, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));

    // Rainfall legend
    textPainter.text = TextSpan(
      text: '█ Rainfall (mm)',
      style: TextStyle(color: Colors.lightBlue, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 30));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
