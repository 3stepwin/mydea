import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String? apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  final String model = 'gemini-pro';

  GeminiService({this.apiKey}) {
    // If no API key provided, try to get from environment variables
    if (apiKey == null) {
      final envApiKey = const String.fromEnvironment('GEMINI_API_KEY');
      if (envApiKey.isEmpty) {
        debugPrint('Warning: GEMINI_API_KEY not found in environment variables. Analysis features will not work.');
      }
    }
  }

  Future<Map<String, dynamic>> analyzeIdea(String ideaText) async {
    try {
      final response = await _generateContent(
        "Analyze this product idea and provide detailed feedback. Format the response as a JSON with the following keys: 'rating' (1-10), 'strengths' (array), 'weaknesses' (array), 'opportunities' (array), 'risks' (array), 'marketPotential' (text), 'nextSteps' (array), and 'summary' (text). Idea: $ideaText"
      );
      
      // Extract just the JSON part from the response
      final jsonStr = _extractJsonFromText(response);
      if (jsonStr.isEmpty) {
        return _getErrorResponse('Could not parse analysis response');
      }
      
      return json.decode(jsonStr);
    } catch (e) {
      debugPrint('Error analyzing idea: $e');
      return _getErrorResponse('Error analyzing idea: $e');
    }
  }
  
  Future<Map<String, dynamic>> generateRoadmap(String ideaText) async {
    try {
      final response = await _generateContent(
        "Generate an MVP development roadmap for this product idea. Format the response as a JSON with the following keys: 'phases' (array of objects with 'name', 'description', 'duration', 'tasks' array), 'totalEstimatedTime', 'keyMilestones' (array), 'technicalRequirements' (array), and 'marketingStrategy' (text). Idea: $ideaText"
      );
      
      // Extract just the JSON part from the response
      final jsonStr = _extractJsonFromText(response);
      if (jsonStr.isEmpty) {
        return _getErrorResponse('Could not parse roadmap response');
      }
      
      return json.decode(jsonStr);
    } catch (e) {
      debugPrint('Error generating roadmap: $e');
      return _getErrorResponse('Error generating roadmap: $e');
    }
  }
  
  Future<String> _generateContent(String prompt) async {
    final key = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');
    if (key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found. Please provide a valid API key.');
    }
    
    final url = '$baseUrl/$model:generateContent?key=$key';
    
    final payload = {
      "contents": [
        {
          "parts": [
            {
              "text": prompt
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.7,
        "topK": 40,
        "topP": 0.95,
        "maxOutputTokens": 2048,
      }
    };
    
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['candidates'] != null && 
          data['candidates'].isNotEmpty && 
          data['candidates'][0]['content'] != null && 
          data['candidates'][0]['content']['parts'] != null && 
          data['candidates'][0]['content']['parts'].isNotEmpty) {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to generate content: ${response.statusCode}\n${response.body}');
    }
  }
  
  String _extractJsonFromText(String text) {
    // Try to find a JSON pattern in the text
    RegExp jsonRegex = RegExp(r'\{(?:[^{}]|(?:\{(?:[^{}]|(?:\{(?:[^{}]|(?:\{[^{}]*\}))*\}))*\}))*\}');
    final match = jsonRegex.firstMatch(text);
    if (match != null) {
      final jsonStr = match.group(0) ?? '';
      
      // Verify it's valid JSON
      try {
        json.decode(jsonStr);
        return jsonStr;
      } catch (_) {
        // Not valid JSON, continue to fallback
      }
    }
    
    // Fallback: Look for the first { and the last }
    int startIndex = text.indexOf('{');
    int endIndex = text.lastIndexOf('}');
    
    if (startIndex >= 0 && endIndex > startIndex) {
      final jsonStr = text.substring(startIndex, endIndex + 1);
      try {
        json.decode(jsonStr);
        return jsonStr;
      } catch (_) {
        // Still not valid JSON
        return '';
      }
    }
    
    return '';
  }
  
  Map<String, dynamic> _getErrorResponse(String message) {
    return {
      'error': true,
      'message': message,
      'rating': 0,
      'strengths': [],
      'weaknesses': [],
      'opportunities': [],
      'risks': [],
      'marketPotential': 'Could not analyze',
      'nextSteps': [],
      'summary': 'Error occurred during analysis'
    };
  }
}