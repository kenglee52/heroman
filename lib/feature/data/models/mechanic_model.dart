import 'package:heroman/feature/domain/entities/mechanic.dart';

class MechanicModel extends Mechanic {
  MechanicModel({
    super.id,
    required super.name,
    super.lastname,
    required super.gender,
    required super.birth,
    required super.phone,
    required super.email,
    required super.password,
    super.experienceYears,
    super.specialties,
    required super.isActive,
    super.profile,
    required super.province,
    required super.district,
    required super.village,
    super.certificate,
    required super.job,
    super.chievements,
    required super.serviceArea,
    required super.documentType,
    required super.documentId,
    required super.issue,
    required super.expiry,
    required super.documentImage,
  });

  factory MechanicModel.fromEntity(Mechanic mechanic) {
    return MechanicModel(
      id: mechanic.id,
      name: mechanic.name,
      lastname: mechanic.lastname,
      gender: mechanic.gender,
      birth: mechanic.birth,
      phone: mechanic.phone,
      email: mechanic.email,
      password: mechanic.password,
      experienceYears: mechanic.experienceYears,
      specialties: mechanic.specialties,
      isActive: mechanic.isActive,
      profile: mechanic.profile,
      province: mechanic.province,
      district: mechanic.district,
      village: mechanic.village,
      certificate: mechanic.certificate,
      job: mechanic.job,
      chievements: mechanic.chievements,
      serviceArea: mechanic.serviceArea,
      documentType: mechanic.documentType,
      documentId: mechanic.documentId,
      issue: mechanic.issue,
      expiry: mechanic.expiry,
      documentImage: mechanic.documentImage,
    );
  }

  factory MechanicModel.fromJson(Map<String, dynamic> json) {
    return MechanicModel(
      id: json["_id"]?.toString(),
      name: json["name"]?.toString() ?? '',
      lastname: json["lastname"]?.toString(),
      gender: json["gender"]?.toString() ?? '',
      birth: json["birth"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      email: json["email"]?.toString() ?? '',
      password: json["password"]?.toString() ?? '',
      experienceYears: json["experienceYears"] != null
          ? int.tryParse(json["experienceYears"].toString())
          : null,
      specialties: json["specialties"]?.toString(),
      isActive: json["isActive"] as bool? ?? false,
      profile: json["profile"]?.toString(),
      province: json["province"]?.toString() ?? '',
      district: json["district"]?.toString() ?? '',
      village: json["village"]?.toString() ?? '',
      certificate: json["certificate"]?.toString(),
      job: json["job"]?.toString() ?? '',
      chievements: (json["chievements"] as List?)?.map((e) => e.toString()).toList(),
      serviceArea: json["serviceArea"]?.toString() ?? '',
      documentType: json["documentType"]?.toString() ?? '',
      documentId: json["documentId"]?.toString() ?? '',
      issue: json["issue"]?.toString() ?? '',
      expiry: json["expiry"]?.toString() ?? '',
      documentImage: (json["documentImage"] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "_id": id,
      "name": name,
      "lastname": lastname,
      "gender": gender,
      "birth": birth,
      "phone": phone,
      "email": email,
      "password": password,
      "experienceYears": experienceYears,
      "specialties": specialties,
      "isActive": isActive,
      "profile": profile,
      "province": province,
      "district": district,
      "village": village,
      "certificate": certificate,
      "job": job,
      "chievements": chievements,
      "serviceArea": serviceArea,
      "documentType": documentType,
      "documentId": documentId,
      "issue": issue,
      "expiry": expiry,
      "documentImage": documentImage,
    };
  }
}