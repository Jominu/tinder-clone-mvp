import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_models.dart';

class MatchesRepository {
  const MatchesRepository(this._client);

  final SupabaseClient _client;

  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('User is not signed in.');
    }
    return id;
  }

  Future<List<MatchPreview>> loadMatches() async {
    final rows = await _client
        .from('matches')
        .select()
        .or('user_a_id.eq.$_currentUserId,user_b_id.eq.$_currentUserId')
        .order('created_at', ascending: false);

    final previews = <MatchPreview>[];

    for (final row in rows) {
      final otherUserId = row['user_a_id'] == _currentUserId
          ? row['user_b_id'] as String
          : row['user_a_id'] as String;

      final profileRow = await _client
          .from('profiles')
          .select()
          .eq('id', otherUserId)
          .maybeSingle();

      if (profileRow == null) {
        continue;
      }

      final photoRow = await _client
          .from('profile_photos')
          .select()
          .eq('user_id', otherUserId)
          .order('sort_order')
          .limit(1)
          .maybeSingle();

      final profile = Profile.fromMap(profileRow);
      final photo = photoRow == null ? null : ProfilePhoto.fromMap(photoRow);

      previews.add(
        MatchPreview(
          id: row['id'] as String,
          profile: profile,
          createdAt: DateTime.parse(row['created_at'] as String),
          photoUrl: photo?.publicUrl,
        ),
      );
    }

    return previews;
  }
}
