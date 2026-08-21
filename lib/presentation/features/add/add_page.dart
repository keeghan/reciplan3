import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:reciplan3/logic/app/settings/app_settings_cubit.dart';
import 'package:reciplan3/logic/core/models/meal.dart';
import 'package:reciplan3/logic/core/models/recipe_draft.dart';
import 'package:reciplan3/logic/data/repositories/recipe_repository.dart';
import 'package:reciplan3/logic/data/services/local_image_storage_service.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_cubit.dart';
import 'package:reciplan3/logic/recipes/recipe_editor_state.dart';
import 'package:reciplan3/presentation/features/settings/settings_screen.dart';
import 'package:reciplan3/presentation/theme/app_theme.dart';
import 'package:reciplan3/presentation/widgets/app_components.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _directionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _videoLinkController = TextEditingController();
  File? _selectedImage;
  bool _showImageError = false;
  bool _showSaved = false;
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
          if (context.read<AppSettingsCubit>().state.hapticsEnabled) {
            HapticFeedback.mediumImpact();
          }
          _clearFields();
          setState(() => _showSaved = true);
          MyUtils.showSnackBar(context, 'Recipe saved successfully');
          context.read<RecipeEditorCubit>().clearFeedback();
          Timer(const Duration(milliseconds: 700), () {
            if (mounted) {
              setState(() => _showSaved = false);
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add recipe'),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () => Navigator.push(
                context,
                AppRoute.build(context, const SettingsScreen()),
              ),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) => _buildFormContent(context, constraints.maxWidth),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.fromLTRB(
            AppBreakpoints.gutter(context),
            8,
            AppBreakpoints.gutter(context),
            12,
          ),
          child: _buildSaveBar(context),
        ),
      ),
    );
  }

  // Builds the form for the current window width.
  Widget _buildFormContent(BuildContext context, double availableWidth) {
    if (availableWidth < AppBreakpoints.expanded) {
      return ListView(
        key: const PageStorageKey('phone-add-form'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          ..._introWidgets(),
          ..._basicWidgets(context),
          ..._recipeWidgets(includeVideo: false),
          ..._saveAndShareWidgets(includeLeadingSpace: true),
          const SizedBox(height: 16),
          _videoField(),
        ],
      );
    }

    return ListView(
      key: const PageStorageKey('tablet-add-form'),
      padding: EdgeInsets.fromLTRB(
        AppBreakpoints.gutter(context),
        8,
        AppBreakpoints.gutter(context),
        120,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.standardContent,
            ),
            child: Column(
              children: [
                const AppSectionHeader(
                  title: 'Create something delicious',
                  subtitle: 'Keep the details simple—you can always refine them later.',
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _ImagePicker(
                            image: _selectedImage,
                            showError: _showImageError,
                            onTap: _pickImage,
                          ),
                          const SizedBox(height: 28),
                          ..._saveAndShareWidgets(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          ..._basicWidgets(
                            context,
                            includeLeadingSpace: false,
                          ),
                          ..._recipeWidgets(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Builds the phone-only introduction and image picker.
  List<Widget> _introWidgets() {
    return [
      const AppSectionHeader(
        title: 'Create something delicious',
        subtitle: 'Keep the details simple—you can always refine them later.',
      ),
      const SizedBox(height: 20),
      _ImagePicker(
        image: _selectedImage,
        showError: _showImageError,
        onTap: _pickImage,
      ),
    ];
  }

  // Shares basic recipe fields between phone and tablet forms.
  List<Widget> _basicWidgets(
    BuildContext context, {
    bool includeLeadingSpace = true,
  }) {
    return [
      SizedBox(height: includeLeadingSpace ? 28 : 0),
      const _FormHeading('Basics'),
      const SizedBox(height: 12),
      TextFormField(
        controller: _titleController,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(
          labelText: 'Recipe title',
          prefixIcon: Icon(Icons.restaurant_menu),
        ),
        validator: _required('Title is required'),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Meal type',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in MealType.values.where(
              (type) => type != MealType.missing,
            ))
              ChoiceChip(
                label: Text(type.label),
                selected: _mealType == type,
                onSelected: (_) => setState(() => _mealType = type),
              ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          const Icon(Icons.schedule),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cooking time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text('$_selectedDuration min'),
        ],
      ),
      Slider(
        min: 5,
        max: 200,
        divisions: 39,
        label: '$_selectedDuration minutes',
        value: _selectedDuration.toDouble(),
        onChanged: (value) => setState(
          () => _selectedDuration = (value / 5).round() * 5,
        ),
      ),
    ];
  }

  // Shares recipe text fields between phone and tablet forms.
  List<Widget> _recipeWidgets({bool includeVideo = true}) {
    return [
      const SizedBox(height: 20),
      const Align(
        alignment: Alignment.centerLeft,
        child: _FormHeading('Recipe'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _ingredientsController,
        textCapitalization: TextCapitalization.sentences,
        minLines: 5,
        maxLines: 8,
        decoration: const InputDecoration(
          labelText: 'Ingredients',
          alignLabelWithHint: true,
          hintText: 'Add one ingredient per line',
        ),
        validator: _required('Ingredients are required'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _directionController,
        textCapitalization: TextCapitalization.sentences,
        minLines: 6,
        maxLines: 12,
        decoration: const InputDecoration(
          labelText: 'Directions',
          alignLabelWithHint: true,
          hintText: 'Describe how to prepare the recipe',
        ),
        validator: _required('Directions are required'),
      ),
      if (includeVideo) ...[
        const SizedBox(height: 16),
        _videoField(),
      ],
    ];
  }

  // Builds the optional video field once per layout.
  Widget _videoField() {
    return TextFormField(
      controller: _videoLinkController,
      keyboardType: TextInputType.url,
      decoration: const InputDecoration(
        labelText: 'Video link (optional)',
        prefixIcon: Icon(Icons.play_circle_outline),
      ),
    );
  }

  // Shares collection controls between phone and tablet forms.
  List<Widget> _saveAndShareWidgets({bool includeLeadingSpace = false}) {
    return [
      if (includeLeadingSpace) const SizedBox(height: 28),
      const Align(
        alignment: Alignment.centerLeft,
        child: _FormHeading('Save and share'),
      ),
      const SizedBox(height: 12),
      Card(
        child: Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.bookmark_outline),
              title: const Text('Add to collection'),
              subtitle: const Text('Make it available in your meal plan'),
              value: _isCollection,
              onChanged: (value) => setState(() {
                _isCollection = value;
                if (!value) _isFavorite = false;
              }),
            ),
            const Divider(height: 1, indent: 56),
            SwitchListTile(
              secondary: const Icon(Icons.favorite_border),
              title: const Text('Mark as favorite'),
              value: _isFavorite,
              onChanged: (value) => setState(() {
                _isFavorite = value;
                if (value) _isCollection = true;
              }),
            ),
          ],
        ),
      ),
    ];
  }

  // Keeps Save full-width on phones and trailing-aligned on tablets.
  Widget _buildSaveBar(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
    final button = SizedBox(
      width: isTablet ? 360 : double.infinity,
      child: BlocBuilder<RecipeEditorCubit, RecipeEditorState>(
        buildWhen: (previous, current) => previous.isSaving != current.isSaving,
        builder: (context, state) {
          return FilledButton.icon(
            onPressed: state.isSaving ? null : () => _submit(context),
            icon: AnimatedSwitcher(
              duration: AppMotion.duration(context, AppMotion.state),
              child: _showSaved
                  ? const Icon(Icons.check, key: ValueKey('saved'))
                  : state.isSaving
                      ? const SizedBox.square(
                          key: ValueKey('saving'),
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.save_outlined,
                          key: ValueKey('save'),
                        ),
            ),
            label: Text(
              _showSaved
                  ? 'Saved'
                  : state.isSaving
                      ? 'Saving…'
                      : 'Save recipe',
            ),
          );
        },
      ),
    );
    if (!isTablet) return button;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.standardContent,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Align(alignment: Alignment.centerRight, child: button),
          ),
        ),
      ),
    );
  }

  // Validates non-empty text.
  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  // Picks a recipe image.
  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showImageError = false;
      });
    }
  }

  // Validates and saves the recipe.
  void _submit(BuildContext context) {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showImageError = _selectedImage == null);
    if (!formIsValid || _selectedImage == null) {
      MyUtils.showSnackBar(context, 'Please complete the required fields');
      return;
    }
    final ingredients = _ingredientsController.text
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();
    context.read<RecipeEditorCubit>().saveRecipe(
          RecipeDraft(
            name: _titleController.text.trim(),
            mins: _selectedDuration,
            numIngredients: ingredients.length,
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

  // Clears the completed form.
  void _clearFields() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _directionController.clear();
    _ingredientsController.clear();
    _videoLinkController.clear();
    setState(() {
      _selectedImage = null;
      _showImageError = false;
      _mealType = MealType.breakfast;
      _isFavorite = false;
      _isCollection = true;
      _selectedDuration = 10;
    });
  }
}

class _FormHeading extends StatelessWidget {
  final String title;

  const _FormHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _ImagePicker extends StatelessWidget {
  final File? image;
  final bool showError;
  final VoidCallback onTap;

  const _ImagePicker({
    required this.image,
    required this.showError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Card(
            child: InkWell(
              onTap: onTap,
              child: AnimatedSwitcher(
                duration: AppMotion.duration(context, AppMotion.state),
                child: image == null
                    ? Container(
                        key: const ValueKey('empty-image'),
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          border: showError ? Border.all(color: scheme.error, width: 2) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 44,
                              color: scheme.onPrimaryContainer,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a recipe photo',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        key: ValueKey(image!.path),
                        fit: StackFit.expand,
                        children: [
                          Image.file(image!, fit: BoxFit.cover),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: IconButton.filledTonal(
                              tooltip: 'Change image',
                              onPressed: onTap,
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.duration(context, AppMotion.state),
          child: showError
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'A recipe image is required',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
