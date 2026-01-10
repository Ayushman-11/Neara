import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gemini_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final emergencyInterpretationProvider =
    StateNotifierProvider<
      EmergencyController,
      AsyncValue<EmergencyInterpretation?>
    >((ref) => EmergencyController(ref));

class EmergencyController
    extends StateNotifier<AsyncValue<EmergencyInterpretation?>> {
  EmergencyController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> interpret(String transcript) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ref
          .read(geminiServiceProvider)
          .interpretEmergency(transcript: transcript);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersController, SearchFilters>((ref) {
      return SearchFiltersController(ref);
    });

class SearchFiltersController extends StateNotifier<SearchFilters> {
  SearchFiltersController(this._ref) : super(const SearchFilters());

  final Ref _ref;

  Future<void> fromQuery(String query) async {
    try {
      final aiFilters = await _ref
          .read(geminiServiceProvider)
          .interpretSearch(query);
      state = aiFilters;
    } catch (_) {
      // Keep existing filters on failure.
    }
  }

  void update(SearchFilters filters) => state = filters;
}
