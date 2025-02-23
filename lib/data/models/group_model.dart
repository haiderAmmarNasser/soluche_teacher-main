class GroupModel {
	int? id;
	String? name;
	int? lessonId;
	DateTime? createdAt;
	DateTime? updatedAt;

	GroupModel({
		this.id, 
		this.name, 
		this.lessonId, 
		this.createdAt, 
		this.updatedAt, 
	});

	@override
	String toString() {
		return 'GroupModel(id: $id, name: $name, lessonId: $lessonId, createdAt: $createdAt, updatedAt: $updatedAt)';
	}

	factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
				id: json['id'] as int?,
				name: json['name'] as String?,
				lessonId: json['lesson_id'] as int?,
				createdAt: json['created_at'] == null
						? null
						: DateTime.parse(json['created_at'] as String),
				updatedAt: json['updated_at'] == null
						? null
						: DateTime.parse(json['updated_at'] as String),
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'lesson_id': lessonId,
				'created_at': createdAt?.toIso8601String(),
				'updated_at': updatedAt?.toIso8601String(),
			};
}
