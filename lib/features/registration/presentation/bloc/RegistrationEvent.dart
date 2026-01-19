import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class SubmitRegistrationEvent extends RegistrationEvent {
  final String name;
  final String mobileNo;
  final String companyName;
  final String designation;
  final String address;
  final String gender;
  final String userId;


  const SubmitRegistrationEvent({
    required this.name,
    required this.mobileNo,
    required this.companyName,
    required this.designation,
    required this.address,
    required this.gender,
    required this.userId, // <-- add this
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
  ];
}