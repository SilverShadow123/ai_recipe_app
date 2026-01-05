import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/constant.dart';

class RecipeAIDatasource {


  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash-lite',
  );

  static const Duration _textTimeout = Duration(seconds: 30);
  static const Duration _imageTimeout = Duration(seconds: 90);
  static const int _maxQuotaRetries = 1;
  static const Duration _maxAutoRetryWait = Duration(seconds: 2);

  bool _isQuotaError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('quota exceeded') ||
        msg.contains('rate limit') ||
        msg.contains('rate-limits') ||
        msg.contains('resource_exhausted');
  }

  Duration? _parseRetryAfter(Object error) {
    final msg = error.toString();
    final match = RegExp(r'Please retry in\s*([0-9.]+)s').firstMatch(msg);
    if (match == null) return null;
    final seconds = double.tryParse(match.group(1) ?? '');
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


  Future<String> extractIngredientsFromImage(Uint8List imageBytes) async {
    final prompt = Content.multi([
      TextPart("""
    Analyze the attached image and return ONLY the FOOD INGREDIENTS you can identify.
    Return them as a comma-separated list, with no extra words or explanation.
    Be specific (e.g., "2 tomatoes" if size/amount is clear), but if uncertain use the ingredient name only.            
    """),
      InlineDataPart('image/jpeg', imageBytes),
    ]);
    try {
      final response = await _runWithQuotaRetry(
        () => model.generateContent([prompt]).timeout(_textTimeout),
      );
      final text = response.text;
      if (text == null || text.trim().isEmpty) return 'No ingredients found';
      return _normalizeCommaSeparatedList(text);
    } on TimeoutException {
      return 'No ingredients found';
    } catch (e) {
      if (_isQuotaError(e)) {
        throw _quotaFriendlyException(e);
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
      final response = await _runWithQuotaRetry(
        () => model.generateContent([Content.text(prompt)]).timeout(_textTimeout),
      );
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw Exception('No recipe generated');
      }
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
