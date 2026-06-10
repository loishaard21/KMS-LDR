class ParticipantModel {
  final String id;
  final String name;
  final String? nip;
  final String? agency;
  final String? seminarTitle;
  final String? date;
  final String status;
  final String? seminarId;

  ParticipantModel({
    required this.id,
    required this.name,
    this.nip,
    this.agency,
    this.seminarTitle,
    this.date,
    this.status = 'Confirmed',
    this.seminarId,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nip: json['nip'] as String?,
      agency: json['agency'] as String?,
      seminarTitle: json['seminarTitle'] as String?,
      date: json['date'] as String?,
      status: json['status'] as String? ?? 'Confirmed',
      seminarId: json['seminarId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nip': nip,
      'agency': agency,
      'seminarTitle': seminarTitle,
      'date': date,
      'status': status,
      'seminarId': seminarId,
    };
  }
}
