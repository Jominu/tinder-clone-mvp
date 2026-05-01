import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/app_models.dart';

class DiscoveryRepository {
  const DiscoveryRepository(this._client);

  final SupabaseClient _client;

  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('User is not signed in.');
    }
    return id;
  }

  Future<List<DiscoveryCard>> loadCards() async {
    final swipedRows = await _client
        .from('swipes')
        .select('swiped_id')
        .eq('swiper_id', _currentUserId);

    final swipedIds =
        swipedRows.map<String>((row) => row['swiped_id'] as String).toSet()
          ..add(_currentUserId);

    final rows = await _client
        .from('profiles')
        .select('*, profile_photos(*)')
        .limit(30);

    return rows
        .where((row) => !swipedIds.contains(row['id'] as String))
        .map<DiscoveryCard>((row) {
          final photos =
              ((row['profile_photos'] as List?) ?? const [])
                  .map(
                    (photo) =>
                        ProfilePhoto.fromMap(photo as Map<String, dynamic>),
                  )
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          return DiscoveryCard(profile: Profile.fromMap(row), photos: photos);
        })
        .toList();
  }

  Future<void> swipe({
    required String targetUserId,
    required String decision,
  }) async {
    await _client.from('swipes').upsert({
      'swiper_id': _currentUserId,
      'swiped_id': targetUserId,
      'decision': decision,
    });

    if (decision == 'like') {
      await _tryCreateMatch(targetUserId);
    }
  }

  Future<void> _tryCreateMatch(String targetUserId) async {
    final userIds = [_currentUserId, targetUserId]..sort();

    try {
      await _client.from('matches').insert({
        'user_a_id': userIds.first,
        'user_b_id': userIds.last,
      });
    } catch (_) {
      // No reciprocal like yet, or the match already exists. Both are fine.
    }
  }
}
