import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/participant_model.dart';
import '../../auth/providers/auth_provider.dart';

class ParticipantState {
  final bool isLoading;
  final List<ParticipantModel> participants;
  final String? errorMessage;
  ParticipantState({this.isLoading = false, this.participants = const [], this.errorMessage});
  ParticipantState copyWith({bool? isLoading, List<ParticipantModel>? participants, String? errorMessage}) =>
      ParticipantState(isLoading: isLoading ?? this.isLoading, participants: participants ?? this.participants, errorMessage: errorMessage);
}

class ParticipantNotifier extends StateNotifier<ParticipantState> {
  final ApiService _api;
  ParticipantNotifier(this._api) : super(ParticipantState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('participants');
      state = state.copyWith(isLoading: false, participants: (response as List).map((e) => ParticipantModel.fromJson(e)).toList());
    } catch (e) { state = state.copyWith(isLoading: false, errorMessage: e.toString()); }
  }
}

final participantProvider = StateNotifierProvider<ParticipantNotifier, ParticipantState>((ref) =>
    ParticipantNotifier(ref.watch(apiServiceProvider)));
