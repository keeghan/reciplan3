import 'package:equatable/equatable.dart';

import 'package:reciplan3/logic/data/entities/recipe.dart';

class CollectionState extends Equatable {
  final bool isLoading;
  final List<Recipe> recipes;
  final String? errorMessage;
  final String? actionMessage;

  const CollectionState({
    this.isLoading = false,
    this.recipes = const [],
    this.errorMessage,
    this.actionMessage,
  });

  bool get isEmpty => !isLoading && errorMessage == null && recipes.isEmpty;

  CollectionState copyWith({
    bool? isLoading,
    List<Recipe>? recipes,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearAction = false,
  }) {
    return CollectionState(
      isLoading: isLoading ?? this.isLoading,
      recipes: recipes ?? this.recipes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearAction ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, recipes, errorMessage, actionMessage];
}
