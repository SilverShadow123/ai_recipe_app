import 'package:ai_recipe_app/core/widgets/app_capsule_button.dart';
import 'package:ai_recipe_app/core/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_event.dart';
import '../bloc/recipe/recipe_state.dart';
import '../bloc/auth/auth_bloc.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ingredientsController = TextEditingController();

  final notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friendly Meals"),
        actions: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                context.goNamed('login');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
              onPressed: () {
                context.read<AuthBloc>().add(SignOutEvent());
              },
            ),
          ),
        ],
      ),
      body: BlocListener<RecipeBloc, RecipeState>(
        listenWhen: (prev, curr) => curr.error.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextFormField(
                      controller: ingredientsController,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      label: 'Ingredients',
                      hintText: 'eg: egg, flour, milk',
                    ),
                    const SizedBox(height: 16),
                    AppTextFormField(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      controller: notesController,
                      label: 'Notes',
                      hintText: 'eg: Italian cuisine, no peanuts',
                    ),
                    const SizedBox(height: 20),
                    AppCapsuleButton(
                      label: state.isLoading
                          ? 'Generating...'
                          : 'Generate Recipe',
                      icon: Icons.auto_awesome_outlined,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: state.isLoading
                          ? null
                          : () {
                              context.read<RecipeBloc>().add(
                                GenerateRecipeEvent(
                                  ingredientsController.text.trim(),
                                  notesController.text.trim(),
                                ),
                              );
                            },
                    ),
                    const SizedBox(height: 20),
                    if (state.recipeText.isNotEmpty)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: MarkdownBody(
                            data: state.recipeText,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16, height: 1.5,
                              fontWeight: FontWeight.w500,
                              ),

                            ),

                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
