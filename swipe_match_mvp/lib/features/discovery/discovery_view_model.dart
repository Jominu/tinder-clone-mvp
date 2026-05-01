import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_models.dart';
import '../../core/supabase/supabase_config.dart';
import 'discovery_repository.dart';

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(SupabaseConfig.client);
});

final discoveryViewModelProvider =
    AsyncNotifierProvider<DiscoveryViewModel, List<DiscoveryCard>>(
      DiscoveryViewModel.new,
    );

class DiscoveryViewModel extends AsyncNotifier<List<DiscoveryCard>> {
  @override
  Future<List<DiscoveryCard>> build() async {
    if (!SupabaseConfig.isConfigured) {
      return const [];
    }

    return ref.read(discoveryRepositoryProvider).loadCards();
  }

  Future<void> like(DiscoveryCard card) => _swipe(card, 'like');

  Future<void> pass(DiscoveryCard card) => _swipe(card, 'pass');

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(discoveryRepositoryProvider).loadCards,
    );
  }

  Future<void> _swipe(DiscoveryCard card, String decision) async {
    final current = state.asData?.value ?? const <DiscoveryCard>[];
    state = AsyncData(
      current.where((item) => item.profile.id != card.profile.id).toList(),
    );

    await AsyncValue.guard(() {
      return ref
          .read(discoveryRepositoryProvider)
          .swipe(targetUserId: card.profile.id, decision: decision);
    });
  }
}
