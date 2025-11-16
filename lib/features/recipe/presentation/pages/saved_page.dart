import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Pages')),
      body: const Center(child: Text('This is the saved page.')),
    );
  }
}
