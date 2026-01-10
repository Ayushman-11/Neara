import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Get Gemini API key from environment variables
String get kGeminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

enum EmergencyUrgency { low, medium, high }

enum ServiceCategory { mechanic, plumber, electrician, maid, other }

class EmergencyInterpretation {
  final String issueSummary;
  final EmergencyUrgency urgency;
  final String locationHint;
  final ServiceCategory serviceCategory;

  EmergencyInterpretation({
    required this.issueSummary,
    required this.urgency,
    required this.locationHint,
    required this.serviceCategory,
  });
}

class SearchFilters {
  final ServiceCategory? serviceCategory;
  final double radiusKm;
  final double minRating;
  final bool verifiedOnly;
  final String genderPreference; // any / female / male

  const SearchFilters({
    this.serviceCategory,
    this.radiusKm = 50,
    this.minRating = 3.5,
    this.verifiedOnly = false,
    this.genderPreference = 'any',
  });

  SearchFilters copyWith({
    ServiceCategory? serviceCategory,
    double? radiusKm,
    double? minRating,
    bool? verifiedOnly,
    String? genderPreference,
  }) {
    return SearchFilters(
      serviceCategory: serviceCategory ?? this.serviceCategory,
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      genderPreference: genderPreference ?? this.genderPreference,
    );
  }
}

class GeminiService {
  GeminiService()
    // Use gemini-2.5-flash which is the latest fast model
    : _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: kGeminiApiKey,
      );

  final GenerativeModel _model;

  /// Lists all available models for debugging
  Future<void> listAvailableModels() async {
    try {
      final response = await _model.generateContent([
        Content.text('List available models'),
      ]);
      print('Available models check: ${response.text}');
    } catch (e) {
      print('Error checking models: $e');
    }
  }

  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
    double? lat,
    double? lng,
  }) async {
    final prompt = StringBuffer()
      ..writeln(
        'You are an assistant for an Indian on-demand worker app for emergencies.',
      )
      ..writeln('User speech transcript: "$transcript"')
      ..writeln(
        lat != null && lng != null
            ? 'User GPS coordinates (lat,lng): $lat,$lng. Use these only to refine the locationHint (e.g., nearby area name) and you may also include the coordinates.'
            : 'No GPS coordinates available for this request.',
      )
      ..writeln(
        'If location hints like NH4 or areas are present, keep them as text.',
      )
      ..writeln('Respond ONLY as compact JSON with keys:')
      ..writeln(
        '{"issueSummary": string, "urgency": "low"|"medium"|"high", "locationHint": string, "serviceCategory": "mechanic"|"plumber"|"electrician"|"maid"|"other"}',
      );

    final response = await _model.generateContent([
      Content.text(prompt.toString()),
    ]);
    final text = response.text ?? '{}';
    final map = _safeDecodeJson(text);

    final urgency = switch (map['urgency']) {
      'high' => EmergencyUrgency.high,
      'medium' => EmergencyUrgency.medium,
      'low' => EmergencyUrgency.low,
      _ => EmergencyUrgency.medium,
    };

    final service = switch (map['serviceCategory']) {
      'mechanic' => ServiceCategory.mechanic,
      'plumber' => ServiceCategory.plumber,
      'electrician' => ServiceCategory.electrician,
      'maid' => ServiceCategory.maid,
      _ => ServiceCategory.other,
    };

    return EmergencyInterpretation(
      issueSummary: map['issueSummary']?.toString() ?? transcript,
      urgency: urgency,
      locationHint: map['locationHint']?.toString() ?? '',
      serviceCategory: service,
    );
  }

  Future<SearchFilters> interpretSearch(String query) async {
    final prompt = StringBuffer()
      ..writeln(
        'You help map natural language to filters for an Indian local worker app.',
      )
      ..writeln('User query: "$query"')
      ..writeln('Respond ONLY as compact JSON with keys:')
      ..writeln(
        '{"serviceCategory": "mechanic"|"plumber"|"electrician"|"maid"|"other"|null,',
      )
      ..writeln(
        ' "radiusKm": number, "minRating": number, "verifiedOnly": boolean,',
      )
      ..writeln(' "genderPreference": "any"|"female"|"male" }');

    final response = await _model.generateContent([
      Content.text(prompt.toString()),
    ]);
    final text = response.text ?? '{}';
    final map = _safeDecodeJson(text);

    ServiceCategory? service;
    switch (map['serviceCategory']) {
      case 'mechanic':
        service = ServiceCategory.mechanic;
        break;
      case 'plumber':
        service = ServiceCategory.plumber;
        break;
      case 'electrician':
        service = ServiceCategory.electrician;
        break;
      case 'maid':
        service = ServiceCategory.maid;
        break;
      default:
        service = null;
    }

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
  }
}

Map<String, dynamic> _safeDecodeJson(String raw) {
  try {
    // Gemini sometimes wraps JSON in code fences or extra text; try to extract the JSON substring.
    final jsonStart = raw.indexOf('{');
    final jsonEnd = raw.lastIndexOf('}');
    if (jsonStart == -1 || jsonEnd == -1) return {};
    final json = raw.substring(jsonStart, jsonEnd + 1);
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  } catch (_) {
    return {};
  }
}
