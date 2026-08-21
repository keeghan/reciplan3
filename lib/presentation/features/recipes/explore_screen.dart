import 'package:flutter/material.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';

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

  // Caps category width while allowing more columns on tablets.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppConstrainedContent(
              maxWidth: AppBreakpoints.wideContent,
              padding: EdgeInsets.fromLTRB(
                AppBreakpoints.gutter(context),
                24,
                AppBreakpoints.gutter(context),
                16,
              ),
              child: const AppSectionHeader(
                title: 'What are you cooking?',
                subtitle: 'Browse recipes by the moment they fit best.',
              ),
            ),
          ),
          SliverLayoutBuilder(
            builder: (context, constraints) {
              final gutter = AppBreakpoints.gutter(context);
              final side = ((constraints.crossAxisExtent - AppBreakpoints.wideContent) / 2)
                  .clamp(gutter, double.infinity);
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 0, side, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    childAspectRatio: 0.92,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = categories[index];
                    final title = category['title']! as String;
                    final mealType = category['mealType']! as MealType;
                    final image = category['image']! as String;

                    return AppEntrance(
                      index: index,
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              AppRoute.build(
                                context,
                                CollectionManagementScreen(
                                  title: title,
                                  mealType: mealType,
                                ),
                              ),
                            );
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(image),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black87],
                                  stops: [0.35, 1],
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    title,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: categories.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
