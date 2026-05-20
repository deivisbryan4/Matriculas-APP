import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  final supabaseUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';

  print('========================================================');
  print('   REPARADOR DE PERFIL DE ESTUDIANTE (UNAJ - SUPABASE)   ');
  print('========================================================');

  // Pedir credenciales por consola
  stdout.write('Introduce tu Correo Institucional: ');
  final email = stdin.readLineSync()?.trim();

  stdout.write('Introduce tu Contraseña: ');
  final password = stdin.readLineSync()?.trim();

  if (email == null || email.isEmpty || password == null || password.isEmpty) {
    print('❌ Error: El correo y la contraseña son obligatorios.');
    return;
  }

  // Extraer DNI por defecto a partir del correo si tiene formato "DNI.est@unaj.edu.pe"
  String defaultDni = '75272636';
  if (email.contains('.est@unaj.edu.pe')) {
    final prefix = email.split('.est@unaj.edu.pe').first;
    if (RegExp(r'^\d+$').hasMatch(prefix)) {
      defaultDni = prefix;
    }
  }

  stdout.write('Introduce tu DNI ($defaultDni por defecto): ');
  final inputDni = stdin.readLineSync()?.trim();
  final dni = (inputDni == null || inputDni.isEmpty) ? defaultDni : inputDni;

  stdout.write('Introduce tus Nombres (ej: Bryan): ');
  final nombres = stdin.readLineSync()?.trim() ?? 'Estudiante';

  stdout.write('Introduce tu Apellido Paterno: ');
  final paterno = stdin.readLineSync()?.trim() ?? 'UNAJ';

  stdout.write('Introduce tu Apellido Materno: ');
  final materno = stdin.readLineSync()?.trim() ?? 'Padrón';

  stdout.write('Introduce tu Código de Estudiante (10 dígitos): ');
  final codigoEstudiante = stdin.readLineSync()?.trim() ?? '2022107034';

  print('\nIniciando sesión en Supabase...');
  
  await Supabase.initialize(url: supabaseUrl, anonKey: anonKey);
  final client = Supabase.instance.client;

  try {
    // 1. Iniciar sesión para obtener el Token JWT y el UUID del usuario
    final authRes = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final userId = authRes.user?.id;
    if (userId == null) {
      print('❌ Error: No se pudo obtener el ID del usuario.');
      return;
    }

    print('✅ Sesión iniciada correctamente. ID de usuario (UUID): $userId');
    print('Insertando perfil en la tabla public.usuarios...');

    // 2. Insertar perfil en tabla usuarios
    await client.from('usuarios').upsert({
      'id': userId,
      'dni': dni,
      'nombres': nombres,
      'apellido_paterno': paterno,
      'apellido_materno': materno,
      'correo': email,
      'codigo_estudiante': codigoEstudiante,
      'rol_id': 2, // ESTUDIANTE
    });
    print('✅ Registro en tabla usuarios creado.');

    print('Insertando perfil en la tabla public.estudiantes...');

    // 3. Insertar perfil en tabla estudiantes
    await client.from('estudiantes').upsert({
      'usuario_id': userId,
      'carrera_id': 1, // Sistemas
      'codigo_estudiante': codigoEstudiante,
      'estado_academico': 'ACTIVO',
      'creditos_aprobados': 0,
    }, onConflict: 'usuario_id');
    print('✅ Registro en tabla estudiantes creado.');

    print('\n🎉 ¡TU PERFIL HA SIDO CREADO Y REPARADO CON ÉXITO!');
    print('Ya puedes abrir la aplicación e iniciar sesión sin problemas.');

  } catch (e) {
    print('\n❌ Ocurrió un error al reparar el perfil:');
    print(e.toString());
    print('\nSi RLS bloquea la inserción, indica al administrador que ejecute el SQL con privilegios postgres.');
  }
}
