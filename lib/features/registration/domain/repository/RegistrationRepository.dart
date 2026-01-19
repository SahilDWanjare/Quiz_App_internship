import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/registration_entity.dart';

abstract class RegistrationRepository {
  Future<Either<Failure, void>> submitRegistration({
    required String userId,
    required String name,
    required String mobileNo,
    required String companyName,
    required String designation,
    required String address,
    required String gender,
  });

  Future<Either<Failure, RegistrationEntity?>> getRegistration(String userId);
}