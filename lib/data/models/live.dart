class Live {
  int? id;
  int? teacherId;
  int? subjectId;
  String? date;
  String? from;
  String? to;
  String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isNow;
  List<dynamic>? files;
  bool? isActive;

  Live(
      {this.id,
      this.teacherId,
      this.subjectId,
      this.date,
      this.from,
      this.to,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.isNow,
      this.files,
      this.isActive});

  @override
  String toString() {
    return 'Live(id: $id, teacherId: $teacherId, subjectId: $subjectId, date: $date, from: $from, to: $to, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, isNow: $isNow, files: $files, isActive: $isActive)';
  }

  factory Live.fromJson(Map<String, dynamic> json) => Live(
        id: json['id'] as int?,
        teacherId: json['teacher_id'] as int?,
        subjectId: json['subject_id'] as int?,
        date: json['date'] as String?,
        from: json['from'] as String?,
        to: json['to'] as String?,
        description: json['description'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
        isNow: json['is_now'] as bool?,
        files: json['files'] as List<dynamic>?,
        isActive: _parseIsActive(json['is_active']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'teacher_id': teacherId,
        'subject_id': subjectId,
        'date': date,
        'from': from,
        'to': to,
        'description': description,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'is_now': isNow,
        'files': files,
        'is_active': isActive
      };

  static bool _parseIsActive(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is int) {
      return value == 1; // 1 is active, 0 is inactive
    } else if (value is String) {
      return value == '1' ||
          value.toLowerCase() == 'true'; // Handle string cases
    }
    return false; // Default to inactive for unrecognized cases
  }
}
