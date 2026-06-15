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
      state = state.copyWith(
        isLoading: false,
        participants: (response as List).map((e) => ParticipantModel.fromJson(e)).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      await _api.put('participants/$id', data);
      // Update local state optimistically
      state = state.copyWith(
        participants: state.participants.map((p) {
          if (p.id == id) {
            return ParticipantModel(
              id: p.id,
              name: p.name,
              nip: p.nip,
              agency: p.agency,
              seminarTitle: p.seminarTitle,
              date: p.date,
              status: data['status'] as String? ?? p.status,
              seminarId: p.seminarId,
            );
          }
          return p;
        }).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

final participantProvider = StateNotifierProvider<ParticipantNotifier, ParticipantState>((ref) =>
    ParticipantNotifier(ref.watch(apiServiceProvider)));
