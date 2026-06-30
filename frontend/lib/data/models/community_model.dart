import '../../domain/entities/community.dart';

class CommunityPostModel extends CommunityPost {
  const CommunityPostModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.content,
    super.imageUrl,
    required super.createdAt,
    super.likes,
    super.comments,
    super.isLiked,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['name'] as String? ?? '',
      userId: json['author'] as String? ?? '',
      userName: json['author_name'] as String? ?? '',
      userAvatarUrl: json['user_avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['image'] as String?,
      createdAt: json['creation'] != null
          ? DateTime.parse(json['creation'] as String)
          : DateTime.now(),
      likes: json['likes'] as int? ?? 0,
      comments: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'author': userId,
    'content': content,
    'image': imageUrl,
  };
}

class CommunityGroupModel extends CommunityGroup {
  const CommunityGroupModel({
    required super.id,
    required super.name,
    super.description,
    super.memberCount,
    super.imageUrl,
    super.isJoined,
  });

  factory CommunityGroupModel.fromJson(Map<String, dynamic> json) {
    return CommunityGroupModel(
      id: json['name'] as String? ?? '',
      name: json['group_name'] as String? ?? '',
      description: json['description'] as String?,
      memberCount: json['members_count']?.toString() ?? '0',
      imageUrl: json['image_url'] as String?,
      isJoined: json['is_joined'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'group_name': name,
    'description': description,
  };
}

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.title,
    required super.description,
    super.durationDays,
    super.remainingDays,
    super.progress,
    super.participants,
    super.isJoined,
    super.category,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationDays: json['duration_days'] as int? ?? 14,
      remainingDays: json['remaining_days'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      participants: json['participants'] as int? ?? 0,
      isJoined: json['is_joined'] as bool? ?? false,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'duration_days': durationDays,
  };
}

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['name'] as String? ?? '',
      userId: json['author'] as String? ?? '',
      userName: json['author_name'] as String? ?? '',
      userAvatarUrl: json['user_avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['creation'] != null
          ? DateTime.parse(json['creation'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'author': userId,
    'content': content,
  };
}
