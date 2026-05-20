import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final url = 'https://laakjkkxhcjrbslyqlbk.supabase.co/rest/v1/usuarios?select=*';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';

  print('========================================================');
  print('LISTANDO USUARIOS REGISTRADOS EN LA TABLA PUBLIC.USUARIOS');
  print('========================================================');

  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode == 200) {
      final List<dynamic> users = jsonDecode(responseBody);
      print('Total de usuarios encontrados: ${users.length}\n');
      for (var i = 0; i < users.length; i++) {
        final u = users[i];
        print('Usuario #${i + 1}:');
        print('  ID: ${u['id']}');
        print('  Nombre: ${u['nombres']} ${u['apellido_paterno'] ?? ''} ${u['apellido_materno'] ?? ''}');
        print('  Correo: ${u['correo']}');
        print('  Código Estudiante: ${u['codigo_estudiante']}');
        print('  DNI: ${u['dni']}');
        print('  Rol ID: ${u['rol_id']}');
        print('  Activo: ${u['activo']}');
        print('-------------------------------------------');
      }
    } else {
      print('Error al consultar: ${response.statusCode}');
      print(responseBody);
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
