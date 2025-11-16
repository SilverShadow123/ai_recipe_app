import 'dart:typed_data';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:firebase_ai/firebase_ai.dart';

import '../../../../core/constants/constant.dart';

class RecipeAIDatasource {


  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash-lite',
  );


  Future<String> extractIngredientsFromImage(Uint8List imageBytes) async {
    final prompt = Content.multi([
      TextPart("""
    Analyze the attached image and return ONLY the FOOD INGREDIENTS you can identify.
    Return them as a comma-separated list, with no extra words or explanation.
    Be specific (e.g., "2 tomatoes" if size/amount is clear), but if uncertain use the ingredient name only.            
    """),
      InlineDataPart('image/jpeg', imageBytes),
    ]);
    final response = await model.generateContent([prompt]);
    return response.text?.trim() ?? 'No ingredients found';
  }

  Future<Uint8List> generateRecipeImage(String ingredients, String? notes) async {
    try {
      String prompt = "A professional food photography shot of this recipe: $ingredients."
          "High-end food photography, restaurant-quality plating, soft natural lighting, "
          "on a clean background, showing the complete plated dish";
      if (notes != null && notes.isNotEmpty) {
        prompt += "\nNotes for internal reasoning only: $notes";
      }

      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['prompt'] = prompt
        ..fields['style'] = 'realistic'
        ..fields['aspect_ratio'] = '1:1'
        ..fields['seed'] = DateTime.now().millisecondsSinceEpoch.toString();

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to generate image: ${response.statusCode} - ${error['error'] ?? response.body}');
      }
    } catch (e) {
      print('Error in generateRecipeImage: $e');
      rethrow;
    }
  }

  Future<String> generateRecipe(String ingredients, String? notes) async {
    String prompt =
        """
Based on this list of ingredients: $ingredients, please generate a recipe.

Follow this exact format and nothing else:

**<Recipe name>**

Cooking Time: <time>(first row}
Servings: <servings>(second row)

**Ingredients:**
- item 1"
- item 2
- item 3

**Instructions:**
1. step 1
2. step 2
3. step 3

Do not include anything outside this format.
If notes are provided, consider them but do not mention them in the output.
""";

    if (notes != null && notes.isNotEmpty) {
      prompt += "\nNotes for internal reasoning only: $notes";
    }
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? 'No recipe generated';
  }
}
