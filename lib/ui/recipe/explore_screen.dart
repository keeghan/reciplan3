import 'package:flutter/material.dart';

import 'collection_management_screen.dart';

class ExploreScreen extends StatelessWidget {
  //Four Images represent variious MealTypes
  static const List<Map<String, String>> categories = [
    {
      'title': 'Breakfast',
      'image': 'assets/images/breakfast.webp',
    },
    {
      'title': 'Snack',
      'image': 'assets/images/snacks.webp',
    },
    {
      'title': 'Lunch',
      'image': 'assets/images/lunch.webp',
    },
    {
      'title': 'Dinner',
      'image': 'assets/images/dinner.jpeg',
    },
  ];

  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 400,
          //  height: MediaQuery.of(context).size.height * 0.5,
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: categories.map((category) {
              return InkWell(
                onTap: () {
                  // Handle navigation to other CollectionManagementScreen
                  //by passing the mealType
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionManagementScreen(
                          collectionId: category['title']!),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(category['image']!),
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
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          category['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ), //end of main container
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
