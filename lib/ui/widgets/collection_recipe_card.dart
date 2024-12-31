import 'package:flutter/material.dart';

import 'network_image_with_placeholder.dart';

class CollectionRecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final bool isFavorite;
  final VoidCallback onDirectionPress;
  final VoidCallback onFavoriteClicked;

  const CollectionRecipeCard(
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
      margin: const EdgeInsets.fromLTRB(50, 24, 50, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: ReciplanImage(
                  imageUrl: imageUrl,
                  height: 250,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    AnimatedScale(
                      scale: isFavorite ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 8, 2),
            child: OverflowBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: onDirectionPress,
                  child: const Text('Directions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
