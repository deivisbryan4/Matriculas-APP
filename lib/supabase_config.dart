import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const _defaultUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
  static const _defaultPublishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxhYWtqa2t4aGNqcmJzbHlxbGJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjUzOTgsImV4cCI6MjA5NDQ0MTM5OH0.2pHF-iDDYqCWAbQiXU9v1S5gT2oVVbPHqH-bTrmDMVE';

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultUrl,
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultPublishableKey,
  );

  static bool get isConfigured =>
      url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint(
        'Supabase no configurado. Ejecuta Flutter con '
        '--dart-define=SUPABASE_URL=... '
        '--dart-define=SUPABASE_ANON_KEY=...',
      );
      return;
    }

    await Supabase.initialize(url: url, anonKey: publishableKey);
  }

  static SupabaseClient? get client {
    if (!isConfigured) return null;
    return Supabase.instance.client;
  }
}
