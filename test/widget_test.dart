import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reciplan3/presentation/features/recipes/explore_screen.dart';

void main() {
  testWidgets('Explore screen shows meal categories', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExploreScreen(),
      ),
    );

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    expect(find.text('Snack'), findsOneWidget);
  });
}
