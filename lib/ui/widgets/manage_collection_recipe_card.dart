import 'package:flutter/material.dart';

import '../../data/entities/recipe.dart';
import '../../util/utils.dart';
import 'network_image_with_placeholder.dart';

//Widget to be used in collectionManagementScreen to add or
//remove recipes from Collection
class ManageCollectionRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onCheckPress;
  final VoidCallback onRemovePress;
  final VoidCallback onDirectionPress;
  final VoidCallback onDeletePress;

  const ManageCollectionRecipeCard({
    super.key,
    required this.recipe,
    required this.onCheckPress,
    required this.onRemovePress,
    required this.onDirectionPress,
    required this.onDeletePress,
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: ReciplanImage(
                  imageUrl: recipe.imageUrl,
                  height: 250,
                  width: double.infinity,
                ),
              ),
              //User Recipe Delete Icon
              if (recipe.userCreated) ...[
                Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      color: Colors.red,
                      icon: const Icon(Icons.delete),
                      onPressed: () => MyUtils.showDeleteConfirmationDialog(
                        context,
                        "Confirm Deletion",
                        "Are you sure you want to delete this recipe?",
                        onDeletePress,
                      ),
                    ))
              ],
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    //recipe.collection is false, show the "add" button otherwise remove
                    if (!recipe.collection)
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

                    if (recipe.collection)
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
                  recipe.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${recipe.mins} mins | ${recipe.numIngredients} ingredients',
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
