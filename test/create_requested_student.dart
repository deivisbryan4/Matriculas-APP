import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final supabaseUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';
  
  final email = '2022107035.est@unaj.edu.pe';
  final password = '12345678';
  final dni = '2022107035';
  final nombres = 'Elyan Rosy';
  final paterno = 'Quispe';
  final materno = 'Zapana';
  final studentCode = '2022107035'; 
  final carreraId = 4; // Ingeniería Ambiental y Forestal (ID: 4)

  print('========================================================');
  print('      CREANDO ESTUDIANTE SOLICITADO (PURE DART)       ');
  print('========================================================');
  print('Email: $email');
  print('DNI: $dni');
  print('Nombres: $nombres');
  print('Apellidos: $paterno $materno');
  print('Código de Estudiante: $studentCode');
  print('--------------------------------------------------------');

  final client = HttpClient();
  String? userId;

  // 1. Intentar registrar el usuario en Supabase Auth o iniciar sesión
  try {
    print('1. Registrando/Autenticando en Supabase Auth...');
    
    // Intentar iniciar sesión primero (en caso de que ya se haya registrado en el intento anterior)
    final tokenUri = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
    final loginRequest = await client.postUrl(tokenUri);
    loginRequest.headers.set('apikey', anonKey);
    loginRequest.headers.set('Content-Type', 'application/json');
    loginRequest.add(utf8.encode(jsonEncode({
      'email': email,
      'password': password,
    })));
    
    final loginResponse = await loginRequest.close();
    final loginResponseBody = await loginResponse.transform(utf8.decoder).join();
    final loginJson = jsonDecode(loginResponseBody) as Map<String, dynamic>;

    if (loginResponse.statusCode == 200) {
      userId = loginJson['user']['id'];
      print('✅ Sesión iniciada con éxito. UUID obtenido: $userId');
    } else {
      print('El usuario no existe o la clave cambió. Procediendo a registrar nuevo usuario...');
      
      final signUpUri = Uri.parse('$supabaseUrl/auth/v1/signup');
      final signUpRequest = await client.postUrl(signUpUri);
      signUpRequest.headers.set('apikey', anonKey);
      signUpRequest.headers.set('Content-Type', 'application/json');
      
      final body = jsonEncode({
        'email': email,
        'password': password,
        'data': {
          'dni': dni,
          'nombres': nombres,
          'apellido_paterno': paterno,
          'apellido_materno': materno,
          'codigo_estudiante': studentCode,
          'carrera_id': carreraId, 
          'rol_id': 2,      // Estudiante
          'anio_ingreso': 2022,
          'semestre_ingreso': 1,
          'estado_academico': 'ACTIVO',
          'creditos_aprobados': 0
        }
      });
      signUpRequest.add(utf8.encode(body));
      
      final signUpResponse = await signUpRequest.close();
      final signUpResponseBody = await signUpResponse.transform(utf8.decoder).join();
      final signUpJson = jsonDecode(signUpResponseBody) as Map<String, dynamic>;

      if (signUpResponse.statusCode == 200 || signUpResponse.statusCode == 201) {
        userId = signUpJson['id'] ?? signUpJson['user']?['id'];
        print('✅ Registrado exitosamente en Auth. UUID: $userId');
      } else {
        print('❌ Error al registrar en Auth (código ${signUpResponse.statusCode}): $signUpResponseBody');
      }
    }
  } catch (e) {
    print('❌ Error durante la comunicación con Supabase Auth: $e');
  }

  if (userId == null) {
    print('❌ No se pudo registrar o autenticar al estudiante en Supabase Auth.');
    client.close();
    return;
  }

  // 2. Insertar/Actualizar perfil en la tabla public.usuarios
  try {
    print('\n2. Insertando perfil en tabla public.usuarios...');
    final uri = Uri.parse('$supabaseUrl/rest/v1/usuarios');
    final request = await client.postUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Prefer', 'resolution=merge-duplicates');

    final body = jsonEncode({
      'id': userId,
      'dni': dni,
      'nombres': nombres,
      'apellido_paterno': paterno,
      'apellido_materno': materno,
      'correo': email,
      'codigo_estudiante': studentCode,
      'rol_id': 2, // Estudiante
    });
    request.add(utf8.encode(body));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Perfil insertado exitosamente en tabla usuarios.');
    } else {
      print('❌ Error en tabla usuarios (código ${response.statusCode}): $responseBody');
    }
  } catch (e) {
    print('❌ Error al insertar en tabla usuarios: $e');
  }

  // 3. Insertar/Actualizar perfil en la tabla public.estudiantes
  try {
    print('\n3. Insertando perfil en tabla public.estudiantes...');
    final uri = Uri.parse('$supabaseUrl/rest/v1/estudiantes?on_conflict=usuario_id');
    final request = await client.postUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Prefer', 'resolution=merge-duplicates');

    final body = jsonEncode({
      'usuario_id': userId,
      'carrera_id': carreraId, 
      'codigo_estudiante': studentCode,
      'anio_ingreso': 2022,
      'semestre_ingreso': 1,
      'estado_academico': 'ACTIVO',
      'creditos_aprobados': 0,
    });
    request.add(utf8.encode(body));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Perfil insertado exitosamente en tabla estudiantes.');
      print('\n🎉 ¡EL ESTUDIANTE HA SIDO CREADO Y CONFIGURADO CON ÉXITO!');
      print('Detalles de Acceso:');
      print('  - Correo: $email');
      print('  - Contraseña: $password');
      print('========================================================');
    } else {
      print('❌ Error en tabla estudiantes (código ${response.statusCode}): $responseBody');
    }
  } catch (e) {
    print('❌ Error al insertar en tabla estudiantes: $e');
  } finally {
    client.close();
  }
}
