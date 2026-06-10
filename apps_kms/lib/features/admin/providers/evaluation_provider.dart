import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/evaluation_model.dart';
import '../../auth/providers/auth_provider.dart';

class EvaluationState {
  final bool isLoading;
  final List<EvaluationModel> evaluations;
  final String? errorMessage;
  EvaluationState({this.isLoading = false, this.evaluations = const [], this.errorMessage});
  EvaluationState copyWith({bool? isLoading, List<EvaluationModel>? evaluations, String? errorMessage}) =>
      EvaluationState(isLoading: isLoading ?? this.isLoading, evaluations: evaluations ?? this.evaluations, errorMessage: errorMessage);
}

class EvaluationNotifier extends StateNotifier<EvaluationState> {
  final ApiService _api;
  EvaluationNotifier(this._api) : super(EvaluationState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('evaluations');
      state = state.copyWith(isLoading: false, evaluations: (response as List).map((e) => EvaluationModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('evaluations', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('evaluations/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('evaluations/$id'); state = state.copyWith(evaluations: state.evaluations.where((e) => e.id != id).toList()); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final evaluationProvider = StateNotifierProvider<EvaluationNotifier, EvaluationState>((ref) =>
    EvaluationNotifier(ref.watch(apiServiceProvider)));
