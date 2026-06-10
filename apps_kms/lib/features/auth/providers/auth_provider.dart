import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/session_manager.dart';
import '../../../shared/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? errorMessage;

  AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final SessionManager _sessionManager;

  AuthNotifier(this._apiService, this._sessionManager) : super(AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _sessionManager.getUser();
      if (user != null) {
        state = AuthState(user: user);
      } else {
        state = AuthState();
      }
    } catch (e) {
      state = AuthState(errorMessage: 'Gagal memuat sesi: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null && response['user'] != null) {
        final user = UserModel.fromJson(response['user']);
        await _sessionManager.saveUser(user);
        state = AuthState(user: user);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Format response backend tidak valid.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionManager.clearUser();
    state = AuthState();
  }

  void updateSession(String name, String email) {
    if (state.user != null) {
      final updatedUser = UserModel(
        id: state.user!.id,
        name: name,
        email: email,
        role: state.user!.role,
        status: state.user!.status,
        lastLogin: state.user!.lastLogin,
      );
      _sessionManager.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final sessionManagerProvider = Provider<SessionManager>((ref) => SessionManager());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final session = ref.watch(sessionManagerProvider);
  return AuthNotifier(api, session);
});
