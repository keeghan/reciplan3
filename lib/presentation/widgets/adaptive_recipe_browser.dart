import 'package:flutter/material.dart';
import 'package:reciplan3/logic/data/entities/recipe.dart';
import 'package:reciplan3/presentation/features/recipes/directions_screen.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';

typedef RecipeCardBuilder = Widget Function(
  BuildContext context,
  Recipe recipe,
  VoidCallback onOpen,
  bool selected,
);

class AdaptiveRecipeBrowser extends StatefulWidget {
  final List<Recipe> recipes;
  final RecipeCardBuilder cardBuilder;
  final String storageKey;

  const AdaptiveRecipeBrowser({
    super.key,
    required this.recipes,
    required this.cardBuilder,
    required this.storageKey,
  });

  @override
  State<AdaptiveRecipeBrowser> createState() => _AdaptiveRecipeBrowserState();
}

class _AdaptiveRecipeBrowserState extends State<AdaptiveRecipeBrowser>
    with AutomaticKeepAliveClientMixin {
  int? _selectedRecipeId;

  // Clears a selection that no longer exists in the source list.
  @override
  void didUpdateWidget(covariant AdaptiveRecipeBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedRecipeId != null &&
        !widget.recipes.any((recipe) => recipe.id == _selectedRecipeId)) {
      _selectedRecipeId = null;
    }
  }

  // Uses routed details on phones and master-detail on wide tablets.
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isExpanded = MediaQuery.sizeOf(context).width >= AppBreakpoints.expanded;
    final isActive = TickerMode.valuesOf(context).enabled;
    final selectedRecipe = _selectedRecipeId == null
        ? null
        : widget.recipes.where((recipe) => recipe.id == _selectedRecipeId).firstOrNull;

    return PopScope(
      canPop: !isExpanded || selectedRecipe == null || !isActive,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && selectedRecipe != null) {
          setState(() => _selectedRecipeId = null);
        }
      },
      child: isExpanded
          ? Row(
              children: [
                Expanded(
                  flex: 7,
                  child: _RecipeGrid(
                    recipes: widget.recipes,
                    storageKey: widget.storageKey,
                    selectedRecipeId: _selectedRecipeId,
                    masterPane: true,
                    cardBuilder: widget.cardBuilder,
                    onOpen: (recipe) {
                      setState(() => _selectedRecipeId = recipe.id);
                    },
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 10,
                  child: AnimatedSwitcher(
                    duration: AppMotion.duration(context, AppMotion.state),
                    child: selectedRecipe == null
                        ? const RecipeSelectionPrompt(key: ValueKey('recipe-selection-prompt'))
                        : RecipeDetailsPane(
                            key: ValueKey(selectedRecipe.id),
                            recipe: selectedRecipe,
                          ),
                  ),
                ),
              ],
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppBreakpoints.wideContent),
                child: _RecipeGrid(
                  recipes: widget.recipes,
                  storageKey: widget.storageKey,
                  selectedRecipeId: null,
                  masterPane: false,
                  cardBuilder: widget.cardBuilder,
                  onOpen: (recipe) {
                    Navigator.push(
                      context,
                      AppRoute.build(context, DirectionsScreen(recipe: recipe)),
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _RecipeGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final String storageKey;
  final int? selectedRecipeId;
  final bool masterPane;
  final RecipeCardBuilder cardBuilder;
  final ValueChanged<Recipe> onOpen;

  const _RecipeGrid({
    required this.recipes,
    required this.storageKey,
    required this.selectedRecipeId,
    required this.masterPane,
    required this.cardBuilder,
    required this.onOpen,
  });

  // Sizes cards for either the master pane or the full content area.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final masterColumns = constraints.maxWidth >= 560 ? 2 : 1;
        final delegate = masterPane
            ? SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: masterColumns,
                childAspectRatio: masterColumns == 1 ? 1.2 : 0.78,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              )
            : const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                childAspectRatio: 0.78,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              );
        return GridView.builder(
          key: PageStorageKey(storageKey),
          padding: EdgeInsets.all(AppBreakpoints.gutter(context)),
          gridDelegate: delegate,
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return cardBuilder(
              context,
              recipe,
              () => onOpen(recipe),
              recipe.id == selectedRecipeId,
            );
          },
        );
      },
    );
  }
}
