import 'package:ai_recipe_app/features/recipe/presentation/widgets/recipe_result_section.dart';
import 'package:flutter/material.dart';

import '../bloc/recipe/recipe_state.dart';
import 'empty_state.dart';
import 'home_page_header.dart';
import 'ingredients_input_section.dart';

class HomePageContent extends StatefulWidget {
  final RecipeState state;
  final ThemeData theme;
  final VoidCallback onPickImage;

  const HomePageContent({
    required this.state,
    required this.theme,
    required this.onPickImage,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late final TextEditingController ingredientsController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    ingredientsController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void didUpdateWidget(HomePageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.extractedIngredients.isNotEmpty &&
        ingredientsController.text != widget.state.extractedIngredients) {
      ingredientsController.text = widget.state.extractedIngredients;
    }
  }

  @override
  void dispose() {
    ingredientsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomePageHeader(theme: widget.theme),
            const SizedBox(height: 24),
            IngredientsInputSection(
              ingredientsController: ingredientsController,
              notesController: notesController,
              state: widget.state,
              onPickImage: widget.onPickImage,
              theme: widget.theme,
            ),
            if (widget.state.recipeText.isNotEmpty)
              RecipeResultSection(state: widget.state, theme: widget.theme),
            if (widget.state.recipeText.isEmpty && !widget.state.isGenerating)
              EmptyStateSection(theme: widget.theme),
          ],
        ),
      ),
    );
  }
}