/// Supabase connection settings, supplied at build time:
///
///   flutter run --dart-define-from-file=supabase.json
///
/// (copy `supabase.example.json` → `supabase.json` and paste your key).
/// Without a key the app runs fully offline and cloud features are
/// hidden, so the ML experience never depends on the network.
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://rinwoxqluqvakvgucnyx.supabase.co',
  );

  /// The project's *publishable* key (`sb_publishable_…`, or the legacy
  /// "anon" key). Both are safe in a client app. Never use the secret /
  /// service-role key here.
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
