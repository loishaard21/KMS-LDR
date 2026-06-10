class GalleryModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String? date;
  final String? authorId;
  final Map<String, dynamic>? author;

  GalleryModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    this.date,
    this.authorId,
    this.author,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      date: json['date'] as String?,
      authorId: json['authorId'] as String?,
      author: json['author'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date,
      'authorId': authorId,
    };
  }
}
