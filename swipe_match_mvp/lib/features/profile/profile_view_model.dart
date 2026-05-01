import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/app_models.dart';
import '../../core/supabase/supabase_config.dart';
import 'profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(SupabaseConfig.client);
});

final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, Profile?>(ProfileViewModel.new);

class ProfileViewModel extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }

    return ref.read(profileRepositoryProvider).loadCurrentProfile();
  }

  Future<void> save({
    required String displayName,
    required String bio,
    required String city,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(profileRepositoryProvider)
          .saveProfile(displayName: displayName, bio: bio, city: city);
    });
  }

  Future<void> uploadPhoto(XFile image) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).uploadProfilePhoto(image);
      return ref.read(profileRepositoryProvider).loadCurrentProfile();
    });
  }
}
