import 'package:flutter/material.dart';

import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'network_image_with_placeholder.dart';

class AdaptiveRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onOpen;
  final VoidCallback? onFavorite;
  final VoidCallback? onCollection;
  final VoidCallback? onDelete;

  const AdaptiveRecipeCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    this.onFavorite,
    this.onCollection,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
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
                        colors: [Colors.black26, Colors.transparent],
                        stops: [0, 0.45],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onDelete != null)
                          _ImageAction(
                            tooltip: 'Delete recipe',
                            icon: Icons.delete_outline,
                            color: scheme.error,
                            onPressed: onDelete!,
                          ),
                        if (onFavorite != null)
                          _ImageAction(
                            tooltip: recipe.favorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                            icon: recipe.favorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: recipe.favorite
                                ? const Color(0xFFE15148)
                                : Colors.white,
                            onPressed: onFavorite!,
                            animate: true,
                          ),
                      ],
                    ),
                  ),
                  if (onCollection != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _ImageAction(
                        tooltip: recipe.collection
                            ? 'Remove from collection'
                            : 'Add to collection',
                        icon: recipe.collection
                            ? Icons.bookmark
                            : Icons.bookmark_add_outlined,
                        color: scheme.onSecondaryContainer,
                        background: scheme.secondaryContainer,
                        onPressed: onCollection!,
                        animate: true,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDesignTokens.space12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 15, color: scheme.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${recipe.mins} min  •  ${recipe.numIngredients} ingredients',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final Color? background;
  final VoidCallback onPressed;
  final bool animate;

  const _ImageAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.background,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton.filledTonal(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: background ?? Colors.black45,
        foregroundColor: color,
      ),
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: AppMotion.duration(context, AppMotion.state),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(icon, key: ValueKey(icon), size: 22),
      ),
    );
    return animate
        ? AnimatedScale(
            scale: 1,
            duration: AppMotion.duration(context, AppMotion.press),
            child: button,
          )
        : button;
  }
}
