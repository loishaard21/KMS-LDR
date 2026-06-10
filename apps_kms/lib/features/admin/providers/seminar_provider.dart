import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/seminar_model.dart';
import '../../auth/providers/auth_provider.dart';

class SeminarState {
  final bool isLoading;
  final List<SeminarModel> seminars;
  final String? errorMessage;

  SeminarState({this.isLoading = false, this.seminars = const [], this.errorMessage});

  SeminarState copyWith({bool? isLoading, List<SeminarModel>? seminars, String? errorMessage}) {
    return SeminarState(
      isLoading: isLoading ?? this.isLoading,
      seminars: seminars ?? this.seminars,
      errorMessage: errorMessage,
    );
  }
}

class SeminarNotifier extends StateNotifier<SeminarState> {
  final ApiService _api;

  SeminarNotifier(this._api) : super(SeminarState());

  Future<void> fetchAll({String? filterByAuthorId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('seminars');
      final list = (response as List).map((e) => SeminarModel.fromJson(e)).toList();
      final filtered = filterByAuthorId != null
          ? list.where((s) => s.authorId == filterByAuthorId).toList()
          : list;
      state = state.copyWith(isLoading: false, seminars: filtered);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try {
      await _api.post('seminars', data);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      await _api.put('seminars/$id', data);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _api.delete('seminars/$id');
      state = state.copyWith(
        seminars: state.seminars.where((s) => s.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final seminarProvider = StateNotifierProvider<SeminarNotifier, SeminarState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return SeminarNotifier(api);
});
