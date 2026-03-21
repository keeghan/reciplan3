import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/core/models/recipe_draft.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_state.dart';

class RecipeEditorCubit extends Cubit<RecipeEditorState> {
  final RecipeRepository _recipeRepository;
  final LocalImageStorageService _imageStorageService;

  RecipeEditorCubit(
    this._recipeRepository,
    this._imageStorageService,
  ) : super(const RecipeEditorState());

  Future<void> saveRecipe(RecipeDraft draft) async {
    emit(state.copyWith(isSaving: true, clearError: true, clearSuccess: true));
    try {
      final imagePath = await _imageStorageService.storeImage(draft.imagePath);
      await _recipeRepository.createRecipe(
        RecipeDraft(
          name: draft.name,
          mins: draft.mins,
          numIngredients: draft.numIngredients,
          direction: draft.direction,
          ingredients: draft.ingredients,
          imagePath: imagePath,
          collection: draft.collection,
          favorite: draft.favorite,
          mealType: draft.mealType,
          videoLink: draft.videoLink,
        ),
      );
      emit(state.copyWith(isSaving: false, saveSuccess: true, clearError: true));
    } catch (error) {
      emit(state.copyWith(isSaving: false, errorMessage: 'Error: $error'));
    }
  }

  void clearFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
