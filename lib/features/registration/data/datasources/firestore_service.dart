import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/registration_model.dart';

abstract class FirestoreService {
  Future<void> saveRegistration(RegistrationModel registration);
  Future<RegistrationModel? > getRegistration(String userId);
  Future<void> updateRegistration(String userId, Map<String, dynamic> data);
  Future<void> deleteRegistration(String userId);
  Future<bool> checkRegistrationExists(String userId);
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
      if (registration.userId. isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      print('========================================');
      print('FIRESTORE SERVICE: Saving registration');
      print('FIRESTORE SERVICE: userId = "${registration.userId}"');
      print('FIRESTORE SERVICE: name = "${registration.name}"');
      print('FIRESTORE SERVICE: mobileNo = "${registration.mobileNo}"');
      print('FIRESTORE SERVICE: companyName = "${registration.companyName}"');
      print('FIRESTORE SERVICE:  designation = "${registration.designation}"');
      print('FIRESTORE SERVICE: address = "${registration.address}"');
      print('FIRESTORE SERVICE: gender = "${registration.gender}"');
      print('========================================');

      final data = registration.toJson();
      print('FIRESTORE SERVICE: Data to save = $data');

      await _firestore
          .collection(_collectionName)
          . doc(registration.userId)
          .set(data);

      print('FIRESTORE SERVICE: ✓ Registration saved successfully! ');

      // Verify the save was successful
      final verifyDoc = await _firestore
          .collection(_collectionName)
          .doc(registration.userId)
          .get();

      if (verifyDoc.exists) {
        print('FIRESTORE SERVICE:  ✓ Verified - Document exists in Firestore');
      } else {
        print('FIRESTORE SERVICE: ✗ Warning - Document not found after save');
      }
    } catch (e, stackTrace) {
      print('FIRESTORE SERVICE: ✗ ERROR saving registration');
      print('FIRESTORE SERVICE: Error: $e');
      print('FIRESTORE SERVICE: StackTrace: $stackTrace');
      throw Exception('Failed to save registration: $e');
    }
  }

  @override
  Future<RegistrationModel?> getRegistration(String userId) async {
    try {
      print('FIRESTORE SERVICE: Getting registration for userId: $userId');

      final doc = await _firestore. collection(_collectionName).doc(userId).get();

      if (doc. exists) {
        print('FIRESTORE SERVICE: ✓ Registration found');
        return RegistrationModel. fromFirestore(doc);
      }

      print('FIRESTORE SERVICE:  Registration not found');
      return null;
    } catch (e) {
      print('FIRESTORE SERVICE:  ✗ ERROR getting registration:  $e');
      throw Exception('Failed to get registration: $e');
    }
  }

  @override
  Future<void> updateRegistration(String userId, Map<String, dynamic> data) async {
    try {
      print('FIRESTORE SERVICE: Updating registration for userId: $userId');

      await _firestore.collection(_collectionName).doc(userId).update(data);

      print('FIRESTORE SERVICE:  ✓ Registration updated successfully');
    } catch (e) {
      print('FIRESTORE SERVICE:  ✗ ERROR updating registration: $e');
      throw Exception('Failed to update registration: $e');
    }
  }

  @override
  Future<void> deleteRegistration(String userId) async {
    try {
      print('FIRESTORE SERVICE: Deleting registration for userId: $userId');

      await _firestore.collection(_collectionName).doc(userId).delete();

      print('FIRESTORE SERVICE: ✓ Registration deleted successfully');
    } catch (e) {
      print('FIRESTORE SERVICE: ✗ ERROR deleting registration: $e');
      throw Exception('Failed to delete registration: $e');
    }
  }

  @override
  Future<bool> checkRegistrationExists(String userId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('FIRESTORE SERVICE: ✗ ERROR checking registration: $e');
      return false;
    }
  }
}