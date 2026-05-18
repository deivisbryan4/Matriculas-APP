import 'package:flutter/material.dart';
import 'models.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  int recoveryStep = 0;

  final List<User> students = [
    User(
      id: '1001',
      name: 'JUAN PEREZ GARCIA',
      email: 'jperez@unaj.edu.pe',
      code: '20211001',
      career: 'Ingenieria de Sistemas',
      role: UserRole.student,
      phone: '987654321',
      altEmail: 'juan.perez@gmail.com',
      enrollmentStatus: EnrollmentStatus.enrolled,
      enrollmentCode: 'UNAJ-2024I-1001',
      paymentOperation: '987654',
      paymentFileName: 'voucher_juan.pdf',
    ),
    User(
      id: '1002',
      name: 'MARIA LOPEZ DIAZ',
      email: 'mlopez@unaj.edu.pe',
      code: '20211002',
      career: 'Medicina Humana',
      role: UserRole.student,
      enrollmentStatus: EnrollmentStatus.selectingCourses,
      paymentOperation: '555888',
      paymentFileName: 'voucher_maria.pdf',
    ),
    User(
      id: '1003',
      name: 'CARLOS RUIZ LUNA',
      email: 'cruiz@unaj.edu.pe',
      code: '20211003',
      career: 'Derecho',
      role: UserRole.student,
    ),
  ];

  void login(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.contains('admin')) {
      _currentUser = User(
        id: '1',
        name: 'ADMIN MASTER',
        email: normalizedEmail,
        code: 'ADM-001',
        career: 'Sistemas',
        role: UserRole.adminMaster,
      );
    } else if (normalizedEmail.contains('sec')) {
      _currentUser = User(
        id: '2',
        name: 'GESTOR ACADEMICO',
        email: normalizedEmail,
        code: 'SEC-002',
        career: 'Administracion',
        role: UserRole.adminSecondary,
      );
    } else {
      _currentUser = students.firstWhere(
        (student) => student.email.toLowerCase() == normalizedEmail,
        orElse: () => User(
          id: '3',
          name: 'ALUMNO PRUEBA UNAJ',
          email: normalizedEmail.isEmpty
              ? 'alumno@unaj.edu.pe'
              : normalizedEmail,
          code: '20230045',
          career: 'Ingenieria de Sistemas',
          role: UserRole.student,
        ),
      );
    }
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

  void addStudent(User user) {
    students.add(user);
    notifyListeners();
  }

  void deleteStudent(String id) {
    students.removeWhere((student) => student.id == id);
    notifyListeners();
  }

  void updateCurrentUserContact({
    required String phone,
    required String altEmail,
  }) {
    if (_currentUser == null) return;
    _currentUser!
      ..phone = phone.trim()
      ..altEmail = altEmail.trim();
    notifyListeners();
  }

  void applyPaymentToCurrentUser(String fileName, String operationNumber) {
    if (_currentUser == null) return;
    _currentUser!
      ..paymentFileName = fileName
      ..paymentOperation = operationNumber
      ..enrollmentStatus = EnrollmentStatus.selectingCourses;
    notifyListeners();
  }

  void markCurrentUserEnrolled(String enrollmentCode) {
    if (_currentUser == null) return;
    _currentUser!
      ..enrollmentCode = enrollmentCode
      ..enrollmentStatus = EnrollmentStatus.enrolled;
    notifyListeners();
  }

  List<User> searchStudents(String query, String careerFilter) {
    final normalized = query.trim().toLowerCase();
    final normalizedCareer = careerFilter.toLowerCase();
    return students.where((student) {
      final matchesText =
          normalized.isEmpty ||
          student.name.toLowerCase().contains(normalized) ||
          student.code.toLowerCase().contains(normalized) ||
          student.email.toLowerCase().contains(normalized);
      final matchesCareer =
          careerFilter == 'Todas las carreras' ||
          normalizedCareer.contains(student.career.toLowerCase()) ||
          student.career.toLowerCase().contains(normalizedCareer);
      return matchesText && matchesCareer;
    }).toList();
  }
}

