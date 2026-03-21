import 'package:equatable/equatable.dart';

class RecipeEditorState extends Equatable {
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const RecipeEditorState({
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  RecipeEditorState copyWith({
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RecipeEditorState(
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: clearSuccess ? false : saveSuccess ?? this.saveSuccess,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isSaving, saveSuccess, errorMessage];
}
