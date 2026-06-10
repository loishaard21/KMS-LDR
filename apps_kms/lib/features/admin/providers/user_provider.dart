import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class UserState {
  final bool isLoading;
  final List<UserModel> users;
  final String? errorMessage;
  UserState({this.isLoading = false, this.users = const [], this.errorMessage});
  UserState copyWith({bool? isLoading, List<UserModel>? users, String? errorMessage}) =>
      UserState(isLoading: isLoading ?? this.isLoading, users: users ?? this.users, errorMessage: errorMessage);
}

class UserNotifier extends StateNotifier<UserState> {
  final ApiService _api;
  UserNotifier(this._api) : super(UserState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('users');
      state = state.copyWith(isLoading: false, users: (response as List).map((e) => UserModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('users', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('users/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try { await _api.delete('users/$id'); state = state.copyWith(users: state.users.where((u) => u.id != id).toList()); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) =>
    UserNotifier(ref.watch(apiServiceProvider)));