class EnrollmentProvider extends ChangeNotifier {
  static const int maxCredits = 22;
  static const String academicPeriod = '2026-I';

  String? _paymentFileName;
  String? get paymentFileName => _paymentFileName;

  String _operationNumber = '';
  String get operationNumber => _operationNumber;

  bool _isPaymentValidated = false;
  bool get isPaymentValidated => _isPaymentValidated;

  bool _isEnrollmentFinished = false;
  bool get isEnrollmentFinished => _isEnrollmentFinished;

  int _selectedCycle = 1;
  int get selectedCycle => _selectedCycle;

  EnrollmentRecord? _currentRecord;
  EnrollmentRecord? get currentRecord => _currentRecord;

  final List<EnrollmentRecord> records = [
    EnrollmentRecord(
      id: 'UNAJ-2024I-1001',
      studentCode: '20211001',
      studentName: 'JUAN PEREZ GARCIA',
      career: 'Ingenieria de Sistemas',
      period: academicPeriod,
      operationNumber: '987654',
      voucherFile: 'voucher_juan.pdf',
      courses: [
        Course(
          id: '0701-101',
          name: 'Introduccion a la Programacion',
          credits: 4,
          cycle: 1,
        ),
        Course(id: '0701-102', name: 'Calculo I', credits: 5, cycle: 1),
      ],
      createdAt: DateTime(2026, 5, 17, 10, 20),
    ),
  ];

  final List<Course> _allCourses = [
    Course(
      id: '0701-101',
      name: 'Introduccion a la Programacion',
      credits: 4,
      cycle: 1,
      section: 'A',
      schedule: 'Lun-Mie 08:00-10:00',
      vacancies: 28,
      isMandatoryRetake: true,
      isSelected: true,
    ),
    Course(
      id: '0701-102',
      name: 'Calculo I',
      credits: 5,
      cycle: 1,
      section: 'B',
      schedule: 'Mar-Jue 10:00-12:00',
      vacancies: 18,
    ),
    Course(
      id: '0701-103',
      name: 'Matematica Discreta',
      credits: 3,
      cycle: 1,
      section: 'A',
      schedule: 'Vie 08:00-11:00',
      vacancies: 30,
    ),
    Course(
      id: '0701-104',
      name: 'Comunicacion Academica',
      credits: 3,
      cycle: 1,
      section: 'C',
      schedule: 'Sab 09:00-12:00',
      vacancies: 22,
    ),
    Course(
      id: '0701-201',
      name: 'Algoritmos y Estructuras de Datos',
      credits: 4,
      cycle: 2,
      section: 'A',
      schedule: 'Lun-Mie 14:00-16:00',
      vacancies: 16,
    ),
    Course(
      id: '0701-202',
      name: 'Fisica I',
      credits: 4,
      cycle: 2,
      section: 'B',
      schedule: 'Mar-Jue 08:00-10:00',
      vacancies: 12,
      isBlockedByPrereq: true,
      prereq: 'Calculo I',
    ),
    Course(
      id: '0701-203',
      name: 'Estadistica Aplicada',
      credits: 3,
      cycle: 2,
      section: 'A',
      schedule: 'Vie 14:00-17:00',
      vacancies: 25,
    ),
    Course(
      id: '0701-301',
      name: 'Arquitectura de Software',
      credits: 5,
      cycle: 3,
      section: 'A',
      schedule: 'Lun-Mie 18:00-20:00',
      vacancies: 20,
    ),
    Course(
      id: '0701-302',
      name: 'Bases de Datos I',
      credits: 4,
      cycle: 3,
      section: 'B',
      schedule: 'Mar-Jue 16:00-18:00',
      vacancies: 26,
    ),
    Course(
      id: '0701-303',
      name: 'Ingenieria de Requisitos',
      credits: 3,
      cycle: 3,
      section: 'A',
      schedule: 'Sab 08:00-11:00',
      vacancies: 19,
    ),
  ];

