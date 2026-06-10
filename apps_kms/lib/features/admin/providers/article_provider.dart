import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../shared/models/article_model.dart';
import '../../auth/providers/auth_provider.dart';

class ArticleState {
  final bool isLoading;
  final List<ArticleModel> articles;
  final String? errorMessage;

  ArticleState({this.isLoading = false, this.articles = const [], this.errorMessage});

  ArticleState copyWith({bool? isLoading, List<ArticleModel>? articles, String? errorMessage}) {
    return ArticleState(
      isLoading: isLoading ?? this.isLoading,
      articles: articles ?? this.articles,
      errorMessage: errorMessage,
    );
  }
}

class ArticleNotifier extends StateNotifier<ArticleState> {
  final ApiService _api;
  ArticleNotifier(this._api) : super(ArticleState());

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _api.get('articles');
      final list = (response as List).map((e) => ArticleModel.fromJson(e)).toList();
      state = state.copyWith(isLoading: false, articles: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> create(Map<String, dynamic> data) async {
    try { await _api.post('articles', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try { await _api.put('articles/$id', data); return true; }
    catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }

  Future<bool> delete(String id) async {
    try {
      await _api.delete('articles/$id');
      state = state.copyWith(articles: state.articles.where((a) => a.id != id).toList());
      return true;
    } catch (e) { state = state.copyWith(errorMessage: e.toString()); return false; }
  }
}

final articleProvider = StateNotifierProvider<ArticleNotifier, ArticleState>((ref) {
  return ArticleNotifier(ref.watch(apiServiceProvider));
});
