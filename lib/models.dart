enum UserRole { adminMaster, adminSecondary, student }

enum StudentStatus { regular, observado, inhabilitado }

enum PaymentStatus { pendiente, validado, rechazado }

enum CourseType { obligatorio, electivo }

class User {
  final String id;
  final String name;
  final String email;
  final String code;
  final String dni;
  final String career;
  final String faculty;
  final UserRole role;
  final StudentStatus status;
  final int approvedCredits;
  final int totalCredits;
  final int approvedCourses;
  final int totalCourses;
  final double gpa;
  final int entryYear;
  final String sede;
  final String? phone;
  final String? altEmail;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.code,
    required this.dni,
    required this.career,
    required this.faculty,
    required this.role,
    this.status = StudentStatus.regular,
    this.approvedCredits = 0,
    this.totalCredits = 220,
    this.approvedCourses = 0,
    this.totalCourses = 40,
    this.gpa = 0.0,
    this.entryYear = 2021,
    this.sede = 'Juliaca',
    this.phone,
    this.altEmail,
  });
}

class Course {
  final String id;
  final String code;
  final String name;
  final int credits;
  final int cycle;
  final CourseType type;
  final String? prereq;
  final String? teacher;
  final String? schedule;
  final double? attendance;
  final bool isMandatoryRetake;
  final bool isBlockedByPrereq;
  bool isSelected;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.cycle,
    this.type = CourseType.obligatorio,
    this.prereq,
    this.teacher,
    this.schedule,
    this.attendance,
    this.isMandatoryRetake = false,
    this.isBlockedByPrereq = false,
    this.isSelected = false,
  });
}

class PaymentVoucher {
  final String id;
  final String studentCode;
  final String studentName;
  final String operationNumber;
  final double amount;
  final String fileName;
  final DateTime date;
  PaymentStatus status;

  PaymentVoucher({
    required this.id,
    required this.studentCode,
    required this.studentName,
    required this.operationNumber,
    required this.amount,
    required this.fileName,
    required this.date,
    this.status = PaymentStatus.pendiente,
  });
}

class AcademicRecord {
  final String courseCode;
  final String courseName;
  final int credits;
  final int grade;
  final int attempts;
  final String semester;

  AcademicRecord({
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.grade,
    required this.attempts,
    required this.semester,
  });

  bool get isApproved => grade >= 11;
}
