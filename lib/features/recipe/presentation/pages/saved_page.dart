import 'package:flutter/material.dart';

import '../widgets/saved_recipes_body.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Recipes')),
      body: const SavedRecipesBody(),
    );
  }
}
