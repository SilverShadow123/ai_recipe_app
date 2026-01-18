import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_recipe_app/features/recipe/presentation/bloc/theme_settings/theme_settings_cubit.dart';
import 'package:ai_recipe_app/core/utils/device_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/constant.dart';

class AppAgent{
  static const String _openRouterModel = 'mistralai/mistral-small-3.1-24b-instruct:free';
  static const Duration _timeout = Duration(seconds: 45);
  static const int _maxToolRounds = 6;

  bool get _modelSupportsVision {
    final m = _openRouterModel.toLowerCase();
    return m.contains('gpt-4') ||
        m.contains('gpt-4o') ||
        m.contains('vision') ||
        m.contains('gemini');
  }

  Uri get _openRouterChatCompletionsUrl =>
      Uri.parse('$openRouterBaseUrl/chat/completions');

  Uri get _openRouterCompletionsUrl =>
      Uri.parse('$openRouterBaseUrl/completions');

  Map<String, String> get _openRouterHeaders => {
        'Authorization': 'Bearer $openRouterApiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  final List<Map<String, dynamic>> _history = [];

  bool get _preferCompletionsEndpoint {
    final m = _openRouterModel.toLowerCase();
    return m.contains('instruct');
  }

  late Uint8List screenshot;
  late String feedbackText;
  String? _lastUiMessage;

  String get _systemPrompt =>
      'You are a friendly and helpful app concierge. Your job is to help the user '
      'get the best, frictionless app experience.\n'
      'If you have access to a tool that can configure the setting for '
      'the user and address their feedback, ALWAYS ask the user to confirm the '
      'change before making the change.\n'
      'Before filing a feedback report, first gather all of the following information:\n'
      '- Device Information\n'
      '- When the user has feedback regarding performance, also include battery information.';

  String get _actionProtocolPrompt =>
      'When you want to change app settings or gather info, respond with ONLY a JSON object in this schema:\n'
      '{\n'
      '  "assistant_message": string,\n'
      '  "actions": [\n'
      '     {"type":"setFontFamily","fontFamily":"Inter|Raleway|Georgia|Caveat"},\n'
      '     {"type":"setFontSizeFactor","fontSizeFactor": number},\n'
      '     {"type":"setAppColor","red":int,"green":int,"blue":int},\n'
      '     {"type":"getDeviceInfo"},\n'
      '     {"type":"getBatteryInfo"},\n'
      '     {"type":"fileFeedback","summary":string,"batteryInfo":string,"deviceInfo":string,"actionHistory":string,"tags":[string],"priority":int}\n'
      '  ]\n'
      '}\n'
      'Rules: Do NOT wrap JSON in markdown or code fences. Do NOT include any other text.';

  List<Map<String, dynamic>> get _tools => [
        {
          'type': 'function',
          'function': {
            'name': 'askConfirmation',
            'description':
                'Ask the user a yes/no question before executing a change. Only ask a yes/no question.',
            'parameters': {
              'type': 'object',
              'properties': {
                'question': {
                  'type': 'string',
                  'description':
                      'The yes/no question to ask the user for confirmation.',
                },
              },
              'required': ['question'],
            },
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'setFontFamily',
            'description': 'Set the app theme\'s font family.',
            'parameters': {
              'type': 'object',
              'properties': {
                'fontFamily': {
                  'type': 'string',
                  'description':
                      'Font family name. Options: Inter, Raleway, Georgia, Caveat.',
                },
              },
              'required': ['fontFamily'],
            },
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'setFontSizeFactor',
            'description':
                'Set font size factor. Minimum 1.0, maximum 2.0, usually increments of 0.05.',
            'parameters': {
              'type': 'object',
              'properties': {
                'fontSizeFactor': {
                  'type': 'number',
                  'description': 'Desired font size factor (1.0 to 2.0).',
                },
              },
              'required': ['fontSizeFactor'],
            },
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'setAppColor',
            'description':
                'Set the app theme color by RGB channels (0 to 255).',
            'parameters': {
              'type': 'object',
              'properties': {
                'red': {
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 255,
                },
                'green': {
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 255,
                },
                'blue': {
                  'type': 'integer',
                  'minimum': 0,
                  'maximum': 255,
                },
              },
              'required': ['red', 'green', 'blue'],
            },
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'getDeviceInfo',
            'description': 'Get device information.',
            'parameters': {'type': 'object', 'properties': {}},
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'getBatteryInfo',
            'description': 'Get battery information.',
            'parameters': {'type': 'object', 'properties': {}},
          },
        },
        {
          'type': 'function',
          'function': {
            'name': 'fileFeedback',
            'description': 'File a feedback report for the user.',
            'parameters': {
              'type': 'object',
              'properties': {
                'summary': {
                  'type': 'string',
                  'description': 'A concise summary of the feedback.',
                },
                'batteryInfo': {
                  'type': 'string',
                  'description':
                      'If the user complains about performance, include battery info.',
                },
                'deviceInfo': {
                  'type': 'string',
                  'description':
                      'A 2 sentence summary of device info: model/manufacturer/OS.',
                },
                'actionHistory': {
                  'type': 'string',
                  'description': 'History of actions taken/recommended.',
                },
                'tags': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'priority': {
                  'type': 'integer',
                  'description':
                      'Priority from 0 (very urgent) to 4 (low urgency).',
                },
              },
              'required': ['summary', 'deviceInfo', 'actionHistory', 'tags', 'priority'],
            },
          },
        },
      ];

  Future<bool> _confirmSettingChange(
    BuildContext context,
    String question,
  ) async {
    if (!context.mounted) return false;
    return askConfirmation(context, question);
  }

  void initialize(){
    _history
      ..clear()
      // Some OpenRouter providers reject the `system` role. Put instructions in the
      // first user message instead.
      ..add({'role': 'user', 'content': '$_systemPrompt\n\n$_actionProtocolPrompt'});
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

  Future<String> _handleAskConfirmationTool(
    BuildContext context,
    Map<String, dynamic> args,
  ) async {
    final question = args['question']?.toString();
    if (question == null || question.trim().isEmpty) return 'no';

    final ok = await askConfirmation(context, question);
    return ok ? 'yes' : 'no';
  }

  Future<String> _handleSetFontFamilyTool(
    BuildContext context,
    Map<String, dynamic> args,
  ) async {
    final fontFamily = args['fontFamily']?.toString();
    if (fontFamily == null || fontFamily.trim().isEmpty || !context.mounted) {
      _lastUiMessage = 'Missing fontFamily.';
      return _lastUiMessage!;
    }

    final ok = await _confirmSettingChange(
      context,
      'Change font family to "$fontFamily"?',
    );
    if (!ok) {
      _lastUiMessage = 'Okay, I won\'t change the font family.';
      return _lastUiMessage!;
    }

    context.read<ThemeSettingsCubit>().setFontFamily(fontFamily);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Font family updated to $fontFamily')),
      );
    }

    _lastUiMessage = 'I\'ve updated the font family to $fontFamily.';
    return _lastUiMessage!;
  }

