import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repository/RegistrationRepository.dart';

class SubmitRegistrationUseCase {
  final RegistrationRepository repository;

  SubmitRegistrationUseCase(this.repository);

  Future<Either<Failure, void>> call(RegistrationParams params) async {
    return await repository.submitRegistration(
      userId: params.userId,
      name: params.name,
      mobileNo: params.mobileNo,
      companyName: params.companyName,
      designation: params.designation,
      address: params.address,
      gender: params.gender,
       // <-- pass actual userId
    );
  }
}

class RegistrationParams {
  final String name;
  final String mobileNo;
  final String companyName;
  final String designation;
  final String address;
  final String gender;
  final String userId; // <-- add this

  RegistrationParams({
    required this.name,
    required this.mobileNo,
    required this.companyName,
    required this.designation,
    required this.address,
    required this.gender,
    required this.userId, // <-- make it required
  });
}
