import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/repository/RegistrationRepository.dart';
import '../datasources/firestore_service.dart';
import '../models/registration_model.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final FirestoreService firestoreService;

  RegistrationRepositoryImpl({required this.firestoreService});

  @override
  Future<Either<Failure, void>> submitRegistration({
    required String userId,
    required String name,
    required String mobileNo,
    required String companyName,
    required String designation,
    required String address,
    required String gender,
  }) async {
    try {
      print('========================================');
      print('REGISTRATION REPO: submitRegistration called');
      print('REGISTRATION REPO:  userId = "$userId"');
      print('REGISTRATION REPO:  userId length = ${userId.length}');
      print('REGISTRATION REPO: userId isEmpty = ${userId.isEmpty}');
      print('REGISTRATION REPO: name = "$name"');
      print('REGISTRATION REPO: mobileNo = "$mobileNo"');
      print('REGISTRATION REPO:  companyName = "$companyName"');
      print('REGISTRATION REPO: designation = "$designation"');
      print('REGISTRATION REPO: address = "$address"');
      print('REGISTRATION REPO: gender = "$gender"');
      print('========================================');

      // Validate userId
      if (userId.isEmpty) {
        print('REGISTRATION REPO: ✗ ERROR - userId is empty! ');
        return Left(ServerFailure('User ID is empty.  Please sign in again.'));
      }

      final registration = RegistrationModel(
        userId:  userId,
        name: name,
        mobileNo: mobileNo,
        companyName: companyName,
        designation: designation,
        address: address,
        gender: gender,
        createdAt: DateTime.now(),
      );

      print('REGISTRATION REPO:  RegistrationModel created successfully');
      print('REGISTRATION REPO:  Calling firestoreService.saveRegistration.. .');

      await firestoreService. saveRegistration(registration);

      print('REGISTRATION REPO:  ✓ Registration saved successfully! ');
      return const Right(null);
    } catch (e, stackTrace) {
      print('REGISTRATION REPO: ✗ ERROR - $e');
      print('REGISTRATION REPO: StackTrace - $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegistrationEntity? >> getRegistration(String userId) async {
    try {
      print('REGISTRATION REPO: Getting registration for userId: $userId');

      final registration = await firestoreService.getRegistration(userId);

      if (registration != null) {
        print('REGISTRATION REPO: ✓ Registration found');
      } else {
        print('REGISTRATION REPO: Registration not found');
      }

      return Right(registration);
    } catch (e) {
      print('REGISTRATION REPO:  ✗ ERROR getting registration: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}