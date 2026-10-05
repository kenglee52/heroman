class Mechanic {
  final String? id;
  final String name;
  final String? lastname;
  final String gender;
  final String birth;
  final String phone;
  final String email;
  final String password;
  final int? experienceYears;
  final String? specialties;
  final bool isActive;
  final String? profile;
  final String province;
  final String district;
  final String village;
  final String? certificate;
  final String job;
  final List? chievements;
  final String serviceArea;
  final String documentType;
  final String documentId;
  final String issue;
  final String expiry;
  final List documentImage;

  Mechanic({
    this.id,
    required this.name,
    this.lastname,
    required this.gender,
    required this.birth,
    required this.phone,
    required this.email,
    required this.password,
    this.experienceYears,
    this.specialties,
    required this.isActive,
    this.profile,
    required this.province,
    required this.district,
    required this.village,
    this.certificate,
    required this.job,
    this.chievements,
    required this.serviceArea,
    required this.documentType,
    required this.documentId,
    required this.issue,
    required this.expiry,
    required this.documentImage,
  });
}
