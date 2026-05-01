class Profile {
  const Profile({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.city,
    this.birthdate,
    this.primaryPhotoUrl,
  });

  final String id;
  final String displayName;
  final String bio;
  final String city;
  final DateTime? birthdate;
  final String? primaryPhotoUrl;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      displayName: (map['display_name'] as String?) ?? '',
      bio: (map['bio'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      birthdate: map['birthdate'] == null
          ? null
          : DateTime.tryParse(map['birthdate'] as String),
      primaryPhotoUrl: map['primary_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toUpsertMap() {
    return {
      'id': id,
      'display_name': displayName,
      'bio': bio,
      'city': city,
      if (birthdate != null) 'birthdate': birthdate!.toIso8601String(),
    };
  }
}

class ProfilePhoto {
  const ProfilePhoto({
    required this.id,
    required this.userId,
    required this.storagePath,
    required this.publicUrl,
    required this.sortOrder,
  });

  final String id;
  final String userId;
  final String storagePath;
  final String publicUrl;
  final int sortOrder;

  factory ProfilePhoto.fromMap(Map<String, dynamic> map) {
    return ProfilePhoto(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      storagePath: map['storage_path'] as String,
      publicUrl: map['public_url'] as String,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class DiscoveryCard {
  const DiscoveryCard({required this.profile, required this.photos});

  final Profile profile;
  final List<ProfilePhoto> photos;

  String? get heroImageUrl {
    if (photos.isNotEmpty) {
      return photos.first.publicUrl;
    }
    return profile.primaryPhotoUrl;
  }
}

class MatchPreview {
  const MatchPreview({
    required this.id,
    required this.profile,
    required this.createdAt,
    this.photoUrl,
  });

  final String id;
  final Profile profile;
  final DateTime createdAt;
  final String? photoUrl;
}
