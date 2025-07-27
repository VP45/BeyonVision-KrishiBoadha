import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/farmer_profile.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _farmersCollection = 'farmers';

  // Save farmer profile to Firestore
  static Future<String> saveFarmerProfile(FarmerProfile profile) async {
    try {
      DocumentReference docRef = await _db.collection(_farmersCollection).add({
        'name': profile.name,
        'phoneNumber': profile.phoneNumber,
        'village': profile.village,
        'district': profile.district,
        'state': profile.state,
        'farmSize': profile.farmSize,
        'cropsGrown': profile.cropsGrown,
        'farmingExperience': profile.farmingExperience,
        'preferredLanguage': profile.preferredLanguage,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error saving farmer profile: $e');
      rethrow;
    }
  }

  // Get farmer profile by ID
  static Future<FarmerProfile?> getFarmerProfile(String farmerId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(_farmersCollection).doc(farmerId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return FarmerProfile.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting farmer profile: $e');
      return null;
    }
  }

  // Update farmer profile
  static Future<void> updateFarmerProfile(
    String farmerId,
    FarmerProfile profile,
  ) async {
    try {
      await _db.collection(_farmersCollection).doc(farmerId).update({
        'name': profile.name,
        'phoneNumber': profile.phoneNumber,
        'village': profile.village,
        'district': profile.district,
        'state': profile.state,
        'farmSize': profile.farmSize,
        'cropsGrown': profile.cropsGrown,
        'farmingExperience': profile.farmingExperience,
        'preferredLanguage': profile.preferredLanguage,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating farmer profile: $e');
      rethrow;
    }
  }

  // Get all farmers (for admin purposes)
  static Future<List<FarmerProfile>> getAllFarmers() async {
    try {
      QuerySnapshot querySnapshot =
          await _db
              .collection(_farmersCollection)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return FarmerProfile.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting all farmers: $e');
      return [];
    }
  }

  // Search farmers by phone number
  static Future<FarmerProfile?> searchFarmerByPhone(String phoneNumber) async {
    try {
      QuerySnapshot querySnapshot =
          await _db
              .collection(_farmersCollection)
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return FarmerProfile.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('Error searching farmer by phone: $e');
      return null;
    }
  }

  // Delete farmer profile
  static Future<void> deleteFarmerProfile(String farmerId) async {
    try {
      await _db.collection(_farmersCollection).doc(farmerId).delete();
    } catch (e) {
      print('Error deleting farmer profile: $e');
      rethrow;
    }
  }
}
