class GuideModel {
  final String id;
  final String title;
  final String key;
  final String? content;
  final int order;
  final String? authorId;
  final Map<String, dynamic>? author;

  GuideModel({
    required this.id,
    required this.title,
    required this.key,
    this.content,
    this.order = 0,
    this.authorId,
    this.author,
  });

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      key: json['key'] as String? ?? '',
      content: json['content'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      authorId: json['authorId'] as String?,
      author: json['author'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'key': key,
      'content': content,
      'order': order,
      'authorId': authorId,
    };
  }
}
