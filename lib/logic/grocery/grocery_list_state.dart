import 'package:equatable/equatable.dart';

class GroceryItem extends Equatable {
  final String key;
  final String label;

  const GroceryItem({
    required this.key,
    required this.label,
  });

  @override
  List<Object?> get props => [key, label];
}

class GroceryGroup extends Equatable {
  final String recipeName;
  final int plannedCount;
  final List<GroceryItem> items;

  const GroceryGroup({
    required this.recipeName,
    required this.plannedCount,
    required this.items,
  });

  @override
  List<Object?> get props => [recipeName, plannedCount, items];
}

class GroceryListState extends Equatable {
  final bool isLoading;
  final List<GroceryGroup> groups;
  final Set<String> checkedItemKeys;
  final String? errorMessage;

  const GroceryListState({
    this.isLoading = true,
    this.groups = const [],
    this.checkedItemKeys = const {},
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && groups.isEmpty;

  bool get hasCheckedItems => checkedItemKeys.isNotEmpty;

  // Copies the grocery list state.
  GroceryListState copyWith({
    bool? isLoading,
    List<GroceryGroup>? groups,
    Set<String>? checkedItemKeys,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GroceryListState(
      isLoading: isLoading ?? this.isLoading,
      groups: groups ?? this.groups,
      checkedItemKeys: checkedItemKeys ?? this.checkedItemKeys,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, groups, checkedItemKeys, errorMessage];
}
