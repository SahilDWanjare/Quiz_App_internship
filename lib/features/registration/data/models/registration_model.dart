import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/registration_entity.dart';

class RegistrationModel extends RegistrationEntity {
  const RegistrationModel({
    required super. userId,
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
      userId:  entity.userId,
      name: entity. name,
      mobileNo: entity. mobileNo,
      companyName:  entity.companyName,
      designation:  entity.designation,
      address: entity. address,
      gender: entity.gender,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name':  name,
      'mobileNo': mobileNo,
      'companyName':  companyName,
      'designation': designation,
      'address': address,
      'gender': gender,
      'createdAt':  Timestamp.fromDate(createdAt),
      'updatedAt':  Timestamp.fromDate(DateTime.now()),
    };
  }

  factory RegistrationModel. fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      userId: json['userId'] as String?  ?? '',
      name: json['name'] as String?  ?? '',
      mobileNo: json['mobileNo'] as String? ?? '',
      companyName:  json['companyName'] as String? ??  '',
      designation:  json['designation'] as String? ?? '',
      address: json['address'] as String?  ?? '',
      gender: json['gender'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  factory RegistrationModel. fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?  ?? {};
    return RegistrationModel. fromJson(data);
  }

  RegistrationModel copyWith({
    String? userId,
    String? name,
    String? mobileNo,
    String? companyName,
    String? designation,
    String?  address,
    String? gender,
    DateTime? createdAt,
  }) {
    return RegistrationModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this. mobileNo,
      companyName:  companyName ?? this.companyName,
      designation: designation ?? this.designation,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      createdAt: createdAt ??  this.createdAt,
    );
  }
}