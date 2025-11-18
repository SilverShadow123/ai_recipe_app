import 'dart:typed_data';
import 'package:flutter/material.dart';

enum FeedbackType { bug, feature, suggestion, other }
enum FeedbackPriority { low, medium, high, critical }

typedef OnSubmitCallback = Future<void> Function({
  required String description,
  required FeedbackType type,
  required FeedbackPriority priority,
  required List<String> tags,
  Uint8List? screenshot,
});

class FeedbackDialog extends StatefulWidget {
  final Uint8List? screenshot;
  final OnSubmitCallback? onSubmit;

  const FeedbackDialog({
    super.key,
    this.screenshot,
    this.onSubmit,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  FeedbackType _selectedType = FeedbackType.suggestion;
  FeedbackPriority _selectedPriority = FeedbackPriority.medium;
  Uint8List? _screenshot;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _screenshot = widget.screenshot;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      
      try {
        final tags = _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        
        await widget.onSubmit!(
          description: _descriptionController.text.trim(),
          type: _selectedType,
          priority: _selectedPriority,
          tags: tags,
          screenshot: _screenshot,
        );
        
        if (mounted) {
          Navigator.pop(context);
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Feedback'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Feedback Type
              const Text('Feedback Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FeedbackType.values.map((type) {
                  final label = type.toString().split('.').last;
                  return ChoiceChip(
                    label: Text(label[0].toUpperCase() + label.substring(1)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedType = type);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Priority
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FeedbackPriority.values.map((priority) {
                  final label = priority.toString().split('.').last;
                  return ChoiceChip(
                    label: Text(label[0].toUpperCase() + label.substring(1)),
                    selected: _selectedPriority == priority,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPriority = priority);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., ui, performance, bug',
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Please describe your feedback in detail...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Screenshot Preview
              if (_screenshot != null && _screenshot!.isNotEmpty) ...[
                const Text('Screenshot', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _screenshot!,
                        fit: BoxFit.contain,
                        height: 150,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _screenshot = null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              
              // Screenshot Upload Button
              ElevatedButton.icon(
                onPressed: () async {
                  // Screenshot functionality can be implemented here
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(_screenshot == null ? 'Add Screenshot' : 'Change Screenshot'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || widget.onSubmit == null ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SUBMIT FEEDBACK'),
        ),
      ]
    );
  }
}