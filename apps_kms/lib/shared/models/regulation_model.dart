class RegulationModel {
  final String id;
  final String group;
  final String title;
  final String url;

  RegulationModel({
    required this.id,
    required this.group,
    required this.title,
    this.url = '#',
  });

  factory RegulationModel.fromJson(Map<String, dynamic> json) {
    return RegulationModel(
      id: json['id'] as String? ?? '',
      group: json['group'] as String? ?? '',
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '#',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group': group,
      'title': title,
      'url': url,
    };
  }
}