  Future<String> _handleSetFontSizeFactorTool(
    BuildContext context,
    Map<String, dynamic> args,
  ) async {
    final raw = args['fontSizeFactor'];
    if (raw is! num || !context.mounted) {
      _lastUiMessage = 'Missing fontSizeFactor.';
      return _lastUiMessage!;
    }

    final factor = raw.toDouble().clamp(1.0, 2.0);
    final ok = await _confirmSettingChange(
      context,
      'Set font size to ${factor.toStringAsFixed(2)}?',
    );
    if (!ok) {
      _lastUiMessage = 'Okay, I won\'t change the font size.';
      return _lastUiMessage!;
    }

    context.read<ThemeSettingsCubit>().setFontSizeFactor(factor);
    _lastUiMessage =
        'I\'ve updated the font size to ${factor.toStringAsFixed(2)}.';
    return _lastUiMessage!;
  }

  Future<String> _handleSetAppColorTool(
    BuildContext context,
    Map<String, dynamic> args,
  ) async {
    final redRaw = args['red'];
    final greenRaw = args['green'];
    final blueRaw = args['blue'];
    if (redRaw is! int || greenRaw is! int || blueRaw is! int || !context.mounted) {
      _lastUiMessage = 'Missing RGB values.';
      return _lastUiMessage!;
    }

    final red = redRaw.clamp(0, 255);
    final green = greenRaw.clamp(0, 255);
    final blue = blueRaw.clamp(0, 255);

    final ok = await _confirmSettingChange(
      context,
      'Change app theme color to RGB($red, $green, $blue)?',
    );
    if (!ok) {
      _lastUiMessage = 'Okay, I won\'t change the app color.';
      return _lastUiMessage!;
    }

    final newSeedColor = Color.fromRGBO(red, green, blue, 1);
    context.read<ThemeSettingsCubit>().setAppColor(newSeedColor);
    _lastUiMessage = 'I\'ve updated the app theme color.';
    return _lastUiMessage!;
  }

