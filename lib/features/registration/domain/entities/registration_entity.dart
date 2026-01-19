import 'package:equatable/equatable.dart';

class RegistrationEntity extends Equatable {
  final String userId;
  final String name;
  final String mobileNo;
  final String companyName;
  final String designation;
  final String address;
  final String gender;
  final DateTime createdAt;

  const RegistrationEntity({
    required this.userId,
    required this.name,
    required this.mobileNo,
    required this.companyName,
    required this.designation,
    required this.address,
    required this.gender,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    mobileNo,
    companyName,
    designation,
    address,
    gender,
    createdAt,
  ];
}