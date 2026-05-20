import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final supabaseUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';
  final uuid = '5975b8c0-6619-4102-a3a0-f10095623884';

  final client = HttpClient();
  
  // 1. Inspect usuarios
  try {
    print('--- USUARIOS ---');
    final uri = Uri.parse('$supabaseUrl/rest/v1/usuarios?id=eq.$uuid');
    final request = await client.getUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Status: ${response.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Error: $e');
  }

  // 2. Inspect estudiantes
  try {
    print('\n--- ESTUDIANTES ---');
    final uri = Uri.parse('$supabaseUrl/rest/v1/estudiantes?usuario_id=eq.$uuid');
    final request = await client.getUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('Status: ${response.statusCode}');
    print('Body: $body');
  } catch (e) {
    print('Error: $e');
  }

  client.close();
}
