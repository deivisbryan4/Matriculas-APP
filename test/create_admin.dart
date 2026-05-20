import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final supabaseUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';
  final adminEmail = 'admin@unaj.edu.pe';
  final adminPassword = 'admin12345678';

  print('========================================================');
  print('    CREANDO USUARIO ADMINISTRADOR EN SUPABASE (PURE DART)  ');
  print('========================================================');

  final client = HttpClient();
  String? userId;

  // 1. Intentar iniciar sesión para obtener el UUID si ya existe
  try {
    print('Intentando iniciar sesión con $adminEmail...');
    final uri = Uri.parse('$supabaseUrl/auth/v1/token?grant_type=password');
    final request = await client.postUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'email': adminEmail,
      'password': adminPassword,
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      userId = jsonResponse['user']['id'];
      print('✅ Sesión iniciada con éxito. El usuario ya existe (UUID: $userId).');
    } else {
      print('No se pudo iniciar sesión (código ${response.statusCode}). Registrando nuevo usuario...');
      
      // 2. Registrar usuario si no se pudo iniciar sesión
      final signUpUri = Uri.parse('$supabaseUrl/auth/v1/signup');
      final signUpRequest = await client.postUrl(signUpUri);
      signUpRequest.headers.set('apikey', anonKey);
      signUpRequest.headers.set('Content-Type', 'application/json');
      signUpRequest.write(body);
      
      final signUpResponse = await signUpRequest.close();
      final signUpResponseBody = await signUpResponse.transform(utf8.decoder).join();
      final signUpJson = jsonDecode(signUpResponseBody) as Map<String, dynamic>;

      if (signUpResponse.statusCode == 200 || signUpResponse.statusCode == 201) {
        userId = signUpJson['id'] ?? signUpJson['user']?['id'];
        print('✅ Usuario registrado exitosamente (UUID: $userId).');
      } else {
        print('❌ Error al registrar usuario (código ${signUpResponse.statusCode}): $signUpResponseBody');
        client.close();
        return;
      }
    }
  } catch (e) {
    print('❌ Error durante la comunicación con Supabase Auth: $e');
    client.close();
    return;
  }

  if (userId == null) {
    print('❌ Error: El ID de usuario es nulo.');
    client.close();
    return;
  }

  // 3. Upsert en la tabla usuarios de PostgREST
  try {
    print('Insertando/actualizando perfil en la tabla public.usuarios con rol_id = 1 (ADMIN)...');
    final uri = Uri.parse('$supabaseUrl/rest/v1/usuarios');
    final request = await client.postUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Prefer', 'resolution=merge-duplicates');

    final body = jsonEncode({
      'id': userId,
      'dni': '99999999',
      'nombres': 'Admin',
      'apellido_paterno': 'UNAJ',
      'apellido_materno': 'Master',
      'correo': adminEmail,
      'codigo_estudiante': null,
      'rol_id': 1, // ADMIN
      'activo': true,
    });
    request.write(body);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('🎉 ¡EL USUARIO ADMINISTRADOR HA SIDO CONFIGURADO CON ÉXITO!');
      print('Credenciales de prueba:');
      print('  - Correo: $adminEmail');
      print('  - Contraseña: $adminPassword');
      print('========================================================');
    } else {
      print('❌ Error al actualizar la tabla usuarios en la BD (código ${response.statusCode}): $responseBody');
    }
  } catch (dbError) {
    print('❌ Error de comunicación con la BD: $dbError');
  } finally {
    client.close();
  }
}
