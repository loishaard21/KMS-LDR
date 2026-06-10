import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/gallery_model.dart';
import '../../auth/providers/auth_provider.dart';

class GalleryState {
  final bool isLoading;
  final List<GalleryModel> galleries;
  final String? errorMessage;
  GalleryState({this.isLoading = false, this.galleries = const [], this.errorMessage});
  GalleryState copyWith({bool? isLoading, List<GalleryModel>? galleries, String? errorMessage}) =>
      GalleryState(isLoading: isLoading ?? this.isLoading, galleries: galleries ?? this.galleries, errorMessage: errorMessage);
}

class GalleryNotifier extends StateNotifier<GalleryState> {
  final ApiService _api;
  GalleryNotifier(this._api) : super(GalleryState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('galleries');
      state = state.copyWith(isLoading: false, galleries: (response as List).map((e) => GalleryModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('galleries', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('galleries/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('galleries/$id'); state = state.copyWith(galleries: state.galleries.where((g) => g.id != id).toList()); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final galleryProvider = StateNotifierProvider<GalleryNotifier, GalleryState>((ref) =>
    GalleryNotifier(ref.watch(apiServiceProvider)));
