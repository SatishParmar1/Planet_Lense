import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/plant_data.dart';

class PlantIdentificationService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<PlantData> identifyPlant(String base64Image, String language) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    final prompt = """
      You are an expert botanist. Identify the plant in this image.
      Respond in $language language.
      Respond ONLY with a single JSON object. Do not include any text or markdown formatting before or after the JSON object.
      The JSON object must have the following structure:
      {
        "commonName": "string",
        "scientificName": "string",
        "keyFacts": ["fact 1", "fact 2", "fact 3", "fact 4", "fact 5"],
        "description": ["bullet point 1", "bullet point 2", "bullet point 3", "bullet point 4"],
        "careGuide": {
          "watering": ["watering tip 1", "watering tip 2", "watering tip 3"],
          "sunlight": ["sunlight requirement 1", "sunlight requirement 2", "sunlight requirement 3"],
          "soil": ["soil requirement 1", "soil requirement 2", "soil requirement 3"]
        }
      }
      Provide all information as bullet points in arrays instead of long paragraphs.
      If you cannot identify the plant, respond with a JSON object where 'commonName' is 'Unknown' and other fields provide helpful advice.
    """;

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image
              }
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final candidate = responseBody['candidates'][0];
      final contentPart = candidate['content']['parts'][0];

      // Clean up the response text to ensure it's valid JSON
      String jsonString = contentPart['text']
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(jsonString);

      if (data['commonName'] == 'Unknown') {
        throw Exception('Could not identify the plant. Please try a clearer image or a different angle.');
      }

      return PlantData.fromJson(data);
    } else {
      throw Exception('API Error: ${response.statusCode}\n${response.body}');
    }
  }
}
