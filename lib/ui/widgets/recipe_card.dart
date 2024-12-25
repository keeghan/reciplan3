import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const RecipeCard ({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.fromLTRB(50,24,50,24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
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
            padding: const EdgeInsets.fromLTRB(6,2,8,2),
            child: OverflowBar(
              alignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () {},
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
