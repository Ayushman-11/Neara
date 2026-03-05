import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Get Gemini API key from environment variables
String get kGeminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

enum EmergencyUrgency { low, medium, high }

enum ServiceCategory {
  plumber,
  carpenter,
  electrician,
  painter,
  acTechnician,
  applianceRepair,
  cleaner,
  pestControl,
  mechanic,
  gardener,
  other,
}

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
  final List<ServiceCategory> categories; // optional multi-select
  final double radiusKm;
  final double minRating;
  final bool verifiedOnly;
  final String genderPreference; // any / female / male

  const SearchFilters({
    this.serviceCategory,
    this.categories = const [],
    this.radiusKm = 50,
    this.minRating = 3.5,
    this.verifiedOnly = false,
    this.genderPreference = 'any',
  });

  SearchFilters copyWith({
    ServiceCategory? serviceCategory,
    List<ServiceCategory>? categories,
    double? radiusKm,
    double? minRating,
    bool? verifiedOnly,
    String? genderPreference,
  }) {
    return SearchFilters(
      serviceCategory: serviceCategory ?? this.serviceCategory,
      categories: categories ?? this.categories,
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      genderPreference: genderPreference ?? this.genderPreference,
    );
  }
}

class GeminiService {
  GeminiService()
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: kGeminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      );

  final GenerativeModel _model;

  /// Lists all available models for debugging
  Future<void> listAvailableModels() async {
    try {
      final response = await _model.generateContent([
        Content.text('List available models'),
      ]);
      debugPrint('Available models check: ${response.text}');
    } catch (e) {
      debugPrint('Error checking models: $e');
    }
  }

  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
    double? lat,
    double? lng,
  }) async {
    final prompt = StringBuffer()
      ..writeln(
        'You are an AI service classifier for a home services app called Neara.',
      )
      ..writeln(
        'Your job is to analyze the user\'s problem description and return the most appropriate service category and emergency details.',
      )
      ..writeln()
      ..writeln('Available service categories:')
      ..writeln('- Plumber')
      ..writeln('- Carpenter')
      ..writeln('- Electrician')
      ..writeln('- Painter')
      ..writeln('- AC Technician')
      ..writeln('- Appliance Repair')
      ..writeln('- Cleaner')
      ..writeln('- Pest Control')
      ..writeln('- Mechanic')
      ..writeln('- Gardener')
      ..writeln('- Other')
      ..writeln()
      ..writeln('Rules:')
      ..writeln('1. Only return ONE service category from the list.')
      ..writeln('2. Do NOT explain anything.')
      ..writeln('3. Do NOT return sentences.')
      ..writeln('4. Only return the exact category name.')
      ..writeln()
      ..writeln('User speech transcript: "$transcript"')
      ..writeln(
        lat != null && lng != null
            ? 'User GPS coordinates (lat,lng): $lat,$lng. Use these to refine locationHint.'
            : 'No GPS coordinates available.',
      )
      ..writeln()
      ..writeln('Return output in this JSON format only:')
      ..writeln('{')
      ..writeln('  "issueSummary": string,')
      ..writeln('  "urgency": "low"|"medium"|"high",')
      ..writeln('  "locationHint": string,')
      ..writeln(
        '  "service": "Plumber"|"Carpenter"|"Electrician"|"Painter"|"AC Technician"|"Appliance Repair"|"Cleaner"|"Pest Control"|"Mechanic"|"Gardener"|"Other"',
      )
      ..writeln('}');

    try {
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 10));
      final text = response.text ?? '{}';
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
      // Surface a clear, fast-failing error so the UI can show feedback
      throw Exception('AI response took too long. Please try again.');
    }
  }

  Future<SearchFilters> interpretSearch(String query) async {
    final prompt = StringBuffer()
      ..writeln(
        'You help map natural language to filters for an Indian local worker app.',
      )
      ..writeln('User query: "$query"')
      ..writeln()
      ..writeln('Available service categories:')
      ..writeln('- Plumber')
      ..writeln('- Carpenter')
      ..writeln('- Electrician')
      ..writeln('- Painter')
      ..writeln('- AC Technician')
      ..writeln('- Appliance Repair')
      ..writeln('- Cleaner')
      ..writeln('- Pest Control')
      ..writeln('- Mechanic')
      ..writeln('- Gardener')
      ..writeln('- Other')
      ..writeln()
      ..writeln('Rules for service classification:')
      ..writeln(
        '1. Only return ONE service category from the list if applicable, or null if unrelated.',
      )
      ..writeln('2. Do NOT explain anything.')
      ..writeln('3. Only return the exact category name.')
      ..writeln()
      ..writeln('Respond ONLY as compact JSON with keys:')
      ..writeln('{')
      ..writeln(
        '  "service": "Plumber"|"Carpenter"|"Electrician"|"Painter"|"AC Technician"|"Appliance Repair"|"Cleaner"|"Pest Control"|"Mechanic"|"Gardener"|"Other"|null,',
      )
      ..writeln('  "radiusKm": number,')
      ..writeln('  "minRating": number,')
      ..writeln('  "verifiedOnly": boolean,')
      ..writeln('  "genderPreference": "any"|"female"|"male"')
      ..writeln('}');

    try {
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 8));
      final text = response.text ?? '{}';
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
      // Fall back quickly to current/default filters if AI is slow
      return const SearchFilters();
    }
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
