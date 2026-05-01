import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/app_models.dart';
import '../../core/supabase/supabase_config.dart';
import 'matches_repository.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  return MatchesRepository(SupabaseConfig.client);
});

final matchesViewModelProvider =
    AsyncNotifierProvider<MatchesViewModel, List<MatchPreview>>(
      MatchesViewModel.new,
    );

class MatchesViewModel extends AsyncNotifier<List<MatchPreview>> {
  @override
  Future<List<MatchPreview>> build() async {
    if (!SupabaseConfig.isConfigured) {
      return const [];
    }

    return ref.read(matchesRepositoryProvider).loadMatches();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      ref.read(matchesRepositoryProvider).loadMatches,
    );
  }
}
