import 'user.dart';

class MessageModel {
	int? id;
	int? groupId;
	int? userId;
	String? message;
	DateTime? createdAt;
	DateTime? updatedAt;
	User? user;
  String? media;

	MessageModel({
		this.id, 
		this.groupId, 
		this.userId, 
		this.message, 
		this.createdAt, 
		this.updatedAt, 
		this.user, 
    this.media
	});

	@override
	String toString() {
		return 'MessageModel(id: $id, groupId: $groupId, userId: $userId, message: $message, createdAt: $createdAt, updatedAt: $updatedAt, user: $user)';
	}

	factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
				id: json['id'] as int?,
				groupId: json['group_id'] as int?,
				userId: json['user_id'] as int?,
				message: json['message'] as String?,
				createdAt: json['created_at'] == null
						? null
						: DateTime.parse(json['created_at'] as String),
				updatedAt: json['updated_at'] == null
						? null
						: DateTime.parse(json['updated_at'] as String),
				user: json['user'] == null
						? null
						: User.fromJson(json['user'] as Map<String, dynamic>),
        media: json['media'] as String?
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'group_id': groupId,
				'user_id': userId,
				'message': message,
				'created_at': createdAt?.toIso8601String(),
				'updated_at': updatedAt?.toIso8601String(),
				'user': user?.toJson(),
        'media': media
			};
}
