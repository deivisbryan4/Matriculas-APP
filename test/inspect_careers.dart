import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';
  final client = HttpClient();

  Future<void> fetchTable(String tableName) async {
    final url = 'https://laakjkkxhcjrbslyqlbk.supabase.co/rest/v1/$tableName?select=*';
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set('apikey', anonKey);
      request.headers.set('Authorization', 'Bearer $anonKey');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      print('=== TABLA: $tableName ===');
      print('Body: $responseBody\n');
    } catch (e) {
      print('Error fetching $tableName: $e\n');
    }
  }

  await fetchTable('carreras');
  client.close();
}
