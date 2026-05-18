import 'package:flutter/material.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  int recoveryStep = 0; // 0: Login, 1: Email, 2: OTP, 3: New Pass

  // Mock data for Admin Padrón
  List<User> students = [
    User(id: '1001', name: 'JUAN PEREZ GARCIA', email: 'jperez@unaj.edu.pe', code: '20211001', career: 'Ingeniería de Sistemas', role: UserRole.student),
    User(id: '1002', name: 'MARIA LOPEZ DIAZ', email: 'mlopez@unaj.edu.pe', code: '20211002', career: 'Medicina Humana', role: UserRole.student),
    User(id: '1003', name: 'CARLOS RUIZ LUNA', email: 'cruiz@unaj.edu.pe', code: '20211003', career: 'Derecho', role: UserRole.student),
  ];

  void login(String email, String password) {
    if (email.contains('admin')) {
      _currentUser = User(
        id: '1', name: 'ADMIN MASTER', email: email, code: 'ADM-001', career: 'Sistemas', role: UserRole.adminMaster
      );
    } else if (email.contains('sec')) {
      _currentUser = User(
        id: '2', name: 'GESTOR ACADEMICO', email: email, code: 'SEC-002', career: 'Administración', role: UserRole.adminSecondary
      );
    } else {
      _currentUser = User(
        id: '3', name: 'ALUMNO PRUEBA UNAJ', email: email, code: '20230045', career: 'Ingeniería de Sistemas', role: UserRole.student
      );
    }
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

  void addStudent(User user) {
    students.add(user);
    notifyListeners();
  }
}

class EnrollmentProvider extends ChangeNotifier {
  String? _paymentFileName;
  String? get paymentFileName => _paymentFileName;
  
  String _operationNumber = '';
  String get operationNumber => _operationNumber;

  bool _isPaymentValidated = false;
  bool get isPaymentValidated => _isPaymentValidated;

  int _selectedCycle = 1;
  int get selectedCycle => _selectedCycle;

  final List<Course> _allCourses = [
    // 0701 - Ingeniería de Software y Sistemas (Ciclo 1)
    Course(id: '0701-101', name: 'Introducción a la Programación', credits: 4, cycle: 1, isMandatoryRetake: true, isSelected: true),
    Course(id: '0701-102', name: 'Cálculo I', credits: 5, cycle: 1),
    Course(id: '0701-103', name: 'Matemática Discreta', credits: 3, cycle: 1),
    // Ciclo 2
    Course(id: '0701-201', name: 'Algoritmos y Estructuras de Datos', credits: 4, cycle: 2),
    Course(id: '0701-202', name: 'Física I', credits: 4, cycle: 2, isBlockedByPrereq: true, prereq: 'MAT-102'),
    // Ciclo 3
    Course(id: '0701-301', name: 'Arquitectura de Software', credits: 5, cycle: 3),
    Course(id: '0701-302', name: 'Bases de Datos I', credits: 4, cycle: 3),
  ];

  final List<String> escuelasProfesionales = [
    '0101 - Ingeniería Textil y de Confecciones',
    '0201 - Ingeniería Ambiental y Forestal',
    '0301 - Ingeniería en Energías Renovables',
    '0401 - Ingeniería en Industrias Alimentarias',
    '0501 - Gestión Pública y Desarrollo Social',
    '0601 - Ingeniería Industrial',
    '0701 - Ingeniería de Software y Sistemas',
    '0801 - Ingeniería Mecatrónica',
    '0901 - Administración y Emprendimiento Empresarial',
    '1001 - Economía',
  ];

  List<Course> get coursesByCycle => _allCourses.where((c) => c.cycle == _selectedCycle).toList();
  List<Course> get selectedCourses => _allCourses.where((c) => c.isSelected).toList();

  int get totalCredits => _allCourses
      .where((c) => c.isSelected)
      .fold(0, (sum, c) => sum + c.credits);

  bool get isOverLimit => totalCredits > 22;

  void setPaymentFile(String? name) {
    _paymentFileName = name;
    notifyListeners();
  }

  void setOperationNumber(String val) {
    _operationNumber = val;
    notifyListeners();
  }

  void validatePayment() {
    if (_paymentFileName != null && _operationNumber.isNotEmpty) {
      _isPaymentValidated = true;
      notifyListeners();
    }
  }

  void setCycle(int cycle) {
    _selectedCycle = cycle;
    notifyListeners();
  }

  void toggleCourse(Course course) {
    if (course.isMandatoryRetake || course.isBlockedByPrereq) return;
    final index = _allCourses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      if (!course.isSelected && (totalCredits + course.credits) > 22) return;
      _allCourses[index].isSelected = !_allCourses[index].isSelected;
      notifyListeners();
    }
  }

  void reset() {
    _paymentFileName = null;
    _operationNumber = '';
    _isPaymentValidated = false;
    for (var c in _allCourses) c.isSelected = c.isMandatoryRetake;
    notifyListeners();
  }
}
