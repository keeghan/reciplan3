import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
import 'package:reciplan3/presentation/widgets/network_image_with_placeholder.dart';
import 'package:reciplan3/util/utils.dart';

class DirectionsScreen extends StatelessWidget {
  final Recipe recipe;

  const DirectionsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasVideo = recipe.videoLink.trim().isNotEmpty &&
        Uri.tryParse(recipe.videoLink)?.hasScheme == true;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            backgroundColor: AppDesignTokens.primary,
            foregroundColor: Colors.white,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            title: Text(recipe.name),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'recipe-${recipe.id}-${recipe.imageUrl}',
                    child: ReciplanImage(
                      imageUrl: recipe.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black87,
                        ],
                        stops: [0, 0.5, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (hasVideo)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton.filled(
                    tooltip: 'Watch recipe video',
                    style: IconButton.styleFrom(
                      backgroundColor: AppDesignTokens.terracotta,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _openVideo(context),
                    icon: const Icon(Icons.play_arrow_rounded),
                  ),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList.list(
              children: [
                AppEntrance(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetadataChip(
                        icon: Icons.schedule,
                        label: '${recipe.mins} minutes',
                      ),
                      _MetadataChip(
                        icon: Icons.restaurant_menu,
                        label: '${recipe.numIngredients} ingredients',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppEntrance(
                  index: 1,
                  child: _RecipeSection(
                    title: 'Ingredients',
                    icon: Icons.shopping_basket_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final ingredient in _lines(recipe.ingredients))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  margin:
                                      const EdgeInsets.only(top: 7, right: 12),
                                  decoration: BoxDecoration(
                                    color: scheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(height: 1.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppEntrance(
                  index: 2,
                  child: _RecipeSection(
                    title: 'Directions',
                    icon: Icons.format_list_numbered,
                    child: Text(
                      recipe.direction.trim(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.65,
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Opens the recipe video externally.
  Future<void> _openVideo(BuildContext context) async {
    final launched = await launchUrl(
      Uri.parse(recipe.videoLink),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      MyUtils.showSnackBar(context, 'Could not open the recipe video');
    }
  }

  // Splits stored ingredient lines.
  static List<String> _lines(String value) {
    return value
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      side: BorderSide.none,
    );
  }
}

class _RecipeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _RecipeSection(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
