import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/guide_model.dart';
import '../../auth/providers/auth_provider.dart';

class GuideState {
  final bool isLoading;
  final List<GuideModel> guides;
  final String? errorMessage;
  GuideState({this.isLoading = false, this.guides = const [], this.errorMessage});
  GuideState copyWith({bool? isLoading, List<GuideModel>? guides, String? errorMessage}) =>
      GuideState(isLoading: isLoading ?? this.isLoading, guides: guides ?? this.guides, errorMessage: errorMessage);
}

class GuideNotifier extends StateNotifier<GuideState> {
  final ApiService _api;
  GuideNotifier(this._api) : super(GuideState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('guides');
      state = state.copyWith(isLoading: false, guides: (response as List).map((e) => GuideModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('guides', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('guides/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('guides/$id'); state = state.copyWith(guides: state.guides.where((g) => g.id != id).toList()); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final guideProvider = StateNotifierProvider<GuideNotifier, GuideState>((ref) =>
    GuideNotifier(ref.watch(apiServiceProvider)));