  Future<String> _handleGetDeviceInfoTool() async {
    final info = await DeviceHelper.getDeviceInfo();
    return jsonEncode(info);
  }

  Future<String> _handleGetBatteryInfoTool() async {
    final info = await DeviceHelper.getBatteryInfo();
    return jsonEncode(info);
  }

  Future<String> fileFeedbackReport(
      BuildContext context,
      Map<String, dynamic> args,
      ) async {
    String summary = args['summary']?.toString() ?? '';
    String deviceInfo = args['deviceInfo']?.toString() ?? '';
    String batteryInfo = args['batteryInfo']?.toString() ?? '';
    String actionHistory = args['actionHistory']?.toString() ?? '';
    final tagsRaw = args['tags'];
    final tags = tagsRaw is List ? tagsRaw.map((e) => e.toString()).toList() : <String>[];
    final priorityRaw = args['priority'];
    final priority = priorityRaw is int ? priorityRaw : int.tryParse(priorityRaw?.toString() ?? '') ?? 4;

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

  Future<Map<String, dynamic>> _openRouterCreateChatCompletion({
    required List<Map<String, dynamic>> messages,
    List<Map<String, dynamic>>? tools,
  }) async {
    if (openRouterApiKey.trim().isEmpty) {
      throw Exception('Missing OPENROUTER_API_KEY.');
    }

    final prepared = _prepareMessagesForProvider(messages);

    final body = <String, dynamic>{
      'model': _openRouterModel,
      'messages': prepared,
      'temperature': 0.2,
    };
    if (tools != null) {
      body['tools'] = tools;
      body['tool_choice'] = 'auto';
    }

    final response = await http
        .post(
          _openRouterChatCompletionsUrl,
          headers: _openRouterHeaders,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OpenRouter request failed: ${response.statusCode} - ${_formatOpenRouterError(response.body)}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('OpenRouter response was not a JSON object');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _openRouterCreateCompletion({
    required String prompt,
  }) async {
    if (openRouterApiKey.trim().isEmpty) {
      throw Exception('Missing OPENROUTER_API_KEY.');
    }

    final body = <String, dynamic>{
      'model': _openRouterModel,
      'prompt': prompt,
      'temperature': 0.2,
    };

    final response = await http
        .post(
          _openRouterCompletionsUrl,
          headers: _openRouterHeaders,
          body: jsonEncode(body),
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'OpenRouter request failed: ${response.statusCode} - ${_formatOpenRouterError(response.body)}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('OpenRouter response was not a JSON object');
    }
    return decoded;
  }

  String _buildCompletionPromptFromHistory() {
    final b = StringBuffer();
    for (final m in _history) {
      final role = (m['role']?.toString() ?? 'user').toLowerCase();
      final content = m['content']?.toString() ?? '';
      if (content.trim().isEmpty) continue;
      if (role == 'user') {
        b.writeln('User: $content');
      } else {
        b.writeln('Assistant: $content');
      }
      b.writeln();
    }
    b.writeln('Assistant:');
    return b.toString();
  }

  String _extractAssistantTextFromOpenAIResponse(Map<String, dynamic> decoded) {
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenRouter response had no choices');
    }

    final first = choices.first;
    if (first is Map) {
      // /chat/completions style
      final msg = first['message'];
      if (msg is Map) {
        final c = msg['content']?.toString();
        if (c != null) return c;
      }
      // /completions style
      final t = first['text']?.toString();
      if (t != null) return t;
    }
    return first.toString();
  }

  List<Map<String, dynamic>> _prepareMessagesForProvider(
    List<Map<String, dynamic>> messages,
  ) {
    // Some OpenRouter providers reject:
    // - non-string content
    // - system role
    // We'll start by coercing content to string where possible.
    final coerced = <Map<String, dynamic>>[];
    const allowedRoles = {'user', 'assistant', 'system'};
    for (final m in messages) {
      var role = m['role']?.toString() ?? 'user';
      if (!allowedRoles.contains(role)) {
        // Providers can reject unknown roles like `tool`.
        role = 'assistant';
      }
      final content = m['content'];
      if (content is String) {
        coerced.add({'role': role, 'content': content});
      } else {
        coerced.add({'role': role, 'content': content?.toString() ?? ''});
      }
    }

    // We avoid `system` in initialize(), but keep this normalization in case
    // other callers add it.
    return coerced;
  }

  List<Map<String, dynamic>> _mergeSystemIntoFirstUser(
    List<Map<String, dynamic>> messages,
  ) {
    final systemParts = messages
        .where((m) => (m['role']?.toString() ?? '') == 'system')
        .map((m) => m['content']?.toString() ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final withoutSystem = messages
        .where((m) => (m['role']?.toString() ?? '') != 'system')
        .map((m) => {
              'role': m['role']?.toString() ?? 'user',
              'content': m['content']?.toString() ?? '',
            })
        .toList();

    if (systemParts.isEmpty) return withoutSystem;
    final sys = systemParts.join('\n\n');

    final firstUserIndex = withoutSystem.indexWhere((m) => m['role'] == 'user');
    if (firstUserIndex == -1) {
      return [
        {'role': 'user', 'content': sys},
        ...withoutSystem,
      ];
    }

    final existing = withoutSystem[firstUserIndex]['content']?.toString() ?? '';
    withoutSystem[firstUserIndex] = {
      'role': 'user',
      'content': '$sys\n\n$existing',
    };
    return withoutSystem;
  }

  String _formatOpenRouterError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final err = decoded['error'];
        if (err is Map) {
          final msg = err['message']?.toString();
          final meta = err['metadata'];
          if (meta is Map) {
            final raw = meta['raw']?.toString();
            if (raw != null && raw.trim().isNotEmpty) {
              return '$msg ($raw)';
            }
          }
          if (msg != null && msg.trim().isNotEmpty) return msg;
        }
      }
    } catch (_) {
      // ignore
    }
    return body;
  }

