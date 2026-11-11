import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// Single entry point to Supabase. Every cloud feature checks
/// [Backend.isAvailable] first, so the app works unchanged when Supabase is
/// not configured or failed to start.
abstract final class Backend {
  static bool _ready = false;
  static Object? _initError;

  static bool get isAvailable => _ready;

  /// Why cloud sync is off, for the in-app explanation.
  static String get offlineReason {
    if (!SupabaseConfig.isConfigured) {
      return 'This build was made without a Supabase key, so accounts and history are turned off. '
          'Rebuild with --dart-define-from-file=supabase.json, for example:\n\n'
          'flutter build apk --release --dart-define-from-file=supabase.json';
    }
    return 'Cloud sync could not start${_initError != null ? ' ($_initError)' : ''}. '
        'Check your connection and restart the app.';
  }

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
    } catch (e) {
      _ready = false;
      _initError = e;
    }
  }
}
