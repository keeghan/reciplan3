import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:reciplan3/data/entities/recipe.dart';

import '../../main.dart';
import '../../recipe_viewmodel.dart';
import '../../util/utils.dart';
import '../settings_screen.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _titleController = TextEditingController();
  final _directionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _videoLinkController = TextEditingController();
  File? _selectedImage;
  String _newRecipeImage = '';

  // Form validation state
  bool _showTitleError = false;
  bool _showDirectionsError = false;
  bool _showImageError = false;
  bool _showIndgredientsError = false;

  //bottomNavigationVariables
  int _mealType = 0;
  bool _isFavorite = false;
  bool _isCollection = true;
  int _selectedDuration = 10;

  late RecipeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = locator.get<RecipeViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              icon: Icon(Icons.settings))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Recipe Title
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
                maxLines: 1,
              ),

              const SizedBox(height: 16),

              // Recipe Direction
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

              // Image Selection Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.add_circle_outline, size: 48),
                              if (_showImageError)
                                const Text(
                                  'Image required',
                                  style: TextStyle(color: Colors.red),
                                ),
                            ])),
                ),
              ),

              const SizedBox(height: 24),

              // Next Button
              ElevatedButton(
                onPressed: () => _validateAndProceed(context),
                child: const Text('Next'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _directionController.dispose();
    _ingredientsController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  //BottomSheet to select Recipe Type, Duration, Favorite, Collection
  //and save recipe
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        //Using Stateful builder to manage Ui state in BottomSheet
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Recipe Ingredients
                      Expanded(
                        child: TextField(
                          controller: _ingredientsController,
                          decoration: InputDecoration(
                            labelText: 'Ingrdients List',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            errorText: _showIndgredientsError ? 'Ingredients is required' : null,
                          ),
                          maxLines: 5,
                        ),
                      ),
                      SizedBox(width: 4),
                      // Duration
                      Column(
                        children: [
                          Text('Duration', style: Theme.of(context).textTheme.bodySmall),
                          NumberPicker(
                            minValue: 5,
                            maxValue: 200,
                            value: _selectedDuration,
                            onChanged: (value) {
                              setState(() => _selectedDuration = value);
                              setStateBottomSheet(() {}); // Redraw bottomSheet
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Recipe Type Button Group
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRadioOption(0, 'breakfast', setStateBottomSheet),
                      _buildRadioOption(1, 'lunch', setStateBottomSheet),
                      _buildRadioOption(2, 'dinner', setStateBottomSheet),
                      _buildRadioOption(3, 'snack', setStateBottomSheet),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Row(
                      children: [
                        // Collection Switch
                        Text('Collection: '),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isCollection,
                            onChanged: (bool value) {
                              setState(() {
                                _isCollection = value;
                                if (!_isCollection) _isFavorite = false;
                              });
                              setStateBottomSheet(
                                  () {}); // Triggering the inner setState for BottomSheet
                            },
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        // Favorite Switch
                        Text('Favorite: '),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _isFavorite,
                            onChanged: (bool value) {
                              setState(() => _isFavorite = value);
                              if (_isFavorite) _isCollection = true;
                              setStateBottomSheet(
                                  () {}); // Triggering the inner setState for BottomSheet
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  // Video Link
                  TextField(
                    controller: _videoLinkController,
                    decoration: InputDecoration(
                      labelText: 'Video Link (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 8),

                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 6, backgroundColor: Theme.of(context).colorScheme.secondary),
                    onPressed: () async {
                      setState(() {
                        _showIndgredientsError = _ingredientsController.text.trim().isEmpty;
                      });
                      setStateBottomSheet(() {});

                      //extra Validation
                      if (_showTitleError ||
                          _showDirectionsError ||
                          _showImageError ||
                          _showIndgredientsError ||
                          _selectedImage == null) {
                        MyUtils.showSnackBar(context, 'Please fill all required fields.');
                        return;
                      }

                      _newRecipeImage = await _storeRecipeImage();
                      if (_newRecipeImage.startsWith('error')) {
                        MyUtils.showSnackBar(context, _newRecipeImage);
                        return;
                      }
                      await _saveRecipe();

                      if (!mounted) return;
                      if (_viewModel.error != null) {
                        MyUtils.showSnackBar(context, _viewModel.error!);
                      } else {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                        MyUtils.showSnackBar(context, 'Recipe saved successfully');
                        _clearFields();
                      }
                      setStateBottomSheet(() {});
                    },
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),

                  SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Radio Button Widget to selected Recipe.MealType
  Widget _buildRadioOption(int value, String label, Function setStateBottomSheet) {
    bool isSelected = _mealType == value;

    return GestureDetector(
      onTap: () {
        setState(() => _mealType = value);
        setStateBottomSheet(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2.0),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          style:
              TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  //Validation Methods and 'backEnd' operational Functions
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showImageError = false;
      });
    }
  }

  void _validateAndProceed(BuildContext context) {
    // Reset error states
    setState(() {
      _showTitleError = false;
      _showDirectionsError = false;
      _showImageError = false;
    });

    if (_titleController.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
    }

    if (_directionController.text.trim().isEmpty) {
      setState(() => _showDirectionsError = true);
    }

    if (_selectedImage == null) {
      setState(() => _showImageError = true);
    }

    // If all validations pass, proceed to next step
    if (!_showTitleError && !_showDirectionsError && !_showImageError) {
      _showBottomSheet(context);
    }
  }

  Future<void> _saveRecipe() async {
    //save recipe
    Recipe recipe = Recipe(
      name: _titleController.text.trim(),
      mins: _selectedDuration,
      numIngredients: _ingredientsController.text.trim().split('\n').length,
      direction: _directionController.text.trim(),
      ingredients: _ingredientsController.text.trim(),
      imageUrl: _newRecipeImage,
      collection: _isCollection,
      favorite: _isFavorite,
      userCreated: true,
      mealType: _mealType,
      videoLink: _videoLinkController.text.trim(),
    );
    await _viewModel.createRecipe(recipe);
  }

  //Take Image selected and save it to AppDocumentsDirectory
  Future<String> _storeRecipeImage() async {
    Map<String, dynamic> result = await MyUtils.storeFileInAppDocumentsDirectory(_selectedImage!);
    if (!result['success']) {
      return 'Error: ${result['errorMessage']}';
    } else {
      return result['filePath'];
    }
  }

  void _clearFields() {
    _titleController.clear();
    _directionController.clear();
    _ingredientsController.clear();
    _videoLinkController.clear();
    _selectedImage = null;
    _newRecipeImage = '';

    _showTitleError = false;
    _showDirectionsError = false;
    _showImageError = false;
    _showIndgredientsError = false;

    _mealType = 0;
    _isFavorite = false;
    _isCollection = true;
    _selectedDuration = 10;
    setState(() {});
  }
}
