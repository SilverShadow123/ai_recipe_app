import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_event.dart';
import '../bloc/recipe/recipe_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_page_header.dart';
import '../widgets/ingredients_input_section.dart';
import '../widgets/recipe_result_section.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: const Text(
          "Friendly Meals",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated)
                context.goNamed('login');
              else if (state is AuthError)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
            },
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black87),
              tooltip: 'Log out',
              onPressed: () => context.read<AuthBloc>().add(SignOutEvent()),
            ),
          ),
        ],
      ),
      body: BlocListener<RecipeBloc, RecipeState>(
        listenWhen: (prev, curr) => curr.error.isNotEmpty,
        listener: (context, state) =>
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            ),
        child: BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, state) {
            if (state.extractedIngredients.isNotEmpty &&
                ingredientsController.text != state.extractedIngredients) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => ingredientsController.text = state.extractedIngredients,
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomePageHeader(theme: theme),
                    const SizedBox(height: 24),
                    IngredientsInputSection(
                      ingredientsController: ingredientsController,
                      notesController: notesController,
                      state: state,
                      onPickImage: _pickImage,
                      theme: theme,
                    ),
                    if (state.recipeText.isNotEmpty)
                      RecipeResultSection(state: state, theme: theme),
                    if (state.recipeText.isEmpty && !state.isGenerating)
                      EmptyStateSection(theme: theme),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
