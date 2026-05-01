import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/app_error.dart';
import '../../core/models/app_models.dart';
import '../auth/auth_view_model.dart';
import 'discovery_view_model.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsState = ref.watch(discoveryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Matches',
            onPressed: () => context.go('/matches'),
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => ref.read(authActionProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: cardsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(friendlyError(error))),
        data: (cards) {
          if (cards.isEmpty) {
            return _EmptyDiscovery(
              onRefresh: () =>
                  ref.read(discoveryViewModelProvider.notifier).refresh(),
            );
          }

          return _CardStack(
            cards: cards,
            onPass: (card) =>
                ref.read(discoveryViewModelProvider.notifier).pass(card),
            onLike: (card) =>
                ref.read(discoveryViewModelProvider.notifier).like(card),
          );
        },
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.cards,
    required this.onPass,
    required this.onLike,
  });

  final List<DiscoveryCard> cards;
  final ValueChanged<DiscoveryCard> onPass;
  final ValueChanged<DiscoveryCard> onLike;

  @override
  Widget build(BuildContext context) {
    final card = cards.first;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(child: _DiscoveryCard(card: card)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                iconSize: 32,
                tooltip: 'Pass',
                onPressed: () => onPass(card),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                iconSize: 32,
                tooltip: 'Like',
                onPressed: () => onLike(card),
                icon: const Icon(Icons.favorite),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  const _DiscoveryCard({required this.card});

  final DiscoveryCard card;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (card.heroImageUrl != null)
            Image.network(card.heroImageUrl!, fit: BoxFit.cover)
          else
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.person, size: 96),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.profile.displayName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (card.profile.city.isNotEmpty)
                  Text(
                    card.profile.city,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                if (card.profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    card.profile.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDiscovery extends StatelessWidget {
  const _EmptyDiscovery({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.style_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'No more cards',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later or update your profile while new people join.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
