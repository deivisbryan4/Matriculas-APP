import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const _defaultUrl = 'https://laakjkkxhcjrbslyqlbk.supabase.co';
  static const _defaultPublishableKey =
      'sb_publishable_6EfX_8W0Jz6fuFPiUJUlnA_oZ4MG4SM';

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
