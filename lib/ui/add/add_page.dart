import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  File? _selectedImage;

  // Form validation state
  bool _showTitleError = false;
  bool _showDirectionsError = false;
  bool _showImageError = false;
  bool _showIndgredientsErro = false;

  //bottomNavigationVariables
  int _selectedRadio = 0;
  bool _isFavorite = false;
  bool _isCollection = false;
  int _selectedDuration = 10;

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

    // Validate title
    if (_titleController.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
    }

    // Validate directions
    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _showDirectionsError = true);
    }

    // Validate image
    if (_selectedImage == null) {
      setState(() => _showImageError = true);
    }

    // If all validations pass, proceed to next step
    if (!_showTitleError && !_showDirectionsError && !_showImageError) {
      _showBottomSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
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

              // Recipe Description
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Directions',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  errorText:
                      _showDirectionsError ? 'Directions are required' : null,
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
                        border: _showImageError
                            ? Border.all(color: Colors.red, width: 2)
                            : null,
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  const Icon(Icons.add_circle_outline,
                                      size: 48),
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
    _descriptionController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  //BottomSheet to select Recipe Type, Duration, Favorite, Collection
  //and save recipe
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        //Using Stateful builder to manage Ui state in BottomSheet
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Recipe Ingredients
                        Expanded(
                          child: TextField(
                            controller: _ingredientsController,
                            decoration: InputDecoration(
                              labelText: 'Ingrdients List',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            maxLines: 5,
                          ),
                        ),
                        SizedBox(width: 4),
                        // Duration
                        Column(
                          children: [
                            Text('Duration',
                                style: Theme.of(context).textTheme.bodySmall),
                            NumberPicker(
                              minValue: 5,
                              maxValue: 200,
                              value: _selectedDuration,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDuration = value;
                                });
                                setStateBottomSheet(
                                    () {}); // Redraw bottomSheet
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

                    // Save Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 6),
                      onPressed: () {
                        //TODO: Save Recipe
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// Radio Button Widget to selected Recipe.MealType
  Widget _buildRadioOption(
      int value, String label, Function setStateBottomSheet) {
    bool isSelected = _selectedRadio == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedRadio = value);
        setStateBottomSheet(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 2.0),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Text(label),
      ),
    );
  }
}
