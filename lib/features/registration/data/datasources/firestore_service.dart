import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/registration_model.dart';

abstract class FirestoreService {
  Future<void> saveRegistration(RegistrationModel registration);
  Future<RegistrationModel?> getRegistration(String userId);
  Future<void> updateRegistration(String userId, Map<String, dynamic> data);
  Future<void> deleteRegistration(String userId);
}

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;
  static const String _collectionName = 'registrations';

  FirestoreServiceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> saveRegistration(RegistrationModel registration) async {
    try {
      // Validate userId is not empty
      if (registration.userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      print('DEBUG: Saving registration to Firestore for userId: ${registration.userId}');

      await _firestore
          .collection(_collectionName)
          .doc(registration.userId)
          .set(registration.toJson());

      print('DEBUG: Registration saved successfully');
    } catch (e) {
      print('DEBUG: Error saving registration: $e');
      throw Exception('Failed to save registration: $e');
    }
  }

  @override
  Future<RegistrationModel?> getRegistration(String userId) async {
    try {
      final doc =
      await _firestore.collection(_collectionName).doc(userId).get();

      if (doc.exists) {
        return RegistrationModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get registration: $e');
    }
  }

  @override
  Future<void> updateRegistration(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update registration: $e');
    }
  }

  @override
  Future<void> deleteRegistration(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete registration: $e');
    }
  }
}