import 'package:ai_recipe_app/features/recipe/presentation/bloc/recipe/recipe_bloc.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/recipe/recipe_event.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/recipe/recipe_state.dart';
import 'package:ai_recipe_app/features/recipe/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RecipeResultSection extends StatelessWidget {
  final RecipeState state;
  final ThemeData theme;

  const RecipeResultSection({
    super.key,
    required this.state,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Your Recipe",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Recipe Image ---
        if (state.imageBytes != null)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: state.isGeneratingImage
                  ? Container(
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomLoadingIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Generating image...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : Image.memory(
                state.imageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // --- Recipe Text ---
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: MarkdownBody(
              data: state.recipeText,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
                h3: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
                p: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                listBullet: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // --- Save Recipe Button ---
        BlocConsumer<RecipeBloc, RecipeState>(
          listener: (context, state) {
            if (state.saveSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recipe saved successfully!')));
            }
            if (state.error.isNotEmpty) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error)));
            }
          },
          builder: (context, blocState) {
            return ElevatedButton.icon(
              onPressed: (blocState.recipeText.isEmpty || blocState.isSaving)
                  ? null
                  : () {
                // Fire the SaveRecipeEvent
                context.read<RecipeBloc>().add(
                  SaveRecipeEvent(
                      blocState.extractedIngredients), // pass ingredients
                );
              },
              icon: blocState.isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.bookmark),
              label: Text(
                blocState.isSaving ? 'Saving...' : 'Save Recipe',
              ),
            );
          },
        ),
      ],
    );
  }
}
