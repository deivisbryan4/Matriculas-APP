enum UserRole { adminMaster, adminSecondary, student }

enum StudentStatus { regular, observado, inhabilitado }

enum PaymentStatus { pendiente, validado, rechazado }

class User {
  final String id;
  final String dni;
  final String nombres;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String email;
  final String? studentCode;
  final UserRole role;
  final String? careerName;
  final String? facultyName;
  final String statusAcademico; // 'ACTIVO', 'OBSERVADO', 'INHABILITADO'
  final int approvedCredits;
  final String? phone;

  User({
    required this.id,
    required this.dni,
    required this.nombres,
    this.apellidoPaterno,
    this.apellidoMaterno,
    required this.email,
    this.studentCode,
    required this.role,
    this.careerName,
    this.facultyName,
    this.statusAcademico = 'ACTIVO',
    this.approvedCredits = 0,
    this.phone,
  });

  // Getters de conveniencia para las pantallas
  String get fullName =>
      '$nombres ${apellidoPaterno ?? ''} ${apellidoMaterno ?? ''}'.trim();

  /// Alias usado por las pantallas
  String get name => fullName;

  /// Código de estudiante con fallback
  String get code => studentCode ?? '—';

  /// Carrera con fallback
  String get career => careerName ?? '—';

  /// Facultad con fallback
  String get faculty => facultyName ?? '—';

  /// Año de ingreso (placeholder — no está en BD)
  String get entryYear => '—';

  /// Sede (placeholder — no está en BD)
  String get sede => '—';

  /// Estado como enum StudentStatus
  StudentStatus get status {
    switch (statusAcademico.toUpperCase()) {
      case 'OBSERVADO':
        return StudentStatus.observado;
      case 'INHABILITADO':
        return StudentStatus.inhabilitado;
      default:
        return StudentStatus.regular;
    }
  }

  /// Total de créditos de la carrera (placeholder)
  int get totalCredits => 220;

  /// Promedio acumulado (placeholder — requiere tabla notas en BD)
  double get gpa => 14.2;

  /// Cursos aprobados (placeholder)
  int get approvedCourses => approvedCredits > 0 ? (approvedCredits ~/ 4) : 0;

  /// Total de cursos de la carrera (placeholder)
  int get totalCourses => 55;

  int get currentCycle {
    if (approvedCredits >= 180) return 10;
    if (approvedCredits >= 160) return 9;
    if (approvedCredits >= 140) return 8;
    if (approvedCredits >= 120) return 7;
    if (approvedCredits >= 100) return 6;
    if (approvedCredits >= 80) return 5;
    if (approvedCredits >= 60) return 4;
    if (approvedCredits >= 40) return 3;
    if (approvedCredits >= 20) return 2;
    return 1;
  }
}

class Course {
  final int id;
  final String code;
  final String name;
  final int credits;
  final int cycle;
  final String type; // 'OBLIGATORIO' | 'ELECTIVO'
  final int theoryHours;
  final int practiceHours;
  final String? prereq;
  final String? teacher;
  final String? schedule;
  final double? attendance;
  final int minRequiredCredits;
  bool isSelected;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.cycle,
    required this.type,
    this.theoryHours = 0,
    this.practiceHours = 0,
    this.prereq,
    this.teacher,
    this.schedule,
    this.attendance,
    this.minRequiredCredits = 0,
    this.isSelected = false,
  });

  /// True si el curso tiene prerequisito pendiente (simplificado)
  bool get isBlockedByPrereq => false;
}

class PaymentVoucher {
  final int id;
  final String studentName;
  final String studentCode;
  final String studentDni;
  final double amount;
  final String operationNumber;
  final String? voucherUrl;
  final String statusStr; // 'PENDIENTE', 'VALIDADO', 'RECHAZADO'
  final DateTime createdAt;

  PaymentVoucher({
    required this.id,
    required this.studentName,
    required this.studentCode,
    this.studentDni = '',
    required this.amount,
    required this.operationNumber,
    this.voucherUrl,
    required String status,
    required this.createdAt,
  }) : statusStr = status;

  /// Alias para compatibilidad con código antiguo
  String get status => statusStr;

  /// Estado como enum PaymentStatus
  PaymentStatus get statusEnum {
    switch (statusStr.toUpperCase()) {
      case 'VALIDADO':
        return PaymentStatus.validado;
      case 'RECHAZADO':
        return PaymentStatus.rechazado;
      default:
        return PaymentStatus.pendiente;
    }
  }
}

class BankTransaction {
  final String operationNumber;
  final String date;
  final double amount;
  final String? clientDni;
  final String? clientName;
  final String type; // 'BANCO_NACION' or 'PAGALO'

  BankTransaction({
    required this.operationNumber,
    required this.date,
    required this.amount,
    this.clientDni,
    this.clientName,
    required this.type,
  });
}


class AcademicRecord {
  final String courseCode;
  final String courseName;
  final int credits;
  final double grade;
  final int attempts;
  final String status; // 'APROBADO', 'DESAPROBADO'
  final String? semester;

  AcademicRecord({
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.grade,
    required this.attempts,
    required this.status,
    this.semester,
  });

  bool get isApproved => grade >= 11;
}
