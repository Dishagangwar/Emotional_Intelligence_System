import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Single entry point to Supabase. Every cloud feature checks
/// [Backend.isAvailable] first, so the app works unchanged when Supabase is
/// not configured or failed to start.
abstract final class Backend {
  static bool _ready = false;

  static bool get isAvailable => _ready;

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialise Supabase if configured. Never throws: on failure the app
  /// simply runs in offline mode.
  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }
}
