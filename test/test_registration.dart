import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final url = 'https://laakjkkxhcjrbslyqlbk.supabase.co/auth/v1/signup';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';

  // Datos para Raquel
  final email = 'rsaquel@unaj.edu.pe';
  final password = 'PruebaPassword123';
  final studentCode = '2022107012';

  print('========================================================');
  print('SIMULANDO REGISTRO DE ESTUDIANTE DESDE LA APP FLUTTER');
  print('========================================================');
  print('Enviando petición a: $url');
  print('Email generado: $email');
  print('Código de Estudiante generado: $studentCode');
  print('Enviando metadatos para el Trigger de base de datos...');

  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');

    final body = {
      'email': email,
      'password': password,
      'data': {
        'dni': '74637012',
        'nombres': 'Raquel',
        'apellido_paterno': 'Cari',
        'apellido_materno': 'Pinto',
        'codigo_estudiante': studentCode,
        'carrera_id': 1, // Ingeniería de Sistemas
        'rol_id': 2,      // Rol ESTUDIANTE
        'anio_ingreso': 2022,
        'semestre_ingreso': 1,
        'estado_academico': 'ACTIVO',
        'creditos_aprobados': 0
      }
    };

    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print('\n---------------- RESPONSE ----------------');
    print('Código de estado HTTP: ${response.statusCode}');
    
    final decoded = jsonDecode(responseBody);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Respuesta exitosa de Supabase Auth.');
      print('ID de Usuario Creado: ${decoded['id'] ?? decoded['user']['id']}');
      print('\n¡Éxito! El estudiante ha sido registrado desde la app simulada.');
      print('La base de datos debería haber ejecutado el Trigger correctamente.');
    } else {
      print('Respuesta fallida:');
      print(responseBody);
    }
    print('-------------------------------------------');
  } catch (e) {
    print('Error de conexión o ejecución: $e');
  } finally {
    client.close();
  }
}
