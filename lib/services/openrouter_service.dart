import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:coo_list/data/repositories/log_repository.dart';

class OpenRouterService {
  final String _baseUrl = dotenv.env['OPENROUTER_URL'] ?? '';
  final String _apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
  final LogRepository _logRepository = LogRepository();

  Future<Map<String, dynamic>> analyzeImageProduct(File image) async {
    try {
      final base64Image = base64Encode(await image.readAsBytes());
      final requestBody = jsonEncode({
        'model': 'google/gemini-2.5-flash',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
              },
              {
                'type': 'text',
                'text':
                    """Analyze the given image and identify the product shown. Extract and return the following details in JSON format:\n\n
**Extraction Requirements:**\n
- **`name`**: A descriptive product name in **Hungarian** and put the brand name at the end of tha name using the format: **[what is the product] [product name] [brand name]**. For example: "Tej félzsíros UHT Mizo".\n
- **`category`**: Predict and classify the product into one of the following categories:\n
  - 'Zöldség' (Vegetables)\n
  - 'Gyümölcs' (Fruits)\n
  - 'Pékárú' (Bakery)\n
  - 'Hús' (Meat)\n
  - 'Italok' (Drinks)\n
  - 'Alkohol' (Alcohol)\n
  - 'Háztartás' (Household)\n
  - 'Alapvető élelmiszerek' (Basic food items)\n
  - 'Tejtermékek' (Dairy products)\n
  - 'Higénia' (Beauty care)\n
- **`price`**: Predict the price in **Hungarian Forints (HUF)** if not explicitly visible.\n
- **`weight`**: Predict the weight of a **single piece** in grams if not visible.\n
- **`db`**: Predict the **number of pieces** in the package if not visible.\n
- **`spoilage`**: Predict the **typical spoilage time** in **days** if the product is food, or if it is a non-food item, estimate its **expected usage duration (days)** before empty.\n\n
**Data Handling & Predictions:**\n
- For perishable food (e.g., dairy, meat, bakery, vegetables, fruits), estimate **how many days it lasts before spoiling**.\n
- For non-perishable items (e.g., household, beauty, packaged goods), estimate **how many days it lasts with normal usage**.\n
**JSON Output Format:**\n
{\n
  "name": "[Termék neve] [Márkanév]",\n
  "category": "Kategória",\n
  "price": 1500,\n
  "weight": 250,\n
  "db": 4,\n
  "spoilage": 5\n
}\n\n
**Additional Considerations:**\n
- Use **Hungarian language** for names and categories.\n
- If you cannot confidently determine a product, return:\n
{ "error": "Nem lehet azonosítani a terméket a képről." }\n" """
              }
            ]
          }
        ],
        'max_tokens': 300
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'ai_vision_app',
          'X-Title': 'YourApp',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            responseData['choices'][0]['message']['content']?.trim() ?? '';
        developer.log(content);
        final parsed = parseResponse(content);
        await _logRepository.logEvent(
          logName: 'analyze_image_product_AI',
          additionalData: parsed,
        );
        return parsed;
      }

      throw Exception(
          'Nem sikerült a kép analizálása. Státusz kód: ${response.statusCode}');
    } catch (e) {
      await _logRepository.logEvent(
        logName: 'analyze_image_product_AI',
        additionalData: {'error': 'Hiba a kép analizálása során: $e'},
      );
      return {'error': 'Hiba a kép analizálása során: $e'};
    }
  }

  Future<Map<String, dynamic>> analyzeTextProduct(String inputText) async {
    try {
      final requestBody = jsonEncode({
        'model': 'google/gemini-2.5-flash',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    """Analyze the given text and create a product from that. Extract and return the following details in JSON format:\n\n
                    "**User Input:** $inputText"
**Extraction Requirements:**\n
- **`name`**: A descriptive product name in **Hungarian** using the format: **[product name] [brand name]**. For example: "Tej félzsíros UHT Mizo".\n
- **`category`**: Predict and classify the product into one of the following categories:\n
  - 'Zöldség' (Vegetables)\n
  - 'Gyümölcs' (Fruits)\n
  - 'Pékárú' (Bakery)\n
  - 'Hús' (Meat)\n
  - 'Italok' (Drinks)\n
  - 'Alkohol' (Alcohol)\n
  - 'Háztartás' (Household)\n
  - 'Alapvető élelmiszerek' (Basic food items)\n
  - 'Tejtermékek' (Dairy products)\n
  - 'Higénia' (Beauty care)\n
- **`price`**: Predict the price in **Hungarian Forints (HUF)** if not explicitly visible.\n
- **`weight`**: Predict the weight of a **single piece** in grams if not visible.\n
- **`db`**: Predict the **number of pieces** in the package if not visible.\n
- **`spoilage`**: Predict the **typical spoilage time** in **days** if the product is food, or if it is a non-food item, estimate its **expected usage duration (days)** before empty.\n\n
**Data Handling & Predictions:**\n
- For perishable food (e.g., dairy, meat, bakery, vegetables, fruits), estimate **how many days it lasts before spoiling**.\n
- For non-perishable items (e.g., household, beauty, packaged goods), estimate **how many days it lasts with normal usage**.\n
**JSON Output Format:**\n
{\n
  "name": "[Termék neve] [Márkanév]",\n
  "category": "Kategória",\n
  "price": 1500,\n
  "weight": 250,\n
  "db": 4,\n
  "spoilage": 5\n
}\n\n
**Additional Considerations:**\n
- Use **Hungarian language** for names and categories.\n
- If you cannot confidently determine a product, return:\n
{ "error": "Cannot identify product from image." }\n"

"""
              }
            ]
          }
        ],
        'max_tokens': 300
      });
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'ai_vision_app',
          'X-Title': 'YourApp',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            responseData['choices'][0]['message']['content']?.trim() ?? '';
        developer.log(content);
        final parsed = parseResponse(content);
        await _logRepository.logEvent(
          logName: 'analyze_text_product_AI',
          additionalData: parsed,
        );
        return parsed;
      }

      throw Exception(
          'Nem sikerült a szöveg analizálása. Státusz kód: ${response.statusCode}');
    } catch (e) {
      await _logRepository.logEvent(
        logName: 'analyze_text_product_AI',
        additionalData: {'error': 'Hiba a szöveg analizálása során: $e'},
      );
      return {'error': 'Hiba a szöveg analizálása során: $e'};
    }
  }

  Future<Map<String, dynamic>> generateRecipe(
      List<Map<String, dynamic>> ingredients) async {
    try {
      ingredients.sort((a, b) => a['spoilage'].compareTo(b['spoilage']));

      String formattedIngredients = ingredients.map((ingredient) {
        return "- ${ingredient['name']} (${ingredient['weight']}g, ${ingredient['db']} pcs, ${ingredient['spoilage']} days to spoil)";
      }).join("\n");
      final requestBody = jsonEncode({
        'model': 'google/gemini-2.0-flash-001',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': 'Generate a detailed and delicious recipe using only the provided ingredients. The recipe must be written in **Hungarian**, while this prompt is in English.\n'
                    "\n"
                    '**Instructions:**\n'
                    '1. Select ingredients from the provided list, prioritizing those with the lowest spoilage value.\n'
                    '2. Create an **authentic and well-structured Hungarian dish** using only the available ingredients.\n'
                    '3. Do **not** introduce any additional ingredients that are not listed.\n'
                    '4. The output must include:\n'
                    '   - A structured recipe name in Hungarian\n'
                    '   - A short description of the dish in Hungarian\n'
                    '   - A list of ingredients with their amounts\n'
                    '   - A step-by-step preparation method in Hungarian, formatted as a linked list where the **step number is the key**.\n'
                    '\n'
                    '**Available Ingredients:**\n'
                    '$formattedIngredients\n'
                    '\n'
                    '**Output Format (in Hungarian):**\n'
                    '{\n'
                    '  "recipe_name": "Recept neve",\n'
                    '  "description": "Rövid leírás a fogásról.",\n'
                    '  "ingredients": [\n'
                    '    {"name": "Hozzávaló neve", "amount": "Mennyiség és mértékegység"}\n'
                    '  ],\n'
                    '  "instructions": {\n'
                    '    "1": "Első lépés...",\n'
                    '    "2": "Második lépés...",\n'
                    '    "3": "Harmadik lépés..."\n'
                    '  }\n'
                    '}\n'
              }
            ]
          }
        ],
        'max_tokens': 800
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'ai_vision_app',
          'X-Title': 'YourApp',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            responseData['choices'][0]['message']['content']?.trim() ?? '';
        developer.log(content);
        final parsed = parseResponse(content);
        await _logRepository.logEvent(
          logName: 'generate_recipe_AI',
          additionalData: parsed,
        );
        return parsed;
      }

      throw Exception(
          'Nem sikerült a recept generálása. Státusz kód: ${response.statusCode}');
    } catch (e) {
      await _logRepository.logEvent(
        logName: 'generate_recipe_AI',
        additionalData: {'error': 'Hiba a recept generálása során: $e'},
      );
      return {'error': 'Hiba a recept generálása során: $e'};
    }
  }

  Future<Map<String, dynamic>> generateRecipeDynamic(
      List<Map<String, dynamic>> ingredients,
      String cuisine,
      String preparationTime,
      int servings,
      String difficulty,
      String mealType) async {
    try {
      ingredients.shuffle(Random());

      String ingredientsList = ingredients.map((ingredient) {
        if (ingredient['spoilage'] >= 0) {
          return "- ${ingredient['name']} (${ingredient['weight']}g, ${ingredient['db']} pcs";
        }
      }).join("\n");

      final requestBody = jsonEncode({
        'model': 'google/gemini-2.5-flash',
        'response_format': {'type': 'json_object'},
        'max_tokens': 1000,
        'messages': [
          {
            'role': 'system',
            'content': '''
You are a Michelin‑starred chef and recipe developer. Create appetizing, authentic dishes that home cooks can reproduce. **Reply only in Hungarian** and output exactly one valid JSON object—no extra text.
'''
          },
          {
            'role': 'user',
            'content': """
### Ingredients on Hand
$ingredientsList

### User Preferences
- Cuisine: $cuisine
- Prep‑time category: $preparationTime  (Short <20 min · Medium 20–60 min · Long 60–120 min)
- Servings: $servings
- Difficulty: $difficulty
- Meal type: $mealType

### Your Task
1. **Select only ingredients that create classic or region‑approved flavor pairings** for the chosen cuisine. If uncertain, leave it out.
2. Base the dish on a recognizable classic (or regional variant) and adapt it authentically to the available ingredients.
3. Write every word in **plain, everyday Hungarian**—short, clear sentences.
4. **Do not add or substitute any ingredient not on the list.** No placeholders, no "optional pantry" items.
5. Compute a realistic integer "preparation_time_minutes" within the category ranges: 5‑20 (Short), 21‑60 (Medium), 61‑120 (Long).
6. Provide **3–6 concise steps**, each starting with an imperative verb (e.g. „Melegítsd", „Pirítsd", „Tálald"). Use familiar home‑cooking methods (sauté, bake, simmer, roast).
7. When heat is involved, indicate approximate temperature or heat level (pl.: „közepes lángon", „180 °C‑ra előmelegített sütőben").
8. Metric quantities only (g, ml, db, tk), ordered as used, and proportionate to the stated servings (≈400–500 g kész étel/fő főfogásnál).
9. Beverages (tea, coffee, juice) may be used **only** in desserts; otherwise hagyd ki.
10. If no practical, appetizing dish is possible, return exactly: {"error":"Nincs elkészíthető étel a megadott hozzávalókból."}
11. Ensure the dish sounds mouth‑watering: balance savory/sweet/acid/salt, provide texture & color contrast, and suggest an optional garnish.
12. **Self‑check before output:** verify ingredient harmony, method feasibility, flavor balance, correct Hungarian, and JSON validity. Revise internally if needed, then output the JSON.

### JSON Schema (return only this object!)
{
  "recipe_name": "Recept neve",
  "description": "1 mondat: miért finom, milyen ízek/textúrák dominálnak.",
  "cuisine": "$cuisine",
  "preparation_time_category": "$preparationTime",
  "preparation_time_minutes": X,
  "servings": $servings,
  "difficulty": "$difficulty",
  "meal_type": "$mealType",
  "ingredients": [
    {"name": "Hozzávaló neve", "amount": "Mennyiség és mértékegység"}
  ],
  "instructions": {
    "1": "Első lépés...",
    "2": "Második lépés...",
    "3": "Harmadik lépés..."
  },
  "garnish": "Opcionális tálalási ötlet (1 rövid mondat)"
}
"""
          }
        ]
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'ai_vision_app',
          'X-Title': 'YourApp',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            responseData['choices'][0]['message']['content']?.trim() ?? '';
        developer.log(content);
        final parsed = parseResponse(content);
        await _logRepository.logEvent(
          logName: 'generate_recipe_dynamic_AI',
          additionalData: parsed,
        );
        return parsed;
      }

      throw Exception(
          'Nem sikerült a recept generálása. Státusz kód: ${response.statusCode}');
    } catch (e) {
      await _logRepository.logEvent(
        logName: 'generate_recipe_dynamic_AI',
        additionalData: {'error': 'Hiba a recept generálása során: $e'},
      );
      return {'error': 'Hiba a recept generálása során: $e'};
    }
  }

  Future<Map<String, dynamic>> generateRecipeWithSpoilageDynamic(
      List<Map<String, dynamic>> ingredients,
      String cuisine,
      String preparationTime,
      int servings,
      String difficulty,
      String mealType) async {
    try {
      ingredients.sort((a, b) => a['spoilage'].compareTo(b['spoilage']));

      String ingredientsList = ingredients.map((ingredient) {
        if (ingredient['spoilage'] >= 0) {
          return "- ${ingredient['name']} (${ingredient['weight']}g, ${ingredient['db']} pcs, ${ingredient['spoilage']} days until its spoiled.";
        }
      }).join("\n");

      final requestBody = jsonEncode({
        'model': 'google/gemini-2.5-flash',
        'response_format': {'type': 'json_object'},
        'max_tokens': 1000,
        'messages': [
          {
            'role': 'system',
            'content': '''
You are a Michelin‑starred chef and recipe developer. Create appetizing, authentic dishes that home cooks can reproduce. **Reply only in Hungarian** and output exactly one valid JSON object—no extra text.
'''
          },
          {
            'role': 'user',
            'content': """
### Ingredients on Hand
$ingredientsList

### User Preferences
- Cuisine: $cuisine
- Prep‑time category: $preparationTime  (Short <20 min · Medium 20–60 min · Long 60–120 min)
- Servings: $servings
- Difficulty: $difficulty
- Meal type: $mealType

### Your Task
1. **Select only ingredients that create classic or region‑approved flavor pairings** for the chosen cuisine. If uncertain, leave it out.
2. Base the dish on a recognizable classic (or regional variant) and adapt it authentically to the available ingredients.
3. Write every word in **plain, everyday Hungarian**—short, clear sentences.
4. **Do not add or substitute any ingredient not on the list.** No placeholders, no "optional pantry" items.
5. Compute a realistic integer "preparation_time_minutes" within the category ranges: 5‑20 (Short), 21‑60 (Medium), 61‑120 (Long).
6. Provide **3–6 concise steps**, each starting with an imperative verb (e.g. „Melegítsd", „Pirítsd", „Tálald"). Use familiar home‑cooking methods (sauté, bake, simmer, roast).
7. When heat is involved, indicate approximate temperature or heat level (pl.: „közepes lángon", „180 °C‑ra előmelegített sütőben").
8. Metric quantities only (g, ml, db, tk), ordered as used, and proportionate to the stated servings (≈400–500 g kész étel/fő főfogásnál).
9. Beverages (tea, coffee, juice) may be used **only** in desserts; otherwise hagyd ki.
10. If no practical, appetizing dish is possible, return exactly: {"error":"Nincs elkészíthető étel a megadott hozzávalókból."}
11. Ensure the dish sounds mouth‑watering: balance savory/sweet/acid/salt, provide texture & color contrast, and suggest an optional garnish.
12. **Self‑check before output:** verify ingredient harmony, method feasibility, flavor balance, correct Hungarian, and JSON validity. Revise internally if needed, then output the JSON.
13. Make sure to prioritize the soon to be spoiled ingredients, this is important keep in mind when making the recipe!

### JSON Schema (return only this object!)
{
  "recipe_name": "Recept neve",
  "description": "1 mondat: miért finom, milyen ízek/textúrák dominálnak.",
  "cuisine": "$cuisine",
  "preparation_time_category": "$preparationTime",
  "preparation_time_minutes": X,
  "servings": $servings,
  "difficulty": "$difficulty",
  "meal_type": "$mealType",
  "ingredients": [
    {"name": "Hozzávaló neve", "amount": "Mennyiség és mértékegység"}
  ],
  "instructions": {
    "1": "Első lépés...",
    "2": "Második lépés...",
    "3": "Harmadik lépés..."
  },
  "garnish": "Opcionális tálalási ötlet (1 rövid mondat)"
}
"""
          }
        ]
      });

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'ai_vision_app',
          'X-Title': 'YourApp',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        final content =
            responseData['choices'][0]['message']['content']?.trim() ?? '';
        final parsed = parseResponse(content);
        await _logRepository.logEvent(
          logName: 'generate_recipe_with_spoilage_dynamic_AI',
          additionalData: parsed,
        );
        return parsed;
      }

      throw Exception(
          'Nem sikerült a recept generálása. Státusz kód: ${response.statusCode}');
    } catch (e) {
      await _logRepository.logEvent(
        logName: 'generate_recipe_with_spoilage_dynamic_AI',
        additionalData: {'error': 'Hiba a recept generálása során: $e'},
      );
      return {'error': 'Hiba a recept generálása során: $e'};
    }
  }

  Map<String, dynamic> parseResponse(String content) {
    try {
      final cleanedContent =
          content.replaceAll("```json", "").replaceAll("```", "").trim();

      return jsonDecode(cleanedContent);
    } catch (e) {
      return {'error': 'Érvénytelen JSON válasz: $e'};
    }
  }
}
