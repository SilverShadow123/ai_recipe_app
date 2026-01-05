import 'dart:typed_data';

import 'package:ai_recipe_app/core/ai/tools.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/theme_settings/theme_settings_cubit.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/utils.dart';

class AppAgent{
  final gemini = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite',
  systemInstruction: Content.text(
   """
   You are a friendly and helpful app concierge. Your job is to help the user
   get the best, frictionless app experience.
   If you have access to a tool that can configure the setting for
   the user and address their feedback, ALWAYS ask the user to confirm the
   change before making the change.
   Before filing a feedback report, first gather all of the following information:
   - Device Information
   - When the user has feedback regarding performance, also include battery information.
   to include in the feedback report.
   """
  ),
    toolConfig: ToolConfig(
      functionCallingConfig: FunctionCallingConfig.any({
        'askConfirmation',
        'setFontFamily',
        'setFontSizeFactor',
        'setAppColor',
        'getDeviceInfo',
        'getBatteryInfo',
        'fileFeedback',
      }),
    ),
    tools: [Tool.functionDeclarations([
      askConfirmationTool,
      fontFamilyTool,
      fontSizeFactorTool,
      appThemeColorTool,
      deviceInfoTool,
      batteryInfoTool,
      fileFeedbackTool,
    ])]
  );

  late ChatSession chat;
  late Uint8List screenshot;
  late String feedbackText;

  void initialize(){
    chat = gemini.startChat();
  }
  Future<bool> askConfirmation(BuildContext context, String question) async {
    var response = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Theme(
          data: context.read<ThemeSettingsCubit>().state.appTheme,
          child: AlertDialog(
            title: Text('App Manager'),
            content: Text(question),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Yes, please'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No.'),
              ),
            ],
          ),
        );
      },
    );

    return response ?? false;
  }

  Future<GenerateContentResponse?> askConfirmationCall(
      BuildContext context,
      FunctionCall functionCall,
      ) async {
    final question = functionCall.args['question'] as String?;
    if (question == null) return null;

    if (context.mounted) {
      final functionResult = await askConfirmation(context, question);

      final response = await chat.sendMessage(
        functionResult
            ? Content.text('Yes, please do that.')
            : Content.text('No, thank you.'),
      );

      return response;
    }
    return null;
  }

  Future<void> setFontFamilyCall(
      BuildContext context,
      FunctionCall functionCall,
      ) async {
    final fontFamily = functionCall.args['fontFamily'] as String?;
    if (fontFamily == null || !context.mounted) return;
    
    // Get the current theme state
    final themeCubit = context.read<ThemeSettingsCubit>();
    
    // Update the font family
    themeCubit.setFontFamily(fontFamily);
    
    // Let the user know the font was updated
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Font family updated to $fontFamily')),
      );
    }
    
    // Send a confirmation message to the chat
    await chat.sendMessage(
      Content.text('I\'ve updated the font family to $fontFamily.'),
    );
  }

  Future<void> checkFunctionCalls(
      BuildContext context,
      Iterable<FunctionCall> functionCalls,
      ) async {
    for (var functionCall in functionCalls) {
      debugPrint(functionCalls.map((fc) => fc.name).toString());
      GenerateContentResponse? response;
      switch (functionCall.name) {
        case 'askConfirmation':
          response = await askConfirmationCall(context, functionCall);
          break;
        case 'setFontFamily':
          await setFontFamilyCall(context, functionCall);
          break;
        case 'setFontSizeFactor':
          setFontSizeFactorCall(context, functionCall);
          await chat.sendMessage(
            Content.text('I\'ve updated the font size.'),
          );
          break;
        case 'setAppColor':
          setAppColorCall(context, functionCall);
          await chat.sendMessage(
            Content.text('I\'ve updated the app theme color.'),
          );
          break;
        case 'getDeviceInfo':
          var deviceInfo = await getDeviceInfoCall();
          response = await chat.sendMessage(
            Content.text('Device Info: $deviceInfo'),
          );
          break;
        case 'getBatteryInfo':
          var batteryInfo = await getBatteryInfoCall();
          response = await chat.sendMessage(
            Content.text('Battery Info: $batteryInfo'),
          );
          break;
        case 'fileFeedback':
          var feedbackReport = await fileFeedbackReport(context, functionCall);
          await chat.sendMessage(
            Content.text(
              'Feedback Report successfully filed: $feedbackReport.',
            ),
          );
          return;
        default:
          throw UnimplementedError(
            'Function not declared to the model: ${functionCall.name}',
          );
      }
      if (response != null &&
          response.functionCalls.isNotEmpty &&
          context.mounted) {
        await checkFunctionCalls(context, response.functionCalls);
      }
    }
    return;
  }

  Future<String> fileFeedbackReport(
      BuildContext context,
      FunctionCall functionCall,
      ) async {
    String summary = functionCall.args['summary'] as String;
    String deviceInfo = functionCall.args['deviceInfo'] as String;
    String batteryInfo = functionCall.args['batteryInfo'] as String? ?? '';
    String actionHistory = functionCall.args['actionHistory'] as String;
    List<dynamic> tagsList = functionCall.args['tags'] as List<dynamic>;
    List<String> tags = tagsList.map((tag) => tag as String).toList();
    int priority = functionCall.args['priority'] as int;

    String feedbackReport = '''
    Summary: $summary\n
    Device Info: $deviceInfo\n
    Battery Info: $batteryInfo\n
    Action History: $actionHistory\n
    Tags: $tags\n
    Priority: $priority\n
    Feedback: $feedbackText\n
    ''';

    ThemeSettingsCubit manager = context.read<ThemeSettingsCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return Theme(
          data: manager.state.appTheme,
          child: AlertDialog(
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
            title: Text('Feedback Report'),
            content: Column(
              children: [
                Text('Summary:$summary'),
                Text('Device Info: $deviceInfo'),
                Text('Battery Info: $batteryInfo'),
                Text('Action History: $actionHistory'),
                Text('Tags: ${tags.join(' ')}'),
                Text('Priority: $priority'),
                Text('Feedback: $feedbackText'),
                Image.memory(screenshot),
              ],
            ),
            scrollable: true,
          ),
        );
      },
    );

    return feedbackReport;
  }

  Future<String?> submitFeedback(
    BuildContext context,
    Uint8List userScreenshot,
    String userFeedbackText,
  ) async {
    try {
      // Store the screenshot and feedback text for later use
      screenshot = userScreenshot;
      feedbackText = userFeedbackText;

      final prompt = Content.multi([
        TextPart(
          '''Please analyze this user feedback and either:
          1. Help the user directly if it's something that can be addressed in-app
          2. File a feedback report if it requires developer attention
          
          For app settings changes, use the appropriate tools to help the user.
          For bug reports or feature requests, use the fileFeedback tool.
          ''',
        ),
        TextPart('User feedback: $userFeedbackText'),
        if (userScreenshot.isNotEmpty) InlineDataPart('image/jpeg', userScreenshot),
      ]);

      final response = await chat.sendMessage(prompt);
      final functionCalls = response.functionCalls.toList();

      // Process any function calls from the response
      if (context.mounted && functionCalls.isNotEmpty) {
        await checkFunctionCalls(context, functionCalls);
      }

      if (response.text?.trim().isNotEmpty ?? false) {
        return response.text!.trim();
      }

      if (functionCalls.isNotEmpty) {
        return 'Done.';
      }

      return null;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }
}