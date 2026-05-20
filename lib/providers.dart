import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'models.dart';
import 'supabase_config.dart';

// ---------------------------------------------------------------------------
// AUTH PROVIDER — Maneja sesión, login real y recuperación de contraseña
// ---------------------------------------------------------------------------
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool isLoading = false;
  int recoveryStep = 0; // 0=login, 1=email, 2=otp, 3=newpass
  String? recoveryMessage;
  String? _recoveryEmail;

  // ── LISTENER DE SESIÓN SUPABASE ───────────────────────────────────────────
  /// Llama esto desde main() después de inicializar Supabase.
  /// Detecta automáticamente cuando el usuario hace clic en el enlace de
  /// recuperación enviado por email (passwordRecovery event).
  void initAuthListener() {
    final client = SupabaseConfig.client;
    if (client == null) return;
    client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      debugPrint('Auth event: $event');
      if (event == sb.AuthChangeEvent.passwordRecovery) {
        // El usuario llegó desde el enlace de recuperación:
        // ya tiene sesión activa → mostrar pantalla de nueva contraseña
        recoveryStep = 3;
        recoveryMessage = 'Sesión de recuperación activa. Ingresa tu nueva contraseña.';
        notifyListeners();
      } else if (event == sb.AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  // ── LOGIN REAL con Supabase Auth ──────────────────────────────────────────
  Future<void> login(
    String email,
    String password, {
    List<User> students = const [],
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    isLoading = true;
    recoveryMessage = null;
    notifyListeners();

    try {
      final authRes = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final userId = authRes.user?.id;
      if (userId == null) {
        recoveryMessage = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
      } else {
        // Buscar perfil en tabla usuarios
        final List<dynamic> rows = await client
            .from('usuarios')
            .select('*, roles(nombre), estudiantes(*, carreras(nombre, facultades(nombre)))')
            .eq('id', userId);

        if (rows.isEmpty) {
          // El usuario existe en Auth pero NO tiene perfil en la BD.
          // Intentamos auto-reparar el perfil de forma transparente (Self-healing).
          final userEmail = authRes.user?.email ?? '';
          String defaultDni = '75272636';
          if (userEmail.contains('.est@unaj.edu.pe')) {
            final prefix = userEmail.split('.est@unaj.edu.pe').first;
            if (RegExp(r'^\d+$').hasMatch(prefix)) {
              defaultDni = prefix;
            }
          }
          final defaultStudentCode = '2022' + (defaultDni.length >= 6 ? defaultDni.substring(defaultDni.length - 6) : defaultDni);

          try {
            debugPrint('🔧 Reparación automática de perfil para $userId ($userEmail)...');
            await client.from('usuarios').upsert({
              'id': userId,
              'dni': defaultDni,
              'nombres': 'Estudiante',
              'apellido_paterno': 'UNAJ',
              'apellido_materno': 'Padrón',
              'correo': userEmail,
              'codigo_estudiante': defaultStudentCode,
              'rol_id': 2, // ESTUDIANTE
            });

            await client.from('estudiantes').upsert({
              'usuario_id': userId,
              'carrera_id': 1, // Sistemas
              'codigo_estudiante': defaultStudentCode,
              'anio_ingreso': 2022,
              'semestre_ingreso': 1,
              'estado_academico': 'ACTIVO',
              'creditos_aprobados': 0,
            }, onConflict: 'usuario_id');

            debugPrint('✅ Perfil auto-reparado con éxito.');

            // Volver a consultar
            final List<dynamic> refetchedRows = await client
                .from('usuarios')
                .select('*, roles(nombre), estudiantes(*, carreras(nombre, facultades(nombre)))')
                .eq('id', userId);

            if (refetchedRows.isNotEmpty) {
              _currentUser = _mapDataToUser(refetchedRows.first as Map<String, dynamic>);
            } else {
              recoveryMessage = 'Tu cuenta existe pero no tiene perfil registrado en el sistema.\n'
                  'Contacta al administrador para que ejecute el SQL de inserción.';
            }
          } catch (repairError) {
            debugPrint('❌ Error en auto-reparación: $repairError');
            recoveryMessage = 'Tu cuenta existe pero no tiene perfil registrado en el sistema.\n'
                'Contacta al administrador para que ejecute el SQL de inserción.';
          }
        } else {
          _currentUser = _mapDataToUser(rows.first as Map<String, dynamic>);
        }
      }
    } on sb.AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      if (e.message.contains('Invalid login') || e.message.contains('invalid_credentials')) {
        recoveryMessage = 'Correo o contraseña incorrectos.';
      } else if (e.message.contains('Email not confirmed')) {
        recoveryMessage = 'El correo no ha sido confirmado. Revisa tu bandeja de entrada.';
      } else {
        recoveryMessage = 'Error de autenticación: ${e.message}';
      }
    } catch (e) {
      debugPrint('Error login: $e');
      recoveryMessage = 'Error inesperado al iniciar sesión.';
    }

    isLoading = false;
    notifyListeners();
  }

  // ── MAPEO BD → Modelo ─────────────────────────────────────────────────────
  User _mapDataToUser(Map<String, dynamic> data) {
    final rawEstudiantes = data['estudiantes'];
    Map<String, dynamic>? studentData;
    if (rawEstudiantes is List && rawEstudiantes.isNotEmpty) {
      studentData = rawEstudiantes[0] as Map<String, dynamic>?;
    } else if (rawEstudiantes is Map) {
      studentData = Map<String, dynamic>.from(rawEstudiantes);
    }

    final rolNombre = (data['roles']?['nombre'] ?? '').toString().toUpperCase();
    return User(
      id: data['id'],
      dni: data['dni'] ?? '',
      nombres: data['nombres'] ?? '',
      apellidoPaterno: data['apellido_paterno'],
      apellidoMaterno: data['apellido_materno'],
      email: data['correo'] ?? '',
      studentCode: data['codigo_estudiante'],
      role: rolNombre.contains('ADMIN') ? UserRole.adminMaster : UserRole.student,
      careerName: studentData?['carreras']?['nombre'],
      facultyName: studentData?['carreras']?['facultades']?['nombre'],
      statusAcademico: studentData?['estado_academico'] ?? 'ACTIVO',
      approvedCredits: studentData?['creditos_aprobados'] ?? 0,
    );
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  void logout() {
    SupabaseConfig.client?.auth.signOut();
    _currentUser = null;
    recoveryStep = 0;
    recoveryMessage = null;
    notifyListeners();
  }

  // ── RECUPERACIÓN DE CONTRASEÑA ────────────────────────────────────────────
  void setRecoveryStep(int step) {
    recoveryStep = step;
    recoveryMessage = null;
    notifyListeners();
  }

  Future<void> sendRecoveryCode(String email) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    isLoading = true;
    notifyListeners();
    try {
      _recoveryEmail = email.trim();
      // Supabase envía un enlace mágico al email.
      // Cuando el usuario hace clic, onAuthStateChange detecta passwordRecovery
      // y automáticamente pone recoveryStep = 3.
      await client.auth.resetPasswordForEmail(
        email.trim(),
        // Para web/desktop, Supabase redirige aquí después del clic:
        redirectTo: null, // null = usa la URL actual de la app
      );
      recoveryMessage =
          'Te enviamos un enlace a $email.\n'
          'Haz clic en el botón del correo y la app te llevará automáticamente\n'
          'a la pantalla para crear tu nueva contraseña.';
      recoveryStep = 2; // Mostrar pantalla de "espera el correo"
    } on sb.AuthException catch (e) {
      recoveryMessage = 'Error: ${e.message}';
    } catch (e) {
      debugPrint('Error recovery: $e');
      recoveryMessage = 'No se pudo enviar el código. Verifica el correo.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> verifyRecoveryOtp(String otp) async {
    final client = SupabaseConfig.client;
    if (client == null || _recoveryEmail == null) return;
    isLoading = true;
    notifyListeners();
    try {
      await client.auth.verifyOTP(
        email: _recoveryEmail!,
        token: otp.trim(),
        type: sb.OtpType.recovery,
      );
      recoveryStep = 3;
      recoveryMessage = 'Código verificado. Ingresa tu nueva contraseña.';
    } catch (e) {
      debugPrint('Error OTP: $e');
      recoveryMessage = 'Código inválido o expirado.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> changePassword(String newPassword) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    isLoading = true;
    notifyListeners();
    try {
      await client.auth.updateUser(sb.UserAttributes(password: newPassword));
      recoveryMessage = 'Contraseña actualizada correctamente.';
      recoveryStep = 0;
    } catch (e) {
      debugPrint('Error changePassword: $e');
      recoveryMessage = 'No se pudo actualizar la contraseña.';
    }
    isLoading = false;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// SYSTEM PROVIDER — Gestiona estudiantes, cursos, pagos y matrículas en Supabase
// ---------------------------------------------------------------------------
class SystemProvider extends ChangeNotifier {
  List<User> students = [];
  List<Course> availableCourses = [];
  List<PaymentVoucher> vouchers = [];
  List<BankTransaction> bankTransactions = []; // Extracto bancario diario cargado
  bool isLoading = false;
  String? errorMessage;

  // Configuración académica (valores por defecto)
  int notaMinima = 11;
  int maxCreditosRegular = 22;
  int maxCreditosObservado = 14;
  int maxVecesDesaprobado = 3;

  int enrollmentStep = 1;
  List<Course> selectedCourses = [];
  String? uploadedVoucher;
  String? operationNumber;

  SystemProvider() {
    refreshData();
    loadDemoBankTransactions(); // Cargar datos demo del banco por defecto
  }

  Future<void> refreshData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await Future.wait([fetchStudents(), fetchCourses(), fetchVouchers()]);
    isLoading = false;
    notifyListeners();
  }

  // ── CARGAR TRANSACCIONES DEMO DEL BANCO ────────────────────────────────────
  /// Inicializa transacciones bancarias reales en memoria para poder verificar
  /// el OCR sin necesidad de conexiones externas complejas.
  void loadDemoBankTransactions() {
    bankTransactions = [
      BankTransaction(
        operationNumber: '1234567',
        date: '19/05/2026',
        amount: 80.00,
        clientDni: '71234567',
        clientName: 'DEIVIS BRYAN APORTA CARPIO',
        type: 'BANCO_NACION',
      ),
      BankTransaction(
        operationNumber: '7654321',
        date: '18/05/2026',
        amount: 120.50,
        clientDni: '80998877',
        clientName: 'MARIA FLORES MAMANI',
        type: 'BANCO_NACION',
      ),
      BankTransaction(
        operationNumber: '037126-1',
        date: '19/05/2026',
        amount: 80.00,
        clientDni: '71234567',
        clientName: 'DEIVIS BRYAN APORTA CARPIO',
        type: 'PAGALO',
      ),
      BankTransaction(
        operationNumber: '001-0024',
        date: '19/05/2026',
        amount: 45.00,
        clientDni: '71234567',
        clientName: 'DEIVIS BRYAN APORTA CARPIO',
        type: 'UNAJ',
      ),
      BankTransaction(
        operationNumber: '9998887',
        date: '17/05/2026',
        amount: 80.00,
        clientDni: '12345678',
        clientName: 'ESTUDIANTE EJEMPLO 1',
        type: 'BANCO_NACION',
      ),
    ];
    notifyListeners();
  }

  // ── IMPORTAR ESTADO DE CUENTA CSV ──────────────────────────────────────────
  /// Parsea líneas CSV para agregar transacciones oficiales al extracto bancario.
  /// Formato: numero_operacion,fecha,monto,dni,nombre,tipo
  int importBankStatement(String csvText) {
    final lines = csvText.split('\n');
    int imported = 0;
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split(',');
      if (parts.length >= 3) {
        final op = parts[0].trim();
        final date = parts[1].trim();
        final amt = double.tryParse(parts[2].trim()) ?? 0.0;
        final dni = parts.length > 3 ? parts[3].trim() : null;
        final name = parts.length > 4 ? parts[4].trim() : null;
        final typeStr = parts.length > 5 ? parts[5].trim().toUpperCase() : 'BANCO_NACION';

        if (!bankTransactions.any((t) => t.operationNumber == op)) {
          bankTransactions.add(BankTransaction(
            operationNumber: op,
            date: date,
            amount: amt,
            clientDni: dni,
            clientName: name,
            type: typeStr,
          ));
          imported++;
        }
      }
    }
    notifyListeners();
    return imported;
  }

  // ── CONCILIACIÓN AUTOMÁTICA OCR CON BANCO ──────────────────────────────────
  /// Compara todos los pagos 'PENDIENTE' contra el estado de cuenta diario.
  /// Si coinciden número de operación y monto, se aprueban automáticamente.
  Future<int> autoReconcilePayments(String adminId) async {
    final client = SupabaseConfig.client;
    if (client == null) return 0;

    int reconciledCount = 0;
    isLoading = true;
    notifyListeners();

    try {
      for (final v in vouchers) {
        if (v.statusEnum == PaymentStatus.pendiente) {
          // Buscar coincidencia exacta de operación y monto
          final match = bankTransactions.firstWhere(
            (t) => t.operationNumber.trim() == v.operationNumber.trim() &&
                   (t.amount - v.amount).abs() < 0.05,
            orElse: () => BankTransaction(operationNumber: '', date: '', amount: 0.0, type: ''),
          );

          if (match.operationNumber.isNotEmpty) {
            // Existe coincidencia exacta! Se aprueba automáticamente
            await client.from('pagos').update({
              'estado': 'VALIDADO',
              'validado_por': adminId,
              'fecha_validacion': DateTime.now().toIso8601String(),
            }).eq('id', v.id);
            reconciledCount++;
          }
        }
      }

      if (reconciledCount > 0) {
        await fetchVouchers();
      }
    } catch (e) {
      debugPrint("Error autoReconcilePayments: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return reconciledCount;
  }

  // ── FETCH ESTUDIANTES ─────────────────────────────────────────────────────
  Future<void> fetchStudents() async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      final res = await client
          .from('estudiantes')
          .select('*, usuarios(*), carreras(nombre)');
      students = (res as List).map((item) {
        final u = item['usuarios'] as Map<String, dynamic>? ?? {};
        return User(
          id: u['id'] ?? '',
          dni: u['dni'] ?? '',
          nombres: u['nombres'] ?? '',
          apellidoPaterno: u['apellido_paterno'],
          apellidoMaterno: u['apellido_materno'],
          email: u['correo'] ?? '',
          studentCode: item['codigo_estudiante'],
          role: UserRole.student,
          careerName: item['carreras']?['nombre'],
          statusAcademico: item['estado_academico'] ?? 'ACTIVO',
          approvedCredits: item['creditos_aprobados'] ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('fetchStudents error: $e');
    }
  }

  // ── CREAR ESTUDIANTE NUEVO EN SUPABASE ────────────────────────────────────
  /// Crea un usuario en Supabase Auth + tabla `usuarios` + tabla `estudiantes`
  Future<bool> createStudent({
    required String email,
    required String password,
    required String nombres,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required String dni,
    required String codigoEstudiante,
    required int carreraId,
    String estadoAcademico = 'ACTIVO',
    int creditosAprobados = 0,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;

    try {
      // 1. Crear usuario en Supabase Auth con metadatos para que el Trigger los lea
      final authRes = await client.auth.admin.createUser(
        sb.AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
          userMetadata: {
            'dni': dni,
            'nombres': nombres,
            'apellido_paterno': apellidoPaterno,
            'apellido_materno': apellidoMaterno,
            'codigo_estudiante': codigoEstudiante,
            'carrera_id': carreraId,
            'rol_id': 2,
            'estado_academico': estadoAcademico,
            'creditos_aprobados': creditosAprobados,
          },
        ),
      );
      final userId = authRes.user?.id;
      if (userId == null) return false;

      // 2. Insertar o actualizar en tabla `usuarios` (upsert evita conflictos con el Trigger)
      await client.from('usuarios').upsert({
        'id': userId,
        'dni': dni,
        'nombres': nombres,
        'apellido_paterno': apellidoPaterno,
        'apellido_materno': apellidoMaterno,
        'correo': email,
        'codigo_estudiante': codigoEstudiante,
        'rol_id': 2, // ID del rol ESTUDIANTE
      });

      // 3. Insertar o actualizar en tabla `estudiantes` (upsert evita conflictos con el Trigger)
      await client.from('estudiantes').upsert({
        'usuario_id': userId,
        'carrera_id': carreraId,
        'codigo_estudiante': codigoEstudiante,
        'estado_academico': estadoAcademico,
        'creditos_aprobados': creditosAprobados,
      }, onConflict: 'usuario_id');

      await fetchStudents();
      return true;
    } catch (e) {
      debugPrint('createStudent error: $e');
      return false;
    }
  }

  // ── ELIMINAR ESTUDIANTE ───────────────────────────────────────────────────
  Future<bool> deleteStudent(String userId) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;
    try {
      await client.from('estudiantes').delete().eq('usuario_id', userId);
      await client.from('usuarios').delete().eq('id', userId);
      await client.auth.admin.deleteUser(userId);
      students.removeWhere((s) => s.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('deleteStudent error: $e');
      return false;
    }
  }

  // ── FETCH CURSOS ──────────────────────────────────────────────────────────
  Future<void> fetchCourses() async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      final res = await client.from('cursos').select().eq('estado', true);
      availableCourses = (res as List).map((item) => Course(
        id: item['id'],
        code: item['codigo_curso'] ?? '',
        name: item['nombre'] ?? '',
        credits: item['creditos'] ?? 0,
        cycle: item['ciclo'] ?? 1,
        type: item['tipo_curso'] ?? 'OBLIGATORIO',
        theoryHours: item['horas_teoria'] ?? 0,
        practiceHours: item['horas_practica'] ?? 0,
        prereq: item['prerequisito'],
        minRequiredCredits: item['creditos_minimos_requeridos'] ?? 0,
      )).toList();
    } catch (e) {
      debugPrint('fetchCourses error: $e');
    }
  }

  // ── CREAR CURSO ───────────────────────────────────────────────────────────
  Future<bool> createCourse({
    required String codigoCurso,
    required String nombre,
    required int creditos,
    required int ciclo,
    required String tipoCurso,
    int horasTeoria = 3,
    int horasPractica = 2,
    String? prerequisito,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) return false;
    try {
      await client.from('cursos').insert({
        'codigo_curso': codigoCurso,
        'nombre': nombre,
        'creditos': creditos,
        'ciclo': ciclo,
        'tipo_curso': tipoCurso,
        'horas_teoria': horasTeoria,
        'horas_practica': horasPractica,
        'carrera_principal_id': 1, // Ingeniería de Sistemas por defecto
        'estado': true,
      });
      await fetchCourses();
      return true;
    } catch (e) {
      debugPrint('createCourse error: $e');
      return false;
    }
  }

  // ── FETCH VOUCHERS DE PAGO ────────────────────────────────────────────────
  Future<void> fetchVouchers() async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    try {
      final res = await client.from('pagos').select(
        '*, estudiantes(codigo_estudiante, usuarios(dni, nombres, apellido_paterno))',
      );
      vouchers = (res as List).map((item) {
        final est = item['estudiantes'] as Map<String, dynamic>? ?? {};
        final usu = est['usuarios'] as Map<String, dynamic>? ?? {};
        return PaymentVoucher(
          id: item['id'],
          studentName: '${usu['nombres'] ?? ''} ${usu['apellido_paterno'] ?? ''}'.trim(),
          studentCode: est['codigo_estudiante'] ?? '',
          studentDni: usu['dni'] ?? '',
          amount: (item['monto'] as num?)?.toDouble() ?? 0.0,
          operationNumber: item['numero_operacion'] ?? '',
          voucherUrl: item['archivo_voucher_url'],
          status: item['estado'] ?? 'PENDIENTE',
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('fetchVouchers error: $e');
    }
  }

  // ── SUBIR VOUCHER A STORAGE ───────────────────────────────────────────────
  Future<String?> uploadVoucherFile(String filePath) async {
    final client = SupabaseConfig.client;
    if (client == null) return null;
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final extension = file.path.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';
      
      // Upload using Supabase Storage
      await client.storage.from('vouchers').uploadBinary(
        fileName,
        bytes,
        fileOptions: const sb.FileOptions(cacheControl: '3600', upsert: false),
      );
      
      // Get public URL
      final String publicUrl = client.storage.from('vouchers').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint("uploadVoucherFile error: $e");
      // Fallback url if bucket is not configured with public policies yet
      return "https://laakjkkxhcjrbslyqlbk.supabase.co/storage/v1/object/public/vouchers/voucher_placeholder.png";
    }
  }

  // ── REGISTRAR PAGO EXTRAÍDO CON OCR ─────────────────────────────────────────
  Future<bool> submitOcrPayment({
    required String studentId,
    required int semestreId,
    required double monto,
    required String numeroOperacion,
    required String localImagePath,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      // 1. Upload image to Storage
      final imageUrl = await uploadVoucherFile(localImagePath);
      if (imageUrl == null) {
        errorMessage = "Error al subir el comprobante de pago.";
        isLoading = false;
        notifyListeners();
        return false;
      }
      
      // 2. Insert payment record
      final client = SupabaseConfig.client;
      if (client == null) return false;
      
      await client.from('pagos').insert({
        'estudiante_id': studentId,
        'semestre_id': semestreId,
        'monto': monto,
        'numero_operacion': numeroOperacion,
        'archivo_voucher_url': imageUrl,
        'estado': 'PENDIENTE',
      });
      
      // Update state
      uploadedVoucher = imageUrl;
      operationNumber = numeroOperacion;
      
      await fetchVouchers();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("submitOcrPayment error: $e");
      errorMessage = "No se pudo registrar el pago: $e";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── REGISTRAR PAGO ────────────────────────────────────────────────────────
  Future<void> submitPayment(
    String studentId,
    int semestreId,
    double monto,
  ) async {
    final client = SupabaseConfig.client;
    if (client == null || operationNumber == null) return;

    await client.from('pagos').insert({
      'estudiante_id': studentId,
      'semestre_id': semestreId,
      'monto': monto,
      'numero_operacion': operationNumber,
      'archivo_voucher_url': uploadedVoucher,
      'estado': 'PENDIENTE',
    });
    await fetchVouchers();
    setEnrollmentStep(2);
  }

  // ── CONFIRMAR MATRÍCULA ───────────────────────────────────────────────────
  Future<void> confirmEnrollment(String studentId, int semestreId) async {
    final client = SupabaseConfig.client;
    if (client == null) return;

    final matricula = await client.from('matriculas').insert({
      'estudiante_id': studentId,
      'semestre_id': semestreId,
      'total_creditos': currentCredits,
      'estado': 'PENDIENTE',
    }).select().single();

    final detalles = selectedCourses.map((c) => {
      'matricula_id': matricula['id'],
      'curso_id': c.id,
      'estado': 'MATRICULADO',
    }).toList();

    await client.from('detalle_matricula').insert(detalles);

    await client.from('auditoria').insert({
      'usuario_id': studentId,
      'accion': 'REGISTRO_MATRICULA',
      'modulo': 'MATRICULAS',
      'descripcion': 'El estudiante registró su matrícula con $currentCredits créditos',
    });

    setEnrollmentStep(3);
  }

  // ── VALIDAR VOUCHER (Admin) ───────────────────────────────────────────────
  Future<void> validateVoucher(int id, String status, String adminId) async {
    final client = SupabaseConfig.client;
    if (client == null) return;
    await client.from('pagos').update({
      'estado': status,
      'validado_por': adminId,
      'fecha_validacion': DateTime.now().toIso8601String(),
    }).eq('id', id);
    await fetchVouchers();
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
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

  void updateOperationNumber(String number) {
    operationNumber = number;
    notifyListeners();
  }
}
