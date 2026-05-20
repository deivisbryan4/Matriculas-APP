import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final url = 'https://laakjkkxhcjrbslyqlbk.supabase.co/rest/v1/usuarios?id=eq.21450006-5246-4132-b43e-02c43a4dca10&select=*,estudiantes(*)';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';

  print('========================================================');
  print('VERIFICANDO ESTADO ACTUAL EN LA BASE DE DATOS');
  print('========================================================');

  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    print('HTTP Status: ${response.statusCode}');
    print('Body: $responseBody');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
