import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/seminar_model.dart';
import '../../../shared/models/participant_model.dart';
import '../../../shared/models/article_model.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardState {
  final bool isLoading;
  final int totalSeminars;
  final int totalParticipants;
  final int certificatesCount;
  final int totalArticles;
  final List<SeminarModel> recentSeminars;
  final Map<String, double> categoryDistribution;
  final String? errorMessage;

  DashboardState({
    this.isLoading = false,
    this.totalSeminars = 0,
    this.totalParticipants = 0,
    this.certificatesCount = 0,
    this.totalArticles = 0,
    this.recentSeminars = const [],
    this.categoryDistribution = const {},
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    int? totalSeminars,
    int? totalParticipants,
    int? certificatesCount,
    int? totalArticles,
    List<SeminarModel>? recentSeminars,
    Map<String, double>? categoryDistribution,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      totalSeminars: totalSeminars ?? this.totalSeminars,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      certificatesCount: certificatesCount ?? this.certificatesCount,
      totalArticles: totalArticles ?? this.totalArticles,
      recentSeminars: recentSeminars ?? this.recentSeminars,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      errorMessage: errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;

  DashboardNotifier(this._ref) : super(DashboardState()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    final api = _ref.read(apiServiceProvider);
    final user = _ref.read(authProvider).user;

    if (user == null) {
      state = state.copyWith(isLoading: false, errorMessage: 'User session not found.');
      return;
    }

    try {
      final semsJson = await api.get('seminars') as List;
      final partsJson = await api.get('participants') as List;
      
      final seminars = semsJson.map((s) => SeminarModel.fromJson(s)).toList();
      final participants = partsJson.map((p) => ParticipantModel.fromJson(p)).toList();

      if (user.role == 'superadmin') {
        // Superadmin stats: load articles too
        final artsJson = await api.get('articles') as List;
        final articles = artsJson.map((a) => ArticleModel.fromJson(a)).toList();

        // Calculate certificates (seminar has certificateUrl and it is not empty)
        final certsCount = seminars.where((s) => s.certificateUrl != null && s.certificateUrl!.isNotEmpty).length;

        // Calculate distribution
        final Map<String, int> catCounts = {};
        for (var s in seminars) {
          if (s.category.isNotEmpty) {
            catCounts[s.category] = (catCounts[s.category] ?? 0) + 1;
          }
        }
        final Map<String, double> distribution = {};
        final totalCats = catCounts.values.fold(0, (sum, val) => sum + val);
        if (totalCats > 0) {
          catCounts.forEach((key, val) {
            distribution[key] = (val / totalCats) * 100;
          });
        }

        state = DashboardState(
          isLoading: false,
          totalSeminars: seminars.length,
          totalParticipants: participants.length,
          certificatesCount: certsCount,
          totalArticles: articles.length,
          recentSeminars: seminars,
          categoryDistribution: distribution,
        );
      } else {
        // Operator stats: filter by authorId
        final operatorSeminars = seminars.where((s) => s.authorId == user.id).toList();
        final opSemIds = operatorSeminars.map((s) => s.id).toSet();
        
        final operatorParticipants = participants.where((p) => opSemIds.contains(p.seminarId)).toList();
        final certsCount = operatorParticipants.where((p) => p.status.toLowerCase() == 'certificate issued' || p.status.toLowerCase() == 'attended').length;

        state = DashboardState(
          isLoading: false,
          totalSeminars: operatorSeminars.length,
          totalParticipants: operatorParticipants.length,
          certificatesCount: certsCount,
          recentSeminars: operatorSeminars,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> deleteSeminarItem(String id) async {
    final api = _ref.read(apiServiceProvider);
    try {
      await api.delete('seminars/$id');
      loadDashboard();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
