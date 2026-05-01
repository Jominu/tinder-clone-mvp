import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/errors/app_error.dart';
import '../auth/auth_view_model.dart';
import 'profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);

    ref.listen(profileViewModelProvider, (previous, next) {
      if (next.hasError && next.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(next.error!))));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => ref.read(authActionProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(friendlyError(error))),
        data: (profile) {
          if (!_hydrated && profile != null) {
            _nameController.text = profile.displayName;
            _bioController.text = profile.bio;
            _cityController.text = profile.city;
            _hydrated = true;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (profile?.primaryPhotoUrl != null)
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      profile!.primaryPhotoUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Add a profile photo'),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Upload photo'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _save, child: const Text('Save profile')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.go('/discover'),
                child: const Text('Go to discovery'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(profileViewModelProvider.notifier)
        .save(
          displayName: _nameController.text,
          bio: _bioController.text,
          city: _cityController.text,
        );
  }

  Future<void> _pickPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    await ref.read(profileViewModelProvider.notifier).uploadPhoto(image);
  }
}
