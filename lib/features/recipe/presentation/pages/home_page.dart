import 'package:ai_recipe_app/core/widgets/app_capsule_button.dart';
import 'package:ai_recipe_app/core/widgets/app_text_form_field.dart';
import 'package:ai_recipe_app/features/recipe/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_event.dart';
import '../bloc/recipe/recipe_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController ingredientsController;
  late final TextEditingController notesController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    ingredientsController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    ingredientsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    context.read<RecipeBloc>().add(ExtractIngredientsFromImageEvent(bytes));
  }

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
              if (state.extractedIngredients.isNotEmpty &&
                  ingredientsController.text != state.extractedIngredients) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ingredientsController.text = state.extractedIngredients;
                });
              }

              return SingleChildScrollView(
                child: Column(
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
                                color: Colors.grey,
                              ),
                        onPressed: _pickImage,
                      ),
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
                    const SizedBox(height: 12),
                    AppCapsuleButton(
                      label: state.isGenerating
                          ? 'Generating...'
                          : 'Generate Recipe',
                      icon: Icons.auto_awesome_outlined,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: state.isGenerating
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
                      Column(
                        children: [
                          if (state.imageBytes != null)
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: state.isGenerating? CustomLoadingIndicator() : Image.memory(state.imageBytes!),
                              ),
                            ),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: state.isGeneratingImage
                                  ? const Center(child: CustomLoadingIndicator())
                                  : MarkdownBody(
                                      data: state.recipeText,
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
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
