class SeminarModel {
  final String id;
  final String title;
  final String category;
  final String mode;
  final String status;
  final String speaker;
  final String speakerRole;
  final String? speakerAvatar;
  final String date;
  final String? time;
  final String location;
  final int capacity;
  final int registered;
  final String? description;
  final List<String> requirements;
  final String? organizer;
  final String? organizerLogo;
  final String? cover;
  final String? daftarType;
  final String? daftarUrl;
  final String? certificateUrl;
  final String? authorId;
  final Map<String, dynamic>? author;

  SeminarModel({
    required this.id,
    required this.title,
    required this.category,
    required this.mode,
    required this.status,
    required this.speaker,
    required this.speakerRole,
    this.speakerAvatar,
    required this.date,
    this.time,
    required this.location,
    required this.capacity,
    this.registered = 0,
    this.description,
    this.requirements = const [],
    this.organizer,
    this.organizerLogo,
    this.cover,
    this.daftarType,
    this.daftarUrl,
    this.certificateUrl,
    this.authorId,
    this.author,
  });

  factory SeminarModel.fromJson(Map<String, dynamic> json) {
    return SeminarModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      mode: json['mode'] as String? ?? 'Hybrid',
      status: json['status'] as String? ?? '',
      speaker: json['speaker'] as String? ?? '',
      speakerRole: json['speakerRole'] as String? ?? '',
      speakerAvatar: json['speakerAvatar'] as String?,
      date: json['date'] as String? ?? '',
      time: json['time'] as String?,
      location: json['location'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      registered: (json['registered'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      organizer: json['organizer'] as String?,
      organizerLogo: json['organizerLogo'] as String?,
      cover: json['cover'] as String?,
      daftarType: json['daftarType'] as String?,
      daftarUrl: json['daftarUrl'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      authorId: json['authorId'] as String?,
      author: json['author'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'mode': mode,
      'status': status,
      'speaker': speaker,
      'speakerRole': speakerRole,
      'speakerAvatar': speakerAvatar,
      'date': date,
      'time': time,
      'location': location,
      'capacity': capacity,
      'registered': registered,
      'description': description,
      'requirements': requirements,
      'organizer': organizer,
      'cover': cover,
      'daftarType': daftarType,
      'daftarUrl': daftarUrl,
      'certificateUrl': certificateUrl,
      'authorId': authorId,
    };
  }
}
