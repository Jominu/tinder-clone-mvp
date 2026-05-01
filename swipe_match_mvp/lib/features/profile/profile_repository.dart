import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/app_models.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('User is not signed in.');
    }
    return id;
  }

  Future<Profile?> loadCurrentProfile() async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', _currentUserId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    final profile = Profile.fromMap(response);
    final photo = await loadPrimaryPhoto(profile.id);
    return Profile(
      id: profile.id,
      displayName: profile.displayName,
      bio: profile.bio,
      city: profile.city,
      birthdate: profile.birthdate,
      primaryPhotoUrl: photo?.publicUrl,
    );
  }

  Future<Profile> saveProfile({
    required String displayName,
    required String bio,
    required String city,
    DateTime? birthdate,
  }) async {
    final profile = Profile(
      id: _currentUserId,
      displayName: displayName.trim(),
      bio: bio.trim(),
      city: city.trim(),
      birthdate: birthdate,
    );

    final response = await _client
        .from('profiles')
        .upsert(profile.toUpsertMap())
        .select()
        .single();

    return Profile.fromMap(response);
  }

  Future<ProfilePhoto?> loadPrimaryPhoto(String userId) async {
    final response = await _client
        .from('profile_photos')
        .select()
        .eq('user_id', userId)
        .order('sort_order')
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return ProfilePhoto.fromMap(response);
  }

  Future<ProfilePhoto> uploadProfilePhoto(XFile image) async {
    final extension = image.name.split('.').last.toLowerCase();
    final path = '$_currentUserId/${const Uuid().v4()}.$extension';
    final bytes = await image.readAsBytes();

    await _client.storage.from('profile-photos').uploadBinary(path, bytes);
    final publicUrl = _client.storage.from('profile-photos').getPublicUrl(path);

    final response = await _client
        .from('profile_photos')
        .insert({
          'user_id': _currentUserId,
          'storage_path': path,
          'public_url': publicUrl,
          'sort_order': 0,
        })
        .select()
        .single();

    return ProfilePhoto.fromMap(response);
  }
}
