import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const _defaultUrl = 'https://hkdsguzbjywieieyijwk.supabase.co';
  static const _defaultAnonKey =
      'sb_publishable_tcDijWreubViNBcVpuFk0A_jrJIau-A';

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultUrl,
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultAnonKey,
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
