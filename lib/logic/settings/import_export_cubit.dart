import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/import_export_service.dart';
import 'package:reciplan3/logic/settings/import_export_state.dart';

class ImportExportCubit extends Cubit<ImportExportState> {
  final RecipeRepository _recipeRepository;
  final ImportExportService _importExportService;

  ImportExportCubit(
    this._recipeRepository,
    this._importExportService,
  ) : super(const ImportExportState());

  Future<void> exportRecipes(String fileNamePrefix) async {
    emit(state.copyWith(isBusy: true, clearError: true, clearSuccess: true));
    try {
      final recipes = await _recipeRepository.getUserCreatedRecipes();
      if (recipes.isEmpty) {
        emit(state.copyWith(isBusy: false, errorMessage: 'No local recipes to export'));
        return;
      }

      final result = await _importExportService.exportRecipes(
        recipes: recipes,
        fileNamePrefix: fileNamePrefix,
      );
      final message = result.copiedToDownloads
          ? 'Exported to Downloads folder'
          : 'Exported locally to ${result.filePath}';
      emit(state.copyWith(isBusy: false, successMessage: message, clearError: true));
    } catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: 'Error exporting recipes: $error'));
    }
  }

  Future<void> importRecipes() async {
    emit(state.copyWith(isBusy: true, clearError: true, clearSuccess: true));
    try {
      final recipes = await _importExportService.pickRecipesForImport();
      if (recipes == null) {
        emit(state.copyWith(isBusy: false));
        return;
      }
      await _recipeRepository.importRecipes(recipes);
      emit(
        state.copyWith(
          isBusy: false,
          successMessage: '${recipes.length} recipes imported',
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isBusy: false, errorMessage: 'Error importing recipes: $error'));
    }
  }

  void clearFeedback() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
