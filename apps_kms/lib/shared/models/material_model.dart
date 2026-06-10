class MaterialModel {
  final String id;
  final String title;
  final String? description;
  final String icon;
  final String type;
  final String size;
  final String url;

  MaterialModel({
    required this.id,
    required this.title,
    this.description,
    this.icon = '📘',
    this.type = 'PDF',
    this.size = '1.0 MB',
    this.url = '#',
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? '📘',
      type: json['type'] as String? ?? 'PDF',
      size: json['size'] as String? ?? '1.0 MB',
      url: json['url'] as String? ?? '#',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'type': type,
      'size': size,
      'url': url,
    };
  }
}
