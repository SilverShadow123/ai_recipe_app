import 'package:firebase_ai/firebase_ai.dart';

class RecipeAIDatasource {
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash-lite',
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 200,

    )
  );

  Future<String> generateRecipe(String ingredients, String? notes) async {
    String prompt =
        """
Based on this list of ingredients: $ingredients, please generate a recipe.

Follow this exact format and nothing else:

**<Recipe name>**

Cooking Time: <time>
Servings: <servings>

**Ingredients:**
- item 1
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
    return response.text ?? 'No recipe generated.';
  }
}