  String _stripCodeFences(String text) {
    var t = text.trim();
    if (t.startsWith('```')) {
      t = t.replaceAll(RegExp(r'^```\w*\n'), '');
      t = t.replaceAll(RegExp(r'```$'), '');
    }
    return t.trim();
  }

  Future<String?> _runJsonActionLoop(BuildContext context) async {
    for (var round = 0; round < _maxToolRounds; round++) {
      Map<String, dynamic> decoded;
      try {
        if (_preferCompletionsEndpoint) {
          final prompt = _buildCompletionPromptFromHistory();
          decoded = await _openRouterCreateCompletion(prompt: prompt);
        } else {
          decoded = await _openRouterCreateChatCompletion(messages: _history);
        }
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('OpenRouter request failed: 400')) {
          // Retry by removing system role (already avoided, but keep for safety)
          final merged = _mergeSystemIntoFirstUser(_history);
          _history
            ..clear()
            ..addAll(merged);

          // Some providers reject one endpoint but accept the other.
          try {
            if (_preferCompletionsEndpoint) {
              // We tried /completions first; fall back to /chat/completions.
              decoded = await _openRouterCreateChatCompletion(messages: _history);
            } else {
              // We tried /chat/completions first; fall back to /completions.
              final prompt = _buildCompletionPromptFromHistory();
              decoded = await _openRouterCreateCompletion(prompt: prompt);
            }
          } catch (_) {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      final content = _extractAssistantTextFromOpenAIResponse(decoded);
      if (content.trim().isEmpty) return null;

      // Keep assistant message for context.
      _history.add({'role': 'assistant', 'content': content});

      final cleaned = _stripCodeFences(content);
      Map<String, dynamic>? parsed;
      try {
        final decodedJson = jsonDecode(cleaned);
        if (decodedJson is Map<String, dynamic>) {
          parsed = decodedJson;
        } else if (decodedJson is Map) {
          parsed = Map<String, dynamic>.from(decodedJson);
        }
      } catch (_) {
        parsed = null;
      }

      if (parsed == null) {
        // Not JSON; ask once more using the JSON-only protocol.
        _history.add({
          'role': 'user',
          'content':
              'Please respond with ONLY the JSON object (no extra text), following the schema exactly.',
        });
        continue;
      }

      final assistantMessage = parsed['assistant_message']?.toString().trim();
      final actionsRaw = parsed['actions'];
      final actions = actionsRaw is List ? actionsRaw : const [];
      if (actions.isEmpty) {
        return (assistantMessage?.isNotEmpty ?? false)
            ? assistantMessage
            : content.trim();
      }

      var requestedInfo = false;
      for (final a in actions) {
        if (a is! Map) continue;
        final action = Map<String, dynamic>.from(a as Map);
        final type = action['type']?.toString();
        if (type == null) continue;

        switch (type) {
          case 'setFontFamily':
            await _handleSetFontFamilyTool(context, action);
            break;
          case 'setFontSizeFactor':
            await _handleSetFontSizeFactorTool(context, action);
            break;
          case 'setAppColor':
            await _handleSetAppColorTool(context, action);
            break;
          case 'getDeviceInfo':
            final info = await _handleGetDeviceInfoTool();
            _history.add({'role': 'user', 'content': 'DeviceInfo: $info'});
            requestedInfo = true;
            break;
          case 'getBatteryInfo':
            final info = await _handleGetBatteryInfoTool();
            _history.add({'role': 'user', 'content': 'BatteryInfo: $info'});
            requestedInfo = true;
            break;
          case 'fileFeedback':
            final report = await fileFeedbackReport(context, action);
            _lastUiMessage = 'Feedback Report successfully filed.';
            return (assistantMessage?.isNotEmpty ?? false)
                ? assistantMessage
                : _lastUiMessage;
          default:
            // ignore unknown actions
            break;
        }
      }

      if (requestedInfo) {
        continue;
      }

      return (assistantMessage?.isNotEmpty ?? false)
          ? assistantMessage
          : (_lastUiMessage ?? 'Done.');
    }

    throw Exception('Too many rounds.');
  }

  Future<String?> submitFeedback(
    BuildContext context,
    Uint8List userScreenshot,
    String userFeedbackText,
  ) async {
    try {
      _lastUiMessage = null;
      // Store the screenshot and feedback text for later use
      screenshot = userScreenshot;
      feedbackText = userFeedbackText;

      final userText =
          'Please analyze this user feedback and either: (1) help the user directly if it\'s something that can be addressed in-app, or (2) file a feedback report if it requires developer attention. For app settings changes, use the appropriate tools. For bug reports/feature requests, use the fileFeedback tool.\n\nUser feedback: $userFeedbackText';

      if (userScreenshot.isNotEmpty && _modelSupportsVision) {
        final b64 = base64Encode(userScreenshot);
        _history.add({
          'role': 'user',
          'content': [
            {'type': 'text', 'text': userText},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$b64'},
            },
          ],
        });
      } else {
        // Many OpenRouter providers only support plain string content.
        _history.add({'role': 'user', 'content': userText});
      }

      final text = await _runJsonActionLoop(context);
      return text ?? _lastUiMessage;
    } on TimeoutException {
      return 'This is taking too long. Please try again.';
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      rethrow; // Rethrow to be handled by the caller
    }
  }
}