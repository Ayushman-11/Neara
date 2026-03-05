import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'gemini_service.dart';

/// Get OpenRouter API key from environment variables
String get kOpenRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  // Using Claude 3.5 Sonnet for better reasoning and understanding
  static const String _model = 'anthropic/claude-3.5-sonnet';

  OpenRouterService();

  /// Emergency interpretation using OpenRouter AI
  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
    double? lat,
    double? lng,
  }) async {
    final prompt = _buildEmergencyPrompt(transcript, lat, lng);

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

      final serviceStr = map['service']?.toString().toLowerCase() ?? '';
      final service = switch (serviceStr) {
        'plumber' => ServiceCategory.plumber,
        'carpenter' => ServiceCategory.carpenter,
        'electrician' => ServiceCategory.electrician,
        'painter' => ServiceCategory.painter,
        'ac technician' || 'actechnician' => ServiceCategory.acTechnician,
        'appliance repair' ||
        'appliancerepair' => ServiceCategory.applianceRepair,
        'cleaner' => ServiceCategory.cleaner,
        'pest control' || 'pestcontrol' => ServiceCategory.pestControl,
        'mechanic' => ServiceCategory.mechanic,
        'gardener' => ServiceCategory.gardener,
        _ => ServiceCategory.other,
      };

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

  /// Search filter interpretation using OpenRouter AI
  Future<SearchFilters> interpretSearch(String query) async {
    final prompt = _buildSearchPrompt(query);

    try {
      final response = await _makeRequest(
        model: _model,
        messages: [
          {'role': 'user', 'content': prompt},
        ],
        temperature: 0.1,
        maxTokens: 200,
      ).timeout(const Duration(seconds: 10));

      final text = _extractContent(response);
      final map = _safeDecodeJson(text);

      final serviceStr = map['service']?.toString().toLowerCase() ?? '';
      final service = switch (serviceStr) {
        'plumber' => ServiceCategory.plumber,
        'carpenter' => ServiceCategory.carpenter,
        'electrician' => ServiceCategory.electrician,
        'painter' => ServiceCategory.painter,
        'ac technician' || 'actechnician' => ServiceCategory.acTechnician,
        'appliance repair' ||
        'appliancerepair' => ServiceCategory.applianceRepair,
        'cleaner' => ServiceCategory.cleaner,
        'pest control' || 'pestcontrol' => ServiceCategory.pestControl,
        'mechanic' => ServiceCategory.mechanic,
        'gardener' => ServiceCategory.gardener,
        _ => null,
      };

      return SearchFilters(
        serviceCategory: service,
        radiusKm: (map['radiusKm'] is num)
            ? (map['radiusKm'] as num).toDouble()
            : 5,
        minRating: (map['minRating'] is num)
            ? (map['minRating'] as num).toDouble()
            : 4.0,
        verifiedOnly: map['verifiedOnly'] is bool
            ? map['verifiedOnly'] as bool
            : true,
        genderPreference: map['genderPreference']?.toString() ?? 'any',
      );
    } on TimeoutException {
      return const SearchFilters();
    } catch (e) {
      return const SearchFilters();
    }
  }

  String _buildEmergencyPrompt(String transcript, double? lat, double? lng) {
    final buffer = StringBuffer();
    buffer.writeln(
      'You are an AI service classifier for a home services app called Neara.',
    );
    buffer.writeln(
      'Analyze the user\'s problem and return the appropriate service category and details.',
    );
    buffer.writeln();
    buffer.writeln('User speech transcript: "$transcript"');

    if (lat != null && lng != null) {
      buffer.writeln('User GPS: $lat, $lng');
    }

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

  String _buildSearchPrompt(String query) {
    final buffer = StringBuffer();
    buffer.writeln(
      'You are an AI service classifier for a home services app called Neara.',
    );
    buffer.writeln('Convert the user query into structured search filters.');
    buffer.writeln();
    buffer.writeln('User query: "$query"');
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
    buffer.writeln('2. Only return the exact category name.');
    buffer.writeln();
    buffer.writeln('Respond ONLY with valid JSON in this exact format:');
    buffer.writeln('{');
    buffer.writeln(
      '  "service": "Plumber"|"Carpenter"|"Electrician"|"Painter"|"AC Technician"|"Appliance Repair"|"Cleaner"|"Pest Control"|"Mechanic"|"Gardener"|"Other"|null,',
    );
    buffer.writeln('  "radiusKm": number,');
    buffer.writeln('  "minRating": number,');
    buffer.writeln('  "verifiedOnly": boolean,');
    buffer.writeln('  "genderPreference": "any"|"female"|"male"');
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln(
      'Default values if not specified: radiusKm: 5, minRating: 4.0, verifiedOnly: true, genderPreference: "any"',
    );

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
      // Try to extract JSON from response
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
