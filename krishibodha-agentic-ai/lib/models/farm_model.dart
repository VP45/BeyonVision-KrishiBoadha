import 'package:flutter/foundation.dart';

@immutable
class Farm {
  final String id;
  final String name;
  final List<String> crops; // Changed from single cropName to multiple crops
  final String harvestTime;
  final double latitude;
  final double longitude;
  final double area; // in hectares
  final String status;
  final List<String> boundaries; // Polygon coordinates as strings
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Farm({
    required this.id,
    required this.name,
    required this.crops, // Updated to support multiple crops
    required this.harvestTime,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.status,
    required this.boundaries,
    this.imageUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Farm copyWith({
    String? id,
    String? name,
    List<String>? crops,
    String? harvestTime,
    double? latitude,
    double? longitude,
    double? area,
    String? status,
    List<String>? boundaries,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      crops: crops ?? this.crops,
      harvestTime: harvestTime ?? this.harvestTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      status: status ?? this.status,
      boundaries: boundaries ?? this.boundaries,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'crops': crops,
      'harvestTime': harvestTime,
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'status': status,
      'boundaries': boundaries,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String,
      name: json['name'] as String,
      crops: List<String>.from(json['crops'] as List),
      harvestTime: json['harvestTime'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      area: (json['area'] as num).toDouble(),
      status: json['status'] as String,
      boundaries: List<String>.from(json['boundaries'] as List),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Farm && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Farm(id: $id, name: $name, crops: ${crops.join(", ")}, area: $area Ha)';
  }

  // Helper methods for UI
  String get primaryCrop => crops.isNotEmpty ? crops.first : 'No crops';
  String get cropsDisplay => crops.join(', ');
}

// Market price trend data model
@immutable
class MarketPriceTrend {
  final String cropName;
  final List<PricePoint> priceHistory;
  final double currentPrice;
  final double previousPrice;
  final String trend; // 'up', 'down', 'stable'

  const MarketPriceTrend({
    required this.cropName,
    required this.priceHistory,
    required this.currentPrice,
    required this.previousPrice,
    required this.trend,
  });

  double get changePercentage {
    if (previousPrice == 0) return 0;
    return ((currentPrice - previousPrice) / previousPrice) * 100;
  }
}

@immutable
class PricePoint {
  final DateTime date;
  final double price;

  const PricePoint({required this.date, required this.price});
}
