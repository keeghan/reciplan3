import 'package:flutter/material.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'collection_management_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const List<Map<String, Object>> categories = [
    {
      'title': 'Breakfast',
      'mealType': MealType.breakfast,
      'image': 'assets/images/breakfast.webp',
    },
    {
      'title': 'Snack',
      'mealType': MealType.snack,
      'image': 'assets/images/snacks.webp',
    },
    {
      'title': 'Lunch',
      'mealType': MealType.lunch,
      'image': 'assets/images/lunch.webp',
    },
    {
      'title': 'Dinner',
      'mealType': MealType.dinner,
      'image': 'assets/images/dinner.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 400,
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: categories.map((category) {
              final title = category['title']! as String;
              final mealType = category['mealType']! as MealType;
              final image = category['image']! as String;

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionManagementScreen(
                        title: title,
                        mealType: mealType,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
