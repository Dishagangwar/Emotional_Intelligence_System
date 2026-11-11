import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/check_in_record.dart';
import '../models/prediction_result.dart';
import '../models/reflection_input.dart';
import 'auth_service.dart';
import 'backend.dart';

/// Reads and writes the signed-in user's check-ins in Supabase.
/// Row-level security on `check_ins` guarantees users only see their own.
abstract final class CheckInRepository {
  static const String _table = 'check_ins';

  /// Bumped after every save / delete so history views know to reload.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Future<void> save(
    ReflectionInput input,
    PredictionResult result,
  ) async {
    await Backend.client
        .from(_table)
        .insert(CheckInRecord.toInsertRow(input, result));
    revision.value++;
  }

  static Future<List<CheckInRecord>> fetchMine({int limit = 200}) async {
    final rows = await Backend.client
        .from(_table)
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return rows.map(CheckInRecord.fromRow).toList();
  }

  static Future<void> delete(String id) async {
    await Backend.client.from(_table).delete().eq('id', id);
    revision.value++;
  }

  /// Deletes every check-in belonging to the current user.
  static Future<void> deleteAll() async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;
    await Backend.client.from(_table).delete().eq('user_id', uid);
    revision.value++;
  }

  static String describeError(Object error) {
    if (error is PostgrestException) {
      if (error.code == '42P01' || error.code == 'PGRST205') {
        return "The check_ins table doesn't exist yet. Run supabase/schema.sql in the Supabase SQL editor.";
      }
      return error.message;
    }
    if (error is AuthException) return error.message;
    return 'Could not reach the server. Check your connection and try again.';
  }
}
