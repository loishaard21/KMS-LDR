import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/regulation_model.dart';
import '../../auth/providers/auth_provider.dart';

class RegulationState {
  final bool isLoading;
  final List<RegulationModel> regulations;
  final String? errorMessage;
  RegulationState({this.isLoading = false, this.regulations = const [], this.errorMessage});
  RegulationState copyWith({bool? isLoading, List<RegulationModel>? regulations, String? errorMessage}) =>
      RegulationState(isLoading: isLoading ?? this.isLoading, regulations: regulations ?? this.regulations, errorMessage: errorMessage);
}

class RegulationNotifier extends StateNotifier<RegulationState> {
  final ApiService _api;
  RegulationNotifier(this._api) : super(RegulationState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('regulations');
      state = state.copyWith(isLoading: false, regulations: (response as List).map((e) => RegulationModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('regulations', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('regulations/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('regulations/$id'); state = state.copyWith(regulations: state.regulations.where((r) => r.id != id).toList()); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final regulationProvider = StateNotifierProvider<RegulationNotifier, RegulationState>((ref) =>
    RegulationNotifier(ref.watch(apiServiceProvider)));
