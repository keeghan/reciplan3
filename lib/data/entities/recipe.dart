import 'package:floor/floor.dart';

@Entity(tableName: 'recipe_table')
class Recipe {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final int mins;
  final int numIngredients;
  final String direction;
  final String ingredients;
  final String imageUrl;
  final bool collection;
  final bool favorite;
  final int mealType;
  final bool userCreated;
  final String videoLink;

  Recipe(
      {this.id,
      required this.name,
      required this.mins,
      required this.numIngredients,
      required this.direction,
      required this.ingredients,
      required this.imageUrl,
      required this.collection,
      required this.favorite,
      required this.mealType,
      this.userCreated = false,
      required this.videoLink});

  @override
  String toString() {
    return 'Recipe(name: $name, type: $mealType)\n';
  }

  Recipe copyWith(
      {int? id,
      String? name,
      int? mins,
      int? numIngredients,
      String? direction,
      String? ingredients,
      String? imageUrl,
      bool? collection,
      bool? favorite,
      int? mealType,
      bool? userCreated,
      String? videoLink}) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      mins: mins ?? this.mins,
      numIngredients: numIngredients ?? this.numIngredients,
      direction: direction ?? this.direction,
      ingredients: ingredients ?? this.ingredients,
      imageUrl: imageUrl ?? this.imageUrl,
      collection: collection ?? this.collection,
      favorite: favorite ?? this.favorite,
      mealType: mealType ?? this.mealType,
      userCreated: userCreated ?? this.userCreated,
      videoLink: videoLink ?? this.videoLink,
    );
  }
}
