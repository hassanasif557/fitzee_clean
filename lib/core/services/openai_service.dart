import 'dart:convert';
import 'package:http/http.dart' as http;

/// Custom exception for OpenAI quota exceeded errors
class QuotaExceededException implements Exception {
  final String message;
  QuotaExceededException(this.message);
  @override
  String toString() => message;
}

/// Custom exception for OpenAI rate limit errors
class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  @override
  String toString() => message;
}

/// Custom exception for OpenAI authentication errors
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  @override
  String toString() => message;
}

/// Custom exception for general OpenAI API errors
class OpenAIException implements Exception {
  final String message;
  final String? errorCode;
  OpenAIException(this.message, {this.errorCode});
  @override
  String toString() => message;
}

class OpenAIService {
  static const String _apiKey =
      '';
  static const String _baseUrl = '';
  static const String _model = 'gpt-4o-mini';

  /// Make a request to OpenAI API
  static Future<String> makeChatRequest(String systemPrompt, String userPrompt) async {
    try {
      print('OpenAI API: Making request to $_baseUrl');
      print('OpenAI API: Model: $_model');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('OpenAI API request timed out after 30 seconds');
        },
      );

      print('OpenAI API: Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['choices'] != null && 
              data['choices'].isNotEmpty && 
              data['choices'][0]['message'] != null) {
            final content = data['choices'][0]['message']['content'] as String;
            print('OpenAI API: Successfully received response');
            return content;
          } else {
            print('OpenAI API: Invalid response structure: ${response.body}');
            throw Exception('Invalid response structure from OpenAI API');
          }
        } catch (e) {
          print('OpenAI API: JSON decode error: $e');
          print('OpenAI API: Response body: ${response.body}');
          throw Exception('Failed to parse OpenAI API response: $e');
        }
      } else {
        final errorBody = response.body;
        print('OpenAI API: Error response (${response.statusCode}): $errorBody');
        
        // Try to parse error message from response
        try {
          final errorData = jsonDecode(errorBody);
          final error = errorData['error'];
          final errorMessage = error?['message'] ?? errorBody;
          final errorCode = error?['code'] ?? '';
          final errorType = error?['type'] ?? '';
          
          // Create specific exception types for better error handling
          if (response.statusCode == 429) {
            if (errorCode == 'insufficient_quota' || errorType == 'insufficient_quota') {
              throw QuotaExceededException('OpenAI API quota exceeded. Please check your billing and plan details.');
            } else {
              throw RateLimitException('OpenAI API rate limit exceeded. Please try again later.');
            }
          } else if (response.statusCode == 401) {
            throw AuthenticationException('OpenAI API authentication failed. Please check your API key.');
          } else {
            throw OpenAIException('OpenAI API error (${response.statusCode}): $errorMessage', errorCode: errorCode);
          }
        } catch (e) {
          // If it's already a custom exception, rethrow it
          if (e is QuotaExceededException || e is RateLimitException || 
              e is AuthenticationException || e is OpenAIException) {
            rethrow;
          }
          // Otherwise, create a generic exception
          throw Exception('OpenAI API error: ${response.statusCode} - $errorBody');
        }
      }
    } on Exception catch (e) {
      print('OpenAI API: Exception caught: $e');
      rethrow;
    } catch (e) {
      print('OpenAI API: Unexpected error: $e');
      throw Exception('Failed to call OpenAI API: $e');
    }
  }

  /// Generate health score based on user profile
  static Future<Map<String, dynamic>> generateHealthScore(
    Map<String, dynamic> userProfile,
  ) async {
    final systemPrompt = '''You are a health and fitness expert. Analyze the user's profile data and calculate a health score from 0-100.
Return ONLY a valid JSON object with this exact structure:
{
  "score": <number between 0-100>,
  "breakdown": {
    "fitness": <number 0-100>,
    "nutrition": <number 0-100>,
    "recovery": <number 0-100>,
    "lifestyle": <number 0-100>
  },
  "recommendations": ["<recommendation 1>", "<recommendation 2>", "<recommendation 3>"]
}''';

    final userPrompt = '''Analyze this user profile and calculate their health score:
${jsonEncode(userProfile)}

Consider:
- Exercise frequency and activity level
- Sleep quality and duration
- Stress levels
- Medical conditions
- Physical state
- Age, weight, height, BMI
- Goals (fat loss, muscle gain, rehab)

Return the JSON response only, no additional text.''';

    try {
      final response = await makeChatRequest(systemPrompt, userPrompt);
      
      print('OpenAI Health Score: Raw response: $response');
      
      // Try to extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        try {
          final jsonString = jsonMatch.group(0)!;
          final parsed = jsonDecode(jsonString) as Map<String, dynamic>;
          
          // Validate structure
          if (parsed['score'] == null) {
            throw Exception('Health score response missing "score" field');
          }
          
          print('OpenAI Health Score: Successfully parsed: $parsed');
          return parsed;
        } catch (e) {
          print('OpenAI Health Score: JSON parse error: $e');
          print('OpenAI Health Score: JSON string: ${jsonMatch.group(0)}');
          throw Exception('Failed to parse health score JSON: $e');
        }
      }
      
      print('OpenAI Health Score: No JSON found in response');
      throw Exception('Invalid JSON response from OpenAI. Response: $response');
    } catch (e) {
      print('OpenAI Health Score: Error generating health score: $e');
      rethrow;
    }
  }

  /// Generate workout plan based on user profile
  static Future<Map<String, dynamic>> generateWorkoutPlan(
    Map<String, dynamic> userProfile,
    Map<String, dynamic> preferences,
  ) async {
    final systemPrompt = '''You are a professional fitness trainer. Create a personalized workout plan based on user profile and preferences.
Return ONLY a valid JSON object with this exact structure:
{
  "planName": "<plan name>",
  "difficulty": "<beginner/intermediate/advanced>",
  "duration": <number in minutes>,
  "weeklySchedule": [
    {
      "day": "<Monday/Tuesday/etc>",
      "workoutType": "<type>",
      "exercises": [
        {
          "name": "<exercise name>",
          "sets": <number>,
          "reps": "<reps or duration>",
          "rest": "<rest time>",
          "instructions": "<brief instructions>"
        }
      ],
      "estimatedCalories": <number>
    }
  ],
  "tips": ["<tip 1>", "<tip 2>", "<tip 3>"]
}''';

    final userPrompt = '''Create a personalized workout plan for this user:
Profile: ${jsonEncode(userProfile)}
Preferences: ${jsonEncode(preferences)}

Consider their goal, fitness level, available days, preferred time, medical conditions, and physical limitations.
Return the JSON response only, no additional text.''';

    final response = await makeChatRequest(systemPrompt, userPrompt);
    
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (jsonMatch != null) {
      return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
    }
    
    throw Exception('Invalid JSON response from OpenAI');
  }

  /// Generate diet plan based on user profile
  static Future<Map<String, dynamic>> generateDietPlan(
    Map<String, dynamic> userProfile,
    Map<String, dynamic> preferences,
  ) async {
    final systemPrompt = '''You are a professional nutritionist. Create a personalized diet plan based on user profile and preferences.
Return ONLY a valid JSON object with this exact structure:
{
  "planName": "<plan name>",
  "dailyCalories": <number>,
  "macros": {
    "protein": <grams>,
    "carbs": <grams>,
    "fats": <grams>
  },
  "weeklyMealPlan": [
    {
      "day": "<Monday/Tuesday/etc>",
      "meals": [
        {
          "meal": "<Breakfast/Lunch/Dinner/Snack>",
          "name": "<meal name>",
          "calories": <number>,
          "ingredients": ["<ingredient 1>", "<ingredient 2>"],
          "instructions": "<brief cooking instructions>"
        }
      ]
    }
  ],
  "tips": ["<tip 1>", "<tip 2>", "<tip 3>"]
}''';

    final userPrompt = '''Create a personalized diet plan for this user:
Profile: ${jsonEncode(userProfile)}
Preferences: ${jsonEncode(preferences)}

Consider their goal, body metrics, activity level, dietary restrictions, and food preferences.
Return the JSON response only, no additional text.''';

    final response = await makeChatRequest(systemPrompt, userPrompt);
    
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
    if (jsonMatch != null) {
      return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
    }
    
    throw Exception('Invalid JSON response from OpenAI');
  }
}
