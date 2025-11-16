import 'package:ai_recipe_app/core/widgets/app_capsule_button.dart';
import 'package:ai_recipe_app/core/widgets/app_text_form_field.dart';
import 'package:ai_recipe_app/features/recipe/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_event.dart';
import '../bloc/recipe/recipe_state.dart';

class IngredientsInputSection extends StatelessWidget {
  final TextEditingController ingredientsController;
  final TextEditingController notesController;
  final RecipeState state;
  final VoidCallback onPickImage;
  final ThemeData theme;

  const IngredientsInputSection({
    super.key,
    required this.ingredientsController,
    required this.notesController,
    required this.state,
    required this.onPickImage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFormField(
          controller: ingredientsController,
          maxLines: 3,
          suffix: IconButton(
            icon: state.isExtracting
                ? CustomLoadingIndicator()
                : Icon(
              Icons.camera_enhance_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: state.isExtracting ? null : onPickImage,
            tooltip: 'Scan ingredients',
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.grey.withAlpha(40),
              width: 1.2,
            ),
          ),
          label: 'Ingredients',
          hintText: 'e.g., eggs, flour, milk',
        ),
        const SizedBox(height: 16),
        AppTextFormField(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.grey.withAlpha(40),
              width: 1.2,
            ),
          ),
          controller: notesController,
          label: 'Preferences (Optional)',
          hintText: 'e.g., Italian cuisine, no nuts',
        ),
        const SizedBox(height: 20),
        AppCapsuleButton(
          label: state.isGenerating
              ? 'Creating Your Recipe...'
              : 'Generate Recipe',
          icon: state.isGenerating
              ? Icons.hourglass_empty
              : Icons.auto_awesome_outlined,
          borderRadius: BorderRadius.circular(32),
          onPressed: state.isGenerating
              ? null
              : () {
            if (ingredientsController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter some ingredients'),
                ),
              );
              return;
            }
            context.read<RecipeBloc>().add(
              GenerateRecipeEvent(
                ingredientsController.text.trim(),
                notesController.text.trim(),
              ),
            );
          },
        ),
      ],
    );
  }
}