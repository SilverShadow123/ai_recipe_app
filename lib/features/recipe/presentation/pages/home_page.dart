import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/recipe/recipe_bloc.dart';
import '../bloc/recipe/recipe_event.dart';
import '../bloc/recipe/recipe_state.dart';
import '../widgets/home_page_content_state.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!context.mounted) return;
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
              if (state is AuthUnauthenticated) {
                context.goNamed('login');
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
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
            return HomePageContent(

              state: state,
              theme: theme,
              onPickImage: () => _pickImage(context),

            );
          },
        ),
      ),
    );
  }
}

