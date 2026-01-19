import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/registration_entity.dart';

class RegistrationModel extends RegistrationEntity {
  const RegistrationModel({
    required super.userId,
    required super.name,
    required super.mobileNo,
    required super.companyName,
    required super.designation,
    required super.address,
    required super.gender,
    required super.createdAt,
  });

  factory RegistrationModel.fromEntity(RegistrationEntity entity) {
    return RegistrationModel(
      userId: entity.userId,
      name: entity.name,
      mobileNo: entity.mobileNo,
      companyName: entity.companyName,
      designation: entity.designation,
      address: entity.address,
      gender: entity.gender,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'mobileNo': mobileNo,
      'companyName': companyName,
      'designation': designation,
      'address': address,
      'gender': gender,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      companyName: json['companyName'] ?? '',
      designation: json['designation'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  factory RegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RegistrationModel.fromJson(data);
  }
}