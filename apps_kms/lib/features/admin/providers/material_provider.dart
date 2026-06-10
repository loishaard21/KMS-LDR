import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/material_model.dart';
import '../../auth/providers/auth_provider.dart';

class MaterialState {
  final bool isLoading;
  final List<MaterialModel> materials;
  final String? errorMessage;
  MaterialState({this.isLoading = false, this.materials = const [], this.errorMessage});
  MaterialState copyWith({bool? isLoading, List<MaterialModel>? materials, String? errorMessage}) =>
      MaterialState(isLoading: isLoading ?? this.isLoading, materials: materials ?? this.materials, errorMessage: errorMessage);
}

class MaterialNotifier extends StateNotifier<MaterialState> {
  final ApiService _api;
  MaterialNotifier(this._api) : super(MaterialState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('materials');
      state = state.copyWith(isLoading: false, materials: (response as List).map((e) => MaterialModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('materials', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('materials/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('materials/$id'); state = state.copyWith(materials: state.materials.where((m) => m.id != id).toList()); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final materialProvider = StateNotifierProvider<MaterialNotifier, MaterialState>((ref) =>
    MaterialNotifier(ref.watch(apiServiceProvider)));
