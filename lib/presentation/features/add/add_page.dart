import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_draft.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_cubit.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_state.dart';
import 'package:reciplan3/presentation/features/settings/settings_screen.dart';
import 'package:reciplan3/util/utils.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeEditorCubit(
        context.read<RecipeRepository>(),
        context.read<LocalImageStorageService>(),
      ),
      child: const _AddPageView(),
    );
  }
}

class _AddPageView extends StatefulWidget {
  const _AddPageView();

  @override
  State<_AddPageView> createState() => _AddPageViewState();
}

class _AddPageViewState extends State<_AddPageView> {
  final _titleController = TextEditingController();
  final _directionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _videoLinkController = TextEditingController();
  File? _selectedImage;

  bool _showTitleError = false;
  bool _showDirectionsError = false;
  bool _showImageError = false;
  bool _showIngredientsError = false;

  MealType _mealType = MealType.breakfast;
  bool _isFavorite = false;
  bool _isCollection = true;
  int _selectedDuration = 10;

  @override
  void dispose() {
    _titleController.dispose();
    _directionController.dispose();
    _ingredientsController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecipeEditorCubit, RecipeEditorState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.saveSuccess != current.saveSuccess,
      listener: (context, state) {
        if (state.errorMessage != null) {
          MyUtils.showSnackBar(context, state.errorMessage!);
          context.read<RecipeEditorCubit>().clearFeedback();
          return;
        }

        if (state.saveSuccess) {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
          MyUtils.showSnackBar(context, 'Recipe saved successfully');
          _clearFields();
          context.read<RecipeEditorCubit>().clearFeedback();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ReciplanCustomColors.appBarColor,
          foregroundColor: Colors.white,
          title: const Text('Reciplan'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: _showTitleError ? 'Title is required' : null,
                  ),
                  onChanged: (value) {
                    if (_showTitleError && value.trim().isNotEmpty) {
                      setState(() => _showTitleError = false);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _directionController,
                  decoration: InputDecoration(
                    labelText: 'Directions',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: _showDirectionsError ? 'Directions are required' : null,
                  ),
                  onChanged: (value) {
                    if (_showDirectionsError && value.trim().isNotEmpty) {
                      setState(() => _showDirectionsError = false);
                    }
                  },
                  maxLines: 4,
                  minLines: 4,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: _showImageError ? Border.all(color: Colors.red, width: 2) : null,
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline, size: 48),
                                if (_showImageError)
                                  const Text(
                                    'Image required',
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _validateAndProceed(context),
                  child: const Text('Next'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return BlocBuilder<RecipeEditorCubit, RecipeEditorState>(
              builder: (context, state) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ingredientsController,
                              decoration: InputDecoration(
                                labelText: 'Ingredients List',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorText: _showIngredientsError ? 'Ingredients are required' : null,
                              ),
                              maxLines: 5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            children: [
                              Text('Duration', style: Theme.of(context).textTheme.bodySmall),
                              NumberPicker(
                                minValue: 5,
                                maxValue: 200,
                                value: _selectedDuration,
                                onChanged: (value) {
                                  setState(() => _selectedDuration = value);
                                  setBottomSheetState(() {});
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: MealType.values
                            .where((item) => item != MealType.missing)
                            .map((type) => _buildTypeChip(type, setBottomSheetState))
                            .toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            const Text('Collection: '),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _isCollection,
                                onChanged: (value) {
                                  setState(() {
                                    _isCollection = value;
                                    if (!_isCollection) {
                                      _isFavorite = false;
                                    }
                                  });
                                  setBottomSheetState(() {});
                                },
                              ),
                            ),
                            const Spacer(),
                            const Text('Favorite: '),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: _isFavorite,
                                onChanged: (value) {
                                  setState(() {
                                    _isFavorite = value;
                                    if (_isFavorite) {
                                      _isCollection = true;
                                    }
                                  });
                                  setBottomSheetState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextField(
                        controller: _videoLinkController,
                        decoration: InputDecoration(
                          labelText: 'Video Link (Optional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 6,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        ),
                        onPressed: state.isSaving ? null : () => _submit(context),
                        child: Text(
                          state.isSaving ? 'Saving...' : 'Save',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(MealType type, StateSetter setBottomSheetState) {
    final isSelected = _mealType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _mealType = type);
        setBottomSheetState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          type.label.toLowerCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showImageError = false;
      });
    }
  }

  void _validateAndProceed(BuildContext context) {
    setState(() {
      _showTitleError = _titleController.text.trim().isEmpty;
      _showDirectionsError = _directionController.text.trim().isEmpty;
      _showImageError = _selectedImage == null;
    });

    if (!_showTitleError && !_showDirectionsError && !_showImageError) {
      _showBottomSheet(context);
    }
  }

  void _submit(BuildContext context) {
    setState(() {
      _showIngredientsError = _ingredientsController.text.trim().isEmpty;
    });

    if (_showTitleError ||
        _showDirectionsError ||
        _showImageError ||
        _showIngredientsError ||
        _selectedImage == null) {
      MyUtils.showSnackBar(context, 'Please fill all required fields.');
      return;
    }

    context.read<RecipeEditorCubit>().saveRecipe(
          RecipeDraft(
            name: _titleController.text.trim(),
            mins: _selectedDuration,
            numIngredients: _ingredientsController.text.trim().split('\n').length,
            direction: _directionController.text.trim(),
            ingredients: _ingredientsController.text.trim(),
            imagePath: _selectedImage!.path,
            collection: _isCollection,
            favorite: _isFavorite,
            mealType: _mealType,
            videoLink: _videoLinkController.text.trim(),
          ),
        );
  }

  void _clearFields() {
    _titleController.clear();
    _directionController.clear();
    _ingredientsController.clear();
    _videoLinkController.clear();
    _selectedImage = null;
    _showTitleError = false;
    _showDirectionsError = false;
    _showImageError = false;
    _showIngredientsError = false;
    _mealType = MealType.breakfast;
    _isFavorite = false;
    _isCollection = true;
    _selectedDuration = 10;
    setState(() {});
  }
}
