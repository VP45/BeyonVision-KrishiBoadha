import 'package:flutter_riverpod/flutter_riverpod.dart';

class FarmerData {
  final String? id;
  final String name;
  final String location;
  final String experience;
  final String goals;
  final String crops;
  final String aadhar;

  FarmerData({
    this.id,
    required this.name,
    required this.location,
    required this.experience,
    required this.goals,
    required this.crops,
    required this.aadhar,
  });

  FarmerData copyWith({
    String? id,
    String? name,
    String? location,
    String? experience,
    String? goals,
    String? crops,
    String? aadhar,
  }) {
    return FarmerData(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      experience: experience ?? this.experience,
      goals: goals ?? this.goals,
      crops: crops ?? this.crops,
      aadhar: aadhar ?? this.aadhar,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'experience': experience,
      'goals': goals,
      'crops': crops,
      'aadhar': aadhar,
    };
  }

  factory FarmerData.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmerData(
      id: documentId,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      experience: map['experience'] ?? '',
      goals: map['goals'] ?? '',
      crops: map['crops'] ?? '',
      aadhar: map['aadhar'] ?? '',
    );
  }
}

class FarmerNotifier extends StateNotifier<FarmerData?> {
  FarmerNotifier() : super(null);

  void setFarmerData(FarmerData farmerData) {
    state = farmerData;
  }

  void updateFarmerData({
    String? name,
    String? location,
    String? experience,
    String? goals,
    String? crops,
    String? aadhar,
  }) {
    if (state != null) {
      state = state!.copyWith(
        name: name,
        location: location,
        experience: experience,
        goals: goals,
        crops: crops,
        aadhar: aadhar,
      );
    }
  }

  void clearFarmerData() {
    state = null;
  }
}

final farmerProvider = StateNotifierProvider<FarmerNotifier, FarmerData?>((
  ref,
) {
  return FarmerNotifier();
});
