import 'package:dartz/dartz.dart';
import '../core/error/failure.dart';
import '../features/registration/data/datasources/firestore_service.dart';
import '../features/registration/data/models/registration_model.dart';
import '../features/registration/domain/entities/registration_entity.dart';
import '../features/registration/domain/repository/RegistrationRepository.dart';

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
      print('DEBUG REPO: submitRegistration called');
      print('DEBUG REPO: userId parameter: "$userId"');
      print('DEBUG REPO: userId length: ${userId.length}');
      print('DEBUG REPO: userId isEmpty: ${userId.isEmpty}');
      print('========================================');

      final registration = RegistrationModel(
        userId: userId,
        name: name,
        mobileNo: mobileNo,
        companyName: companyName,
        designation: designation,
        address: address,
        gender: gender,
        createdAt: DateTime.now(),
      );

      print('DEBUG REPO: RegistrationModel created');
      print('DEBUG REPO: Model userId: "${registration.userId}"');
      print('DEBUG REPO: Calling firestoreService.saveRegistration...');

      await firestoreService.saveRegistration(registration);

      print('DEBUG REPO: Registration saved successfully!');
      return const Right(null);
    } catch (e) {
      print('DEBUG REPO: ERROR - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RegistrationEntity?>> getRegistration(
      String userId) async {
    try {
      final registration = await firestoreService.getRegistration(userId);
      return Right(registration);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}