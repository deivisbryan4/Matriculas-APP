import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Inspect Supabase Database Connection and users', () async {
    final supabaseUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
    final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';

    // Usar EmptyLocalStorage para evitar el error de canal nativo de shared_preferences
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
      ),
    );
    final client = Supabase.instance.client;

    try {
      print('=== START DB CONNECTION TEST ===');
      print('Intentando iniciar sesión con rsaquel@unaj.edu.pe...');
      final authRes = await client.auth.signInWithPassword(
        email: 'rsaquel@unaj.edu.pe',
        password: 'PruebaPassword123',
      );
      print('Sesión iniciada con éxito. ID: ${authRes.user?.id}');

      final rows = await client.from('usuarios').select('*');
      print('Usuarios encontrados en la base de datos: ${rows.length}');
      for (var r in rows) {
        print('- DNI: ${r['dni']}, Nombres: ${r['nombres']}, Correo: ${r['correo']}');
      }
      print('=== END DB CONNECTION TEST ===');
    } catch (e) {
      print('Error during test: $e');
    }
  });
}
