import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_config.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(SupabaseConfig.client);
});

final authUserProvider = StreamProvider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return const Stream<User?>.empty();
  }

  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges
      .map((event) => event.session?.user)
      .distinct();
});

final currentUserProvider = Provider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return null;
  }

  ref.watch(authUserProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

final authActionProvider = AsyncNotifierProvider<AuthActionViewModel, void>(
  AuthActionViewModel.new,
);

class AuthActionViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password);
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref
          .read(authRepositoryProvider)
          .signUp(email: email.trim(), password: password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(ref.read(authRepositoryProvider).signOut);
  }
}
