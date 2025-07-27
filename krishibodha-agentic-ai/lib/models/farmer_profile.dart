class FarmerProfile {
  final String? id;
  final String? name;
  final String? phoneNumber;
  final String? village;
  final String? district;
  final String? state;
  final double? farmSize;
  final List<String> cropsGrown;
  final int? farmingExperience;
  final String? preferredLanguage;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? goals;
  final List<String> crops;
  final String? aadharNumber;
  final bool isComplete;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FarmerProfile({
    this.id,
    this.name,
    this.phoneNumber,
    this.village,
    this.district,
    this.state,
    this.farmSize,
    this.cropsGrown = const [],
    this.farmingExperience,
    this.preferredLanguage,
    this.latitude,
    this.longitude,
    this.description,
    this.goals,
    this.crops = const [],
    this.aadharNumber,
    this.isComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  FarmerProfile copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? village,
    String? district,
    String? state,
    double? farmSize,
    List<String>? cropsGrown,
    int? farmingExperience,
    String? preferredLanguage,
    double? latitude,
    double? longitude,
    String? description,
    String? goals,
    List<String>? crops,
    String? aadharNumber,
    bool? isComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      farmSize: farmSize ?? this.farmSize,
      cropsGrown: cropsGrown ?? this.cropsGrown,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      goals: goals ?? this.goals,
      crops: crops ?? this.crops,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'village': village,
      'district': district,
      'state': state,
      'farmSize': farmSize,
      'cropsGrown': cropsGrown,
      'farmingExperience': farmingExperience,
      'preferredLanguage': preferredLanguage,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'goals': goals,
      'crops': crops,
      'aadharNumber': aadharNumber,
      'isComplete': isComplete,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      village: json['village'],
      district: json['district'],
      state: json['state'],
      farmSize: json['farmSize']?.toDouble(),
      cropsGrown: List<String>.from(json['cropsGrown'] ?? []),
      farmingExperience: json['farmingExperience'],
      preferredLanguage: json['preferredLanguage'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      description: json['description'],
      goals: json['goals'],
      crops: List<String>.from(json['crops'] ?? []),
      aadharNumber: json['aadharNumber'],
      isComplete: json['isComplete'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  factory FarmerProfile.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return FarmerProfile(
      id: documentId,
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      village: data['village'],
      district: data['district'],
      state: data['state'],
      farmSize: data['farmSize']?.toDouble(),
      cropsGrown: List<String>.from(data['cropsGrown'] ?? []),
      farmingExperience: data['farmingExperience'],
      preferredLanguage: data['preferredLanguage'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      description: data['description'],
      goals: data['goals'],
      crops: List<String>.from(data['crops'] ?? []),
      aadharNumber: data['aadharNumber'],
      isComplete: data['isComplete'] ?? false,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as dynamic).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as dynamic).toDate()
              : null,
    );
  }

  bool get hasBasicInfo => name != null && name!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasGoals => goals != null && goals!.isNotEmpty;
  bool get hasCrops => crops.isNotEmpty;
  bool get hasAadhar => aadharNumber != null && aadharNumber!.isNotEmpty;

  double get completionPercentage {
    int completedFields = 0;
    int totalFields = 6;

    if (hasBasicInfo) completedFields++;
    if (hasLocation) completedFields++;
    if (hasDescription) completedFields++;
    if (hasGoals) completedFields++;
    if (hasCrops) completedFields++;
    if (hasAadhar) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  @override
  String toString() {
    return 'FarmerProfile(name: $name, location: ($latitude, $longitude), description: $description, goals: $goals, crops: $crops, aadhar: $aadharNumber, complete: $isComplete)';
  }
}

enum OnboardingStep {
  welcome,
  name,
  location,
  description,
  goals,
  crops,
  aadhar,
  summary,
  completed,
}

extension OnboardingStepExtension on OnboardingStep {
  String get prompt {
    switch (this) {
      case OnboardingStep.welcome:
        return '''नमस्कार! मैं आपका किसान मित्र हूं। आज मैं आपकी जानकारी लूंगा ताकि मैं आपकी बेहतर सेवा कर सकूं। आइए शुरू करते हैं।''';
      case OnboardingStep.name:
        return '''पहले मुझे बताइए, आपका नाम क्या है? कृपया अपना पूरा नाम बताएं।''';
      case OnboardingStep.location:
        return '''धन्यवाद! अब मुझे आपका स्थान चाहिए। कृपया GPS की अनुमति दें या अपना पता बताएं।''';
      case OnboardingStep.description:
        return '''अब मुझे अपने बारे में बताइए। आप कितने समय से खेती कर रहे हैं? आपका अनुभव कैसा है? उदाहरण: मैं 10 साल से खेती कर रहा हूं।''';
      case OnboardingStep.goals:
        return '''बहुत बढ़िया! अब बताइए कि आपके खेती के लक्ष्य क्या हैं? आप क्या हासिल करना चाहते हैं? जैसे: अधिक आय या बेहतर फसल।''';
      case OnboardingStep.crops:
        return '''अच्छा! अब बताइए कि आप कौन सी फसलें उगाते हैं या उगाना चाहते हैं? उदाहरण: गेहूं, धान, या सब्जियां।''';
      case OnboardingStep.aadhar:
        return '''अंत में, कृपया अपना 12 अंकों का आधार नंबर बताएं। यह आपकी पहचान के लिए जरूरी है। केवल नंबर बोलें।''';
      case OnboardingStep.summary:
        return '''बहुत बढ़िया! आपकी सभी जानकारी मिल गई है। क्या यह सभी जानकारी सही है? हां या नहीं में जवाब दें।''';
      case OnboardingStep.completed:
        return '''धन्यवाद! आपकी प्रोफाइल तैयार हो गई है। अब मैं आपकी खेती में मदद करने के लिए तैयार हूं।''';
    }
  }

  String get title {
    switch (this) {
      case OnboardingStep.welcome:
        return 'स्वागत है';
      case OnboardingStep.name:
        return 'नाम';
      case OnboardingStep.location:
        return 'स्थान';
      case OnboardingStep.description:
        return 'विवरण';
      case OnboardingStep.goals:
        return 'लक्ष्य';
      case OnboardingStep.crops:
        return 'फसलें';
      case OnboardingStep.aadhar:
        return 'आधार नंबर';
      case OnboardingStep.summary:
        return 'सारांश';
      case OnboardingStep.completed:
        return 'पूर्ण';
    }
  }
}
