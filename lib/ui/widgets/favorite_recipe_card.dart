import 'package:flutter/material.dart';

import 'network_image_with_placeholder.dart';

class FavoriteRecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onDirectionPress;
  final VoidCallback onFavoriteClicked;

  const FavoriteRecipeCard(
      {super.key,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.onDirectionPress,
      required this.onFavoriteClicked,
      required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            // Wrap Stack in Expanded to take remaining space
            child: Stack(
              fit: StackFit.expand, // Make Stack fill available space
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: NetworkImageWithPlaceholder(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover, // Make image cover available space
                    width: double.infinity, height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    iconSize: 32,
                    padding: const EdgeInsets.all(8),
                    color: isFavorite ? Colors.red : Colors.grey,
                    icon: const Icon(
                      Icons.favorite,
                      size: 32,
                    ),
                    onPressed: onFavoriteClicked,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.directions),
                      onPressed: onDirectionPress,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 2, // Limit title to 2 lines
                  overflow:
                      TextOverflow.ellipsis, // Show ellipsis if text overflows
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