  final List<String> escuelasProfesionales = [
    '0101 - Ingenieria Textil y de Confecciones',
    '0201 - Ingenieria Ambiental y Forestal',
    '0301 - Ingenieria en Energias Renovables',
    '0401 - Ingenieria en Industrias Alimentarias',
    '0501 - Gestion Publica y Desarrollo Social',
    '0601 - Ingenieria Industrial',
    '0701 - Ingenieria de Software y Sistemas',
    '0801 - Ingenieria Mecatronica',
    '0901 - Administracion y Emprendimiento Empresarial',
    '1001 - Economia',
  ];

  List<Course> get coursesByCycle =>
      _allCourses.where((course) => course.cycle == _selectedCycle).toList();
  List<Course> get selectedCourses =>
      _allCourses.where((course) => course.isSelected).toList();

  int get totalCredits =>
      selectedCourses.fold(0, (sum, course) => sum + course.credits);
  int get availableCredits => maxCredits - totalCredits;
  bool get isOverLimit => totalCredits > maxCredits;
  bool get canFinishEnrollment =>
      isPaymentValidated && selectedCourses.isNotEmpty && !isOverLimit;

  int countRecordsByCareer(String career) {
    return records
        .where(
          (record) =>
              record.career.toLowerCase().contains(career.toLowerCase()),
        )
        .length;
  }

  void setPaymentFile(String? name) {
    _paymentFileName = name;
    _isPaymentValidated = false;
    notifyListeners();
  }

  void setOperationNumber(String val) {
    _operationNumber = val.trim();
    _isPaymentValidated = false;
    notifyListeners();
  }

  bool validatePayment() {
    final isPdf = _paymentFileName?.toLowerCase().endsWith('.pdf') ?? false;
    if (isPdf && _operationNumber.length >= 5) {
      _isPaymentValidated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void setCycle(int cycle) {
    _selectedCycle = cycle;
    notifyListeners();
  }

  void toggleCourse(Course course) {
    if (course.isMandatoryRetake ||
        course.isBlockedByPrereq ||
        _isEnrollmentFinished) {
      return;
    }
    final index = _allCourses.indexWhere((item) => item.id == course.id);
    if (index == -1) {
      return;
    }
    if (!course.isSelected && (totalCredits + course.credits) > maxCredits) {
      return;
    }
    _allCourses[index].isSelected = !_allCourses[index].isSelected;
    notifyListeners();
  }

  EnrollmentRecord finishEnrollment(User user) {
    final record = EnrollmentRecord(
      id: 'UNAJ-$academicPeriod-${user.code}',
      studentCode: user.code,
      studentName: user.name,
      career: user.career,
      period: academicPeriod,
      operationNumber: _operationNumber,
      voucherFile: _paymentFileName ?? '',
      courses: selectedCourses
          .map(
            (course) => Course(
              id: course.id,
              name: course.name,
              credits: course.credits,
              cycle: course.cycle,
              prereq: course.prereq,
              section: course.section,
              schedule: course.schedule,
              vacancies: course.vacancies,
              isMandatoryRetake: course.isMandatoryRetake,
              isBlockedByPrereq: course.isBlockedByPrereq,
              isSelected: true,
            ),
          )
          .toList(),
      createdAt: DateTime.now(),
    );
    records.removeWhere(
      (item) => item.studentCode == user.code && item.period == academicPeriod,
    );
    records.add(record);
    _currentRecord = record;
    _isEnrollmentFinished = true;
    notifyListeners();
    return record;
  }

  void reset() {
    _paymentFileName = null;
    _operationNumber = '';
    _isPaymentValidated = false;
    _isEnrollmentFinished = false;
    _currentRecord = null;
    _selectedCycle = 1;
    for (final course in _allCourses) {
      course.isSelected = course.isMandatoryRetake;
    }
    notifyListeners();
  }
}
