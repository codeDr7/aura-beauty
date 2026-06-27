import 'package:equatable/equatable.dart';

class CommunityPost extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}';
  }

  @override
  List<Object?> get props => [
    id, userId, userName, userAvatarUrl, content, imageUrl,
    createdAt, likes, comments, isLiked,
  ];
}

class CommunityGroup extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String memberCount;
  final String? imageUrl;
  final bool isJoined;

  const CommunityGroup({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = '0',
    this.imageUrl,
    this.isJoined = false,
  });

  @override
  List<Object?> get props => [id, name, description, memberCount, imageUrl, isJoined];
}

class Challenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final int remainingDays;
  final double progress;
  final int participants;
  final bool isJoined;
  final String? category;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.durationDays = 14,
    this.remainingDays = 0,
    this.progress = 0.0,
    this.participants = 0,
    this.isJoined = false,
    this.category,
  });

  @override
  List<Object?> get props => [
    id, title, description, durationDays, remainingDays,
    progress, participants, isJoined, category,
  ];
}

class Comment extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, userName, userAvatarUrl, content, createdAt];
}
