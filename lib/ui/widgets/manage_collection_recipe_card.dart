import 'package:flutter/material.dart';

import 'network_image_with_placeholder.dart';

//Widget to be used in collectionManagementScreen to add or
//remove recipes from Collection
class ManageCollectionRecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final VoidCallback onCheckPress;
  final VoidCallback onRemovePress;
  final VoidCallback onDirectionPress;

  const ManageCollectionRecipeCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onCheckPress,
    required this.onRemovePress,
    required this.onDirectionPress,
  });

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
                child: NetworkImageWithPlaceholder(
                  imageUrl: imageUrl,
                  height: 250,
                  width: double.infinity,
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: onCheckPress,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: onRemovePress,
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
