class ArticleModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String? excerpt;
  final String? cover;
  final String? content;
  final String? authorId;
  final Map<String, dynamic>? author;

  ArticleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.excerpt,
    this.cover,
    this.content,
    this.authorId,
    this.author,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      date: json['date'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      cover: json['cover'] as String?,
      content: json['content'] as String?,
      authorId: json['authorId'] as String?,
      author: json['author'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'date': date,
      'excerpt': excerpt,
      'cover': cover,
      'content': content,
      'authorId': authorId,
    };
  }
}
