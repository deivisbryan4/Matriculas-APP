import 'package:flutter/material.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  int recoveryStep = 0; // 0: Login, 1: Email, 2: OTP, 3: New Pass
  bool isLoading = false;

  void login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    // Mock delay
    await Future.delayed(const Duration(seconds: 1));

    if (email.contains('admin')) {
      _currentUser = User(
        id: '1',
        name: 'Admin UNAJ',
        email: email,
        code: 'ADM-001',
        dni: '00000000',
        career: 'Sistemas',
        faculty: 'Ingeniería',
        role: UserRole.adminMaster,
      );
    } else if (email.contains('sec')) {
      _currentUser = User(
        id: '2',
        name: 'Secretaria General',
        email: email,
        code: 'SEC-002',
        dni: '11111111',
        career: 'Gestión Académica',
        faculty: 'Administración',
        role: UserRole.adminSecondary,
      );
    } else {
      _currentUser = User(
        id: '3',
        name: 'Kevin Mamani Quispe',
        email: email,
        code: '2021001',
        dni: '76543210',
        career: 'Ing. de Sistemas',
        faculty: 'Ingeniería',
        role: UserRole.student,
        approvedCredits: 87,
        approvedCourses: 22,
        gpa: 13.4,
        entryYear: 2021,
        phone: '951 234 567',
      );
    }

    isLoading = false;
    recoveryStep = 0;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void setRecoveryStep(int step) {
    recoveryStep = step;
    notifyListeners();
  }
}

class SystemProvider extends ChangeNotifier {
  // Configuración Académica
  int notaMinima = 11;
  int maxCreditosRegular = 22;
  int maxCreditosObservado = 12;
  int maxVecesDesaprobado = 3;

  void updateConfig({int? nota, int? regular, int? observado, int? veces}) {
    if (nota != null) notaMinima = nota;
    if (regular != null) maxCreditosRegular = regular;
    if (observado != null) maxCreditosObservado = observado;
    if (veces != null) maxVecesDesaprobado = veces;
    notifyListeners();
  }

  // Estudiantes
  final List<User> students = [
    User(id: '1', name: 'María Quispe Ramos', email: 'maria@unaj.edu.pe', code: '2022-0142', dni: '72341598', career: 'Ing. de Sistemas', faculty: 'Ingeniería', role: UserRole.student, approvedCredits: 86),
    User(id: '2', name: 'Juan Condori Mamani', email: 'juan@unaj.edu.pe', code: '2021-0078', dni: '45782316', career: 'Contabilidad', faculty: 'Ciencias Contables', role: UserRole.student, approvedCredits: 112),
    User(id: '3', name: 'Ana Puma Flores', email: 'ana@unaj.edu.pe', code: '2023-0031', dni: '89023471', career: 'Administración', faculty: 'Administración', role: UserRole.student, approvedCredits: 44, status: StudentStatus.observado),
    User(id: '4', name: 'Rosa Llano Chura', email: 'rosa@unaj.edu.pe', code: '2020-0205', dni: '67234510', career: 'Derecho', faculty: 'Derecho', role: UserRole.student, approvedCredits: 138),
    User(id: '5', name: 'Carlos Apaza Tito', email: 'carlos@unaj.edu.pe', code: '2022-0189', dni: '54123876', career: 'Ing. de Sistemas', faculty: 'Ingeniería', role: UserRole.student, approvedCredits: 32, status: StudentStatus.inhabilitado),
  ];

  // Cursos
  final List<Course> availableCourses = [
    Course(id: '1', code: 'COD-501', name: 'Cálculo III', credits: 4, cycle: 5, prereq: 'Cálculo II'),
    Course(id: '2', code: 'COD-502', name: 'Probabilidad y Estadística', credits: 3, cycle: 5),
    Course(id: '3', code: 'COD-503', name: 'Estructura de Datos', credits: 3, cycle: 5),
    Course(id: '4', code: 'COD-504', name: 'Física II', credits: 4, cycle: 5, isBlockedByPrereq: true, prereq: 'Física I'),
    Course(id: '5', code: 'COD-505', name: 'Inglés Técnico II', credits: 2, cycle: 5, type: CourseType.electivo),
  ];

  final List<Course> activeCourses = [
    Course(id: '1', code: 'COD-501', name: 'Cálculo III', credits: 4, cycle: 5, teacher: 'Dr. Ramirez', schedule: 'Lun/Mié 8-10am', attendance: 0.92),
    Course(id: '2', code: 'COD-502', name: 'Probabilidad y Estadística', credits: 3, cycle: 5, teacher: 'Mg. Torres', schedule: 'Mar/Jue 10-12pm', attendance: 0.78),
    Course(id: '5', code: 'COD-505', name: 'Inglés Técnico II', credits: 2, cycle: 5, teacher: 'Lic. Flores', schedule: 'Vie 2-4pm', attendance: 0.88),
  ];

  // Pagos
  final List<PaymentVoucher> vouchers = [
    PaymentVoucher(id: '1', studentCode: '2022-0142', studentName: 'María Quispe Ramos', operationNumber: '847523', amount: 380, fileName: 'voucher1.pdf', date: DateTime.now().subtract(const Duration(days: 2))),
    PaymentVoucher(id: '2', studentCode: '2021-0078', studentName: 'Juan Condori Mamani', operationNumber: '239871', amount: 380, fileName: 'voucher2.pdf', date: DateTime.now().subtract(const Duration(days: 3)), status: PaymentStatus.validado),
    PaymentVoucher(id: '3', studentCode: '2024-0031', studentName: 'Ana Puma', operationNumber: '134762', amount: 380, fileName: 'voucher3.pdf', date: DateTime.now().subtract(const Duration(days: 4))),
    PaymentVoucher(id: '4', studentCode: '2021-0205', studentName: 'Rosa Llano', operationNumber: '986531', amount: 380, fileName: 'voucher4.pdf', date: DateTime.now().subtract(const Duration(days: 5)), status: PaymentStatus.rechazado),
  ];

  void validateVoucher(String id, PaymentStatus status) {
    final index = vouchers.indexWhere((v) => v.id == id);
    if (index != -1) {
      vouchers[index].status = status;
      notifyListeners();
    }
  }

  // Matrícula actual del alumno
  int enrollmentStep = 1; // 1: Verificar Pago, 2: Seleccionar Cursos, 3: Confirmar
  List<Course> selectedCourses = [];
  String? uploadedVoucher;

  int get currentCredits => selectedCourses.fold(0, (sum, c) => sum + c.credits);

  void toggleCourse(Course course) {
    if (selectedCourses.any((c) => c.id == course.id)) {
      selectedCourses.removeWhere((c) => c.id == course.id);
    } else {
      selectedCourses.add(course);
    }
    notifyListeners();
  }

  void setEnrollmentStep(int step) {
    enrollmentStep = step;
    notifyListeners();
  }

  void updateUploadedVoucher(String name) {
    uploadedVoucher = name;
    notifyListeners();
  }
}
