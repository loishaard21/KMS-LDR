class EvaluationModel {
  final String id;
  final String activity;
  final String category;
  final String period;
  final double score;
  final String status;

  EvaluationModel({
    required this.id,
    required this.activity,
    required this.category,
    required this.period,
    this.score = 0,
    this.status = 'Dalam Proses',
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id'] as String? ?? '',
      activity: json['activity'] as String? ?? '',
      category: json['category'] as String? ?? '',
      period: json['period'] as String? ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'Dalam Proses',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity': activity,
      'category': category,
      'period': period,
      'score': score,
      'status': status,
    };
  }
}
