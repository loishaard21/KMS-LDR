import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class OperatorState {
  final bool isLoading;
  final List<UserModel> operators;
  final String? errorMessage;

  OperatorState({
    this.isLoading = false,
    this.operators = const [],
    this.errorMessage,
  });

  OperatorState copyWith({
    bool? isLoading,
    List<UserModel>? operators,
    String? errorMessage,
  }) {
    return OperatorState(
      isLoading: isLoading ?? this.isLoading,
      operators: operators ?? this.operators,
      errorMessage: errorMessage,
    );
  }
}

class OperatorNotifier extends StateNotifier<OperatorState> {
  final Ref _ref;

  OperatorNotifier(this._ref) : super(OperatorState()) {
    loadOperators();
  }

  Future<void> loadOperators() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final response = await api.get('users') as List;
      final list = response.map((u) => UserModel.fromJson(u)).toList();
      state = OperatorState(operators: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> addOperator(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final api = _ref.read(apiServiceProvider);
      await api.post('users', data);
      await loadOperators();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> editOperator(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final api = _ref.read(apiServiceProvider);
      await api.put('users/$id', data);
      await loadOperators();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> removeOperator(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final api = _ref.read(apiServiceProvider);
      await api.delete('users/$id');
      await loadOperators();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final operatorProvider = StateNotifierProvider<OperatorNotifier, OperatorState>((ref) {
  return OperatorNotifier(ref);
});
