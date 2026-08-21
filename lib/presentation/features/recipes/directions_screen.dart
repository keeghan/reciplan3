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

  // Uses a split detail layout on tablets and a collapsing hero on phones.
  @override
  Widget build(BuildContext context) {
    final isExpanded = MediaQuery.sizeOf(context).width >= AppBreakpoints.expanded;
    if (isExpanded) {
      return Scaffold(
        appBar: AppBar(
          title: Text(recipe.name),
          actions: [
            if (_hasVideo(recipe))
              IconButton.filled(
                tooltip: 'Watch recipe video',
                onPressed: () => _openVideo(context, recipe.videoLink),
                icon: const Icon(Icons.play_arrow_rounded),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: AppConstrainedContent(
          maxWidth: AppBreakpoints.wideContent,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesignTokens.radius20),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Hero(
                      tag: 'recipe-${recipe.id}-${recipe.imageUrl}',
                      child: ReciplanImage(
                        imageUrl: recipe.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  child: _RecipeInformation(
                    recipe: recipe,
                    showVideoAction: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _RecipeHeroAppBar(recipe: recipe),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverToBoxAdapter(
              child: _RecipeInformation(recipe: recipe, showTitle: false),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailsPane extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsPane({super.key, required this.recipe});

  // Builds details without a Hero for the tablet master-detail pane.
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        key: ValueKey('recipe-details-${recipe.id}'),
        slivers: [
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 16 / 8,
              child: ReciplanImage(
                imageUrl: recipe.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            sliver: SliverToBoxAdapter(
              child: _RecipeInformation(
                recipe: recipe,
                showVideoAction: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeSelectionPrompt extends StatelessWidget {
  const RecipeSelectionPrompt({super.key});

  // Centers the initial state within the tablet detail pane.
  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.touch_app_outlined,
      title: 'Select a recipe',
      message: 'Choose a recipe to see its ingredients and directions.',
    );
  }
}

class _RecipeHeroAppBar extends StatelessWidget {
  final Recipe recipe;

  const _RecipeHeroAppBar({required this.recipe});

  // Builds the phone-only collapsing recipe header.
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
                  colors: [Colors.black26, Colors.transparent, Colors.black87],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_hasVideo(recipe))
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filled(
              tooltip: 'Watch recipe video',
              style: IconButton.styleFrom(
                backgroundColor: AppDesignTokens.terracotta,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _openVideo(context, recipe.videoLink),
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          ),
      ],
    );
  }
}

class _RecipeInformation extends StatelessWidget {
  final Recipe recipe;
  final bool showTitle;
  final bool showVideoAction;

  const _RecipeInformation({
    required this.recipe,
    this.showTitle = true,
    this.showVideoAction = false,
  });

  // Shares recipe metadata and sections across routed and embedded details.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(recipe.name, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
        ],
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
              if (showVideoAction && _hasVideo(recipe))
                ActionChip(
                  avatar: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Watch video'),
                  onPressed: () => _openVideo(context, recipe.videoLink),
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
                          margin: const EdgeInsets.only(top: 7, right: 12),
                          decoration: BoxDecoration(
                            color: scheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
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
    );
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

  const _RecipeSection({
    required this.title,
    required this.icon,
    required this.child,
  });

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

// Accepts only non-empty video links with a URI scheme.
bool _hasVideo(Recipe recipe) {
  return recipe.videoLink.trim().isNotEmpty && Uri.tryParse(recipe.videoLink)?.hasScheme == true;
}

// Opens a recipe video externally.
Future<void> _openVideo(BuildContext context, String link) async {
  final launched = await launchUrl(
    Uri.parse(link),
    mode: LaunchMode.externalApplication,
  );
  if (!launched && context.mounted) {
    MyUtils.showSnackBar(context, 'Could not open the recipe video');
  }
}

// Splits stored ingredient lines.
List<String> _lines(String value) {
  return value
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
