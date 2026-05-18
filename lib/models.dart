enum UserRole { adminMaster, adminSecondary, student }

enum EnrollmentStatus { pendingPayment, selectingCourses, enrolled }

class User {
  final String id;
  final String name;
  final String email;
  final String code;
  final String career;
  final UserRole role;
  String phone;
  String altEmail;
  EnrollmentStatus enrollmentStatus;
  String paymentOperation;
  String paymentFileName;
  String enrollmentCode;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.code,
    required this.career,
    required this.role,
    this.phone = '',
    this.altEmail = '',
    this.enrollmentStatus = EnrollmentStatus.pendingPayment,
    this.paymentOperation = '',
    this.paymentFileName = '',
    this.enrollmentCode = '',
  });
}

class Course {
  final String id;
  final String name;
  final int credits;
  final int cycle;
  final String prereq;
  final String section;
  final String schedule;
  final int vacancies;
  final bool isMandatoryRetake; // Rojo - Bloqueado
  final bool isBlockedByPrereq; // Naranja - Opacidad baja
  bool isSelected;

  Course({
    required this.id,
    required this.name,
    required this.credits,
    required this.cycle,
    this.prereq = '',
    this.section = 'A',
    this.schedule = 'Lun-Mie 08:00-10:00',
    this.vacancies = 35,
    this.isMandatoryRetake = false,
    this.isBlockedByPrereq = false,
    this.isSelected = false,
  });
}

class EnrollmentRecord {
  final String id;
  final String studentCode;
  final String studentName;
  final String career;
  final String period;
  final String operationNumber;
  final String voucherFile;
  final List<Course> courses;
  final DateTime createdAt;

  EnrollmentRecord({
    required this.id,
    required this.studentCode,
    required this.studentName,
    required this.career,
    required this.period,
    required this.operationNumber,
    required this.voucherFile,
    required this.courses,
    required this.createdAt,
  });

  int get totalCredits =>
      courses.fold(0, (sum, course) => sum + course.credits);
}
