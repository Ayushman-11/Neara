import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Get OpenRouter API key from environment variables
String get kOpenRouterApiKey {
  try {
    return dotenv.env['OPENROUTER_API_KEY'] ?? '';
  } catch (_) {
    return '';
  }
}

enum EmergencyUrgency { low, medium, high }

class EmergencyInterpretation {
  final String issueSummary;
  final EmergencyUrgency urgency;
  final String locationHint;
  final String serviceCategory;

  EmergencyInterpretation({
    required this.issueSummary,
    required this.urgency,
    required this.locationHint,
    required this.serviceCategory,
  });
}

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  // Using Claude 3.5 Sonnet for better reasoning and understanding
  static const String _model = 'anthropic/claude-3.5-sonnet';

  OpenRouterService();

  /// Emergency interpretation using OpenRouter AI
  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
  }) async {
    final prompt = _buildEmergencyPrompt(transcript);

    try {
      final response = await _makeRequest(
        model: _model,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        temperature: 0.1,
        maxTokens: 300,
      ).timeout(const Duration(seconds: 15));

      final text = _extractContent(response);
      final map = _safeDecodeJson(text);

      final urgency = switch (map['urgency']) {
        'high' => EmergencyUrgency.high,
        'medium' => EmergencyUrgency.medium,
        'low' => EmergencyUrgency.low,
        _ => EmergencyUrgency.medium,
      };

      final service = map['service']?.toString() ?? 'Other';

      return EmergencyInterpretation(
        issueSummary: map['issueSummary']?.toString() ?? transcript,
        urgency: urgency,
        locationHint: map['locationHint']?.toString() ?? '',
        serviceCategory: service,
      );
    } on TimeoutException {
      throw Exception('AI response took too long. Please try again.');
    } catch (e) {
      throw Exception('Failed to process voice input: ${e.toString()}');
    }
  }

  String _buildEmergencyPrompt(String transcript) {
    final buffer = StringBuffer();
    buffer.writeln(
      'You are an AI service classifier for a home services app called Neara.',
    );
    buffer.writeln(
      'Analyze the user\'s problem and return the appropriate service category and details.',
    );
    buffer.writeln();
    buffer.writeln('User speech transcript: "$transcript"');
    buffer.writeln();
    buffer.writeln('Available service categories:');
    buffer.writeln('- Plumber');
    buffer.writeln('- Carpenter');
    buffer.writeln('- Electrician');
    buffer.writeln('- Painter');
    buffer.writeln('- AC Technician');
    buffer.writeln('- Appliance Repair');
    buffer.writeln('- Cleaner');
    buffer.writeln('- Pest Control');
    buffer.writeln('- Mechanic');
    buffer.writeln('- Gardener');
    buffer.writeln('- Other');
    buffer.writeln();
    buffer.writeln('Rules:');
    buffer.writeln('1. Only return ONE service category from the list.');
    buffer.writeln('2. Do NOT explain anything.');
    buffer.writeln('3. Only return the exact category name.');
    buffer.writeln();
    buffer.writeln('Return output in this JSON format only:');
    buffer.writeln('{');
    buffer.writeln('  "issueSummary": string,');
    buffer.writeln('  "urgency": "low"|"medium"|"high",');
    buffer.writeln('  "locationHint": string,');
    buffer.writeln(
      '  "service": "Plumber"|"Carpenter"|"Electrician"|"Painter"|"AC Technician"|"Appliance Repair"|"Cleaner"|"Pest Control"|"Mechanic"|"Gardener"|"Other"',
    );
    buffer.writeln('}');

    return buffer.toString();
  }

  Future<Map<String, dynamic>> _makeRequest({
    required String model,
    required List<Map<String, String>> messages,
    required double temperature,
    required int maxTokens,
  }) async {
    if (kOpenRouterApiKey.isEmpty) {
      throw Exception(
        'OpenRouter API key not found. Please set OPENROUTER_API_KEY in your .env file.',
      );
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $kOpenRouterApiKey',
        'HTTP-Referer': 'https://neara-app.com',
        'X-Title': 'Neara Emergency Services App',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'OpenRouter API error: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _extractContent(Map<String, dynamic> response) {
    try {
      final choices = response['choices'] as List;
      if (choices.isEmpty) return '{}';

      final choice = choices.first as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>;
      return message['content'] as String? ?? '{}';
    } catch (e) {
      debugPrint('Error extracting content from OpenRouter response: $e');
      return '{}';
    }
  }

  Map<String, dynamic> _safeDecodeJson(String raw) {
    try {
      final jsonStart = raw.indexOf('{');
      final jsonEnd = raw.lastIndexOf('}');
      if (jsonStart == -1 || jsonEnd == -1) return {};

      final json = raw.substring(jsonStart, jsonEnd + 1);
      return Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (e) {
      debugPrint('Error decoding JSON: $e');
      return {};
    }
  }
}
