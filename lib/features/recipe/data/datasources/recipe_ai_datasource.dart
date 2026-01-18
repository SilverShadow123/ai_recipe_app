import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../../core/constants/constant.dart';

class RecipeAIDatasource {

  static const String _openRouterModel = 'google/gemma-3-27b-it:free';
  static const String _openRouterVisionModel =
      'nvidia/nemotron-nano-12b-v2-vl:free';

  Uri get _openRouterChatCompletionsUrl =>
      Uri.parse('$openRouterBaseUrl/chat/completions');

  static const Duration _textTimeout = Duration(seconds: 30);
  static const Duration _imageTimeout = Duration(seconds: 90);
  static const int _maxQuotaRetries = 2;
  static const Duration _maxAutoRetryWait = Duration(seconds: 10);

  Map<String, String> get _openRouterHeaders => {
        'Authorization': 'Bearer $openRouterApiKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<String> _openRouterChat({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.2,
    String? model,
    Duration? timeout,
  }) async {
    if (openRouterApiKey.trim().isEmpty) {
      throw Exception(
        'Missing OPENROUTER_API_KEY. Provide it securely (do not hardcode).',
      );
    }

    final body = {
      'model': model ?? _openRouterModel,
      'messages': messages,
      'temperature': temperature,
    };

    final response = await http
        .post(
          _openRouterChatCompletionsUrl,
          headers: _openRouterHeaders,
          body: jsonEncode(body),
        )
        .timeout(timeout ?? _textTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorText;
      try {
        final decoded = jsonDecode(response.body);
        errorText = decoded is Map
            ? (decoded['error']?.toString() ?? decoded.toString())
            : decoded.toString();
      } catch (_) {
        errorText = response.body;
      }

      final retryAfter = response.headers['retry-after'];
      final retrySuffix = (retryAfter != null && retryAfter.trim().isNotEmpty)
          ? ' retry-after: ${retryAfter.trim()}s'
          : '';

      throw Exception(
        'OpenRouter request failed: ${response.statusCode} - $errorText$retrySuffix',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('OpenRouter response was not JSON object');
    }

    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('OpenRouter response had no choices');
    }

    final message = choices.first['message'];
    final content = message is Map ? message['content'] : null;
    final text = content?.toString().trim();
    if (text == null || text.isEmpty) {
      throw Exception('OpenRouter returned empty content');
    }
    return text;
  }

  bool _isQuotaError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('quota exceeded') ||
        msg.contains('rate limit') ||
        msg.contains('rate limited') ||
        msg.contains('rate-limits') ||
        msg.contains('resource_exhausted') ||
        msg.contains('too many requests') ||
        msg.contains(' 429 ');
  }

  bool _isVisionUnsupportedError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('unsupported media type') ||
        msg.contains('unsupported content type') ||
        msg.contains('unsupported image') ||
        msg.contains('unsupported input') ||
        msg.contains('invalid request parameters') ||
        msg.contains('provider returned error') ||
        msg.contains('image_url') ||
        msg.contains('multimodal') ||
        msg.contains('vision');
  }

  Duration? _parseRetryAfter(Object error) {
    final msg = error.toString();

    final matchSeconds = RegExp(r'Please retry in\s*([0-9.]+)s').firstMatch(msg);
    final matchHeader = RegExp(
      r'retry-after\s*:\s*([0-9.]+)s?',
      caseSensitive: false,
    ).firstMatch(msg);

    final raw = matchSeconds?.group(1) ?? matchHeader?.group(1);
    if (raw == null) return null;
    final seconds = double.tryParse(raw);
    if (seconds == null) return null;
    final ms = (seconds * 1000).ceil();
    if (ms <= 0) return null;
    // Cap so we don't block the UI forever.
    return Duration(milliseconds: ms.clamp(0, 20000));
  }

  Exception _quotaFriendlyException(Object error) {
    final retry = _parseRetryAfter(error);
    if (retry != null) {
      final s = (retry.inMilliseconds / 1000).toStringAsFixed(0);
      return Exception('Rate limit reached. Please wait about ${s}s and try again.');
    }
    return Exception('Rate limit reached. Please try again in a moment.');
  }

  Future<T> _runWithQuotaRetry<T>(Future<T> Function() fn) async {
    var attempt = 0;
    while (true) {
      try {
        return await fn();
      } catch (e) {
        if (_isQuotaError(e) && attempt < _maxQuotaRetries) {
          attempt++;
          final wait = _parseRetryAfter(e) ?? const Duration(seconds: 5);
          if (wait > _maxAutoRetryWait) {
            throw _quotaFriendlyException(e);
          }
          await Future.delayed(wait);
          continue;
        }
        if (_isQuotaError(e)) {
          throw _quotaFriendlyException(e);
        }
        rethrow;
      }
    }
  }

  String _normalizeCommaSeparatedList(String raw) {
    var text = raw.trim();

    if (text.startsWith('```')) {
      text = text.replaceAll(RegExp(r'^```\w*\n|```$'), '').trim();
    }

    text = text.replaceAll(RegExp(r'\r?\n'), ', ');
    text = text.replaceAll(RegExp(r'\s*,\s*'), ', ');
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    text = text.replaceAll(RegExp(r'^\s*[-*]\s*'), '');
    text = text.replaceAll(RegExp(r'\s*[,;]\s*$'), '');
    return text.trim();
  }

  String _sniffImageMimeType(Uint8List bytes) {
    if (bytes.length >= 12) {
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47 &&
          bytes[4] == 0x0D &&
          bytes[5] == 0x0A &&
          bytes[6] == 0x1A &&
          bytes[7] == 0x0A) {
        return 'image/png';
      }

      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return 'image/jpeg';
      }

      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return 'image/webp';
      }
    }

    return 'image/jpeg';
  }

  Future<String> extractIngredientsFromImage(Uint8List imageBytes) async {
    if (imageBytes.length > 3 * 1024 * 1024) {
      return 'Image is too large to analyze. Please choose a smaller image.';
    }

    final mime = _sniffImageMimeType(imageBytes);
    final imageB64 = base64Encode(imageBytes);
    final messages = [
      {
        'role': 'user',
        'content': [
          {
            'type': 'text',
            'text':
                'Analyze the attached image and return ONLY the FOOD INGREDIENTS you can identify.\n'
                    'Return them as a comma-separated list, with no extra words or explanation.\n'
                    'Be specific (e.g., "2 tomatoes" if size/amount is clear), but if uncertain use the ingredient name only.',
          },
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:$mime;base64,$imageB64',
              'detail': 'low',
            },
          },
        ],
      },
    ];
    try {
      final text = await _runWithQuotaRetry(() async {
        try {
          return await _openRouterChat(
            messages: messages,
            timeout: _imageTimeout,
            model: _openRouterModel,
          );
        } catch (e) {
          if (_isVisionUnsupportedError(e) &&
              _openRouterVisionModel != _openRouterModel) {
            return await _openRouterChat(
              messages: messages,
              timeout: _imageTimeout,
              model: _openRouterVisionModel,
            );
          }
          rethrow;
        }
      });

      return _normalizeCommaSeparatedList(text);
    } on TimeoutException {
      return 'No ingredients found';
    } catch (e) {
      if (_isQuotaError(e)) {
        throw _quotaFriendlyException(e);
      }
      if (_isVisionUnsupportedError(e)) {
        debugPrint('Vision not supported for extractIngredientsFromImage: $e');
        return 'Image analysis is not supported right now.';
      }
      debugPrint('Error in extractIngredientsFromImage: $e');
      return 'No ingredients found';
    }
  }

  Future<Uint8List> generateRecipeImage(String ingredients, String? notes) async {
    try {
      if (apiKey.trim().isEmpty) {
        throw Exception(
          'Missing VYRO_API_KEY. Provide it via --dart-define=VYRO_API_KEY=YOUR_KEY',
        );
      }

      String prompt = "A professional food photography shot of this recipe: $ingredients."
          "High-end food photography, restaurant-quality plating, soft natural lighting, "
          "on a clean background, showing the complete plated dish";
      if (notes != null && notes.isNotEmpty) {
        prompt += "\nStyle notes: $notes";
      }

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['prompt'] = prompt
        ..fields['style'] = 'realistic'
        ..fields['aspect_ratio'] = '1:1'
        ..fields['seed'] = DateTime.now().millisecondsSinceEpoch.toString();

      final streamedResponse =
          await request.send().timeout(_imageTimeout);
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(_imageTimeout);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        dynamic error;
        try {
          error = jsonDecode(response.body);
        } catch (_) {
          error = response.body;
        }
        throw Exception(
          'Failed to generate image: ${response.statusCode} - ${error is Map ? (error['error'] ?? response.body) : error}',
        );
      }
    } catch (e) {
      debugPrint('Error in generateRecipeImage: $e');
      rethrow;
    }
  }

  Future<String> generateRecipe(String ingredients, String? notes) async {
    String prompt = """
Based on this list of ingredients: $ingredients, generate a recipe.

Return valid Markdown using this exact structure:

# <Recipe name>

**Cooking Time:** <time>
**Servings:** <servings>

## Ingredients
- item 1
- item 2

## Instructions
1. step 1
2. step 2

Rules:
- Do not include anything outside this structure.
- Keep it concise and practical.
- If notes are provided, consider them but do not mention them in the output.
""";

    if (notes != null && notes.isNotEmpty) {
      prompt += "\nNotes: $notes";
    }

    try {
      final text = await _runWithQuotaRetry(
        () => _openRouterChat(
          messages: [
            {'role': 'user', 'content': prompt},
          ],
          temperature: 0.3,
        ),
      );
      return text;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      if (_isQuotaError(e)) {
        throw _quotaFriendlyException(e);
      }
      debugPrint('Error in generateRecipe: $e');
      rethrow;
    }
  }
}
