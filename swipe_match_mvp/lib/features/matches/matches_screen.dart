import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import 'matches_view_model.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesState = ref.watch(matchesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.go('/discover'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: matchesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(friendlyError(error))),
        data: (matches) {
          if (matches.isEmpty) {
            return const _EmptyMatches();
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(matchesViewModelProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final match = matches[index];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: CircleAvatar(
                    backgroundImage: match.photoUrl == null
                        ? null
                        : NetworkImage(match.photoUrl!),
                    child: match.photoUrl == null
                        ? Text(match.profile.displayName.characters.first)
                        : null,
                  ),
                  title: Text(match.profile.displayName),
                  subtitle: Text(
                    match.profile.city.isEmpty
                        ? 'Matched recently'
                        : match.profile.city,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 56),
            const SizedBox(height: 16),
            Text(
              'No matches yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Keep discovering people. A match appears when both people like each other.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
