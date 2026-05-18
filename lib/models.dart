enum UserRole { adminMaster, adminSecondary, student }

class User {
  final String id;
  final String name;
  final String email;
  final String code;
  final String career;
  final UserRole role;
  String phone;
  String altEmail;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.code,
    required this.career,
    required this.role,
    this.phone = '',
    this.altEmail = '',
  });
}

class Course {
  final String id;
  final String name;
  final int credits;
  final int cycle;
  final String prereq;
  final bool isMandatoryRetake; // Rojo - Bloqueado
  final bool isBlockedByPrereq; // Naranja - Opacidad baja
  bool isSelected;

  Course({
    required this.id,
    required this.name,
    required this.credits,
    required this.cycle,
    this.prereq = '',
    this.isMandatoryRetake = false,
    this.isBlockedByPrereq = false,
    this.isSelected = false,
  });
}

