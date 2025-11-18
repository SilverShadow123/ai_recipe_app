import 'dart:typed_data';
import 'package:ai_recipe_app/core/ai/ap_agent.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/message_input.dart';
import '../widgets/message_list.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? image;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.image,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  Uint8List? _currentScreenshot;
  final AppAgent _appAgent = AppAgent();
  final List<ChatMessage> _messages = [
    ChatMessage(
      message:
          "Hello! I'm your AI assistant. How can I help you with your app settings today?",
      isUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _appAgent.initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleScreenshot() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      
      final bytes = await image.readAsBytes();
      setState(() {
        _currentScreenshot = bytes;
        _messages.add(ChatMessage(
          message: '[Screenshot attached]',
          isUser: true,
        ));
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to attach image')),
        );
      }
    }
  }
  
  Future<void> _processMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty && _currentScreenshot == null) return;

    setState(() {
      _messages.add(ChatMessage(
        message: message,
        isUser: true,
      ));
      _isLoading = true;
    });
    
    final screenshot = _currentScreenshot;
    _messageController.clear();
    _currentScreenshot = null;
    
    _scrollToBottom();

    try {
      await _appAgent.submitFeedback(
        context,
        screenshot ?? Uint8List(0),
        message.isNotEmpty ? message : 'Screenshot feedback',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            message: 'Sorry, I encountered an error: ${e.toString()}',
            isUser: false,
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Settings Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: _messages,
              scrollController: _scrollController,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          MessageInput(
            controller: _messageController,
            isLoading: _isLoading,
            onSend: () => _processMessage(),
            onScreenshot: _handleScreenshot,
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }



  // No longer needed - using AI agent's built-in feedback handling
}
