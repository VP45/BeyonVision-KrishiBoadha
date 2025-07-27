class Crop {
  final String name;
  final String hindiName;
  final double price;
  final String unit;
  final double changePercentage;
  final String changeDirection; // 'up' or 'down'
  final String lastUpdated;
  final int confidence;
  final List<PriceTrend> priceTrends;
  final String status; // 'BULLISH', 'BEARISH', 'STABLE'

  Crop({
    required this.name,
    required this.hindiName,
    required this.price,
    required this.unit,
    required this.changePercentage,
    required this.changeDirection,
    required this.lastUpdated,
    required this.confidence,
    required this.priceTrends,
    required this.status,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      name: json['name'] ?? '',
      hindiName: json['hindiName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      changePercentage: (json['changePercentage'] ?? 0).toDouble(),
      changeDirection: json['changeDirection'] ?? 'up',
      lastUpdated: json['lastUpdated'] ?? '',
      confidence: json['confidence'] ?? 0,
      priceTrends:
          (json['priceTrends'] as List<dynamic>?)
              ?.map((e) => PriceTrend.fromJson(e))
              .toList() ??
          [],
      status: json['status'] ?? 'STABLE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hindiName': hindiName,
      'price': price,
      'unit': unit,
      'changePercentage': changePercentage,
      'changeDirection': changeDirection,
      'lastUpdated': lastUpdated,
      'confidence': confidence,
      'priceTrends': priceTrends.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }

  // Helper method to get formatted price
  String get formattedPrice => '₹${price.toInt()}';

  // Helper method to get price change text
  String get priceChangeText =>
      '${changeDirection == 'up' ? '+' : ''}${changePercentage.toStringAsFixed(1)}% from yesterday';

  // Helper method to get confidence text
  String get confidenceText => 'Confidence: $confidence%';
}

class PriceTrend {
  final DateTime date;
  final double price;

  PriceTrend({required this.date, required this.price});

  factory PriceTrend.fromJson(Map<String, dynamic> json) {
    return PriceTrend(
      date: DateTime.parse(json['date']),
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'price': price};
  }
}
