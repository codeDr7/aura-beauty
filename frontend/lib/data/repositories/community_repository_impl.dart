import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/community.dart';
import '../../domain/repositories/community_repository.dart';
import '../../core/network/api_exceptions.dart';
import '../datasources/remote_data_source.dart';
import '../models/community_model.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final RemoteDataSource _remote;

  CommunityRepositoryImpl(this._remote);

  @override
  Future<List<CommunityPost>> getFeed({int page = 1, int limit = 20}) async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getFeed,
      queryParameters: {'limit': limit, 'start': (page - 1) * limit},
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => CommunityPostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load feed');
  }

  @override
  Future<CommunityPost> getPostById(String id) async {
    final feed = await getFeed(page: 1, limit: 100);
    final match = feed.where((p) => p.id == id).toList();
    if (match.isNotEmpty) return match.first;
    throw ApiException(message: 'Post not found');
  }

  @override
  Future<CommunityPost> createPost(String content, {String? imageUrl}) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.createPost,
      data: {'content': content, 'title': 'Post', 'group': '', 'tags': ''},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return CommunityPostModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to create post');
  }

  @override
  Future<void> likePost(String postId) async {
    await _remote.post(ApiConstants.toggleLike, data: {'post': postId});
  }

  @override
  Future<void> unlikePost(String postId) async {
    await likePost(postId);
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    final response = await _remote.get<Map<String, dynamic>>(
      '/api/resource/Community Comment',
      queryParameters: {
        'filters': jsonEncode({'post': postId}),
        'limit': 100,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      final list = response.data!['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load comments');
  }

  @override
  Future<Comment> addComment(String postId, String content) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.addComment,
      data: {'post': postId, 'content': content},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return CommentModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to add comment');
  }

  @override
  Future<List<CommunityGroup>> getGroups() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.getGroups,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => CommunityGroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load groups');
  }

  @override
  Future<CommunityGroup> getGroupById(String id) async {
    final groups = await getGroups();
    final match = groups.where((g) => g.id == id).toList();
    if (match.isNotEmpty) return match.first;
    throw ApiException(message: 'Group not found');
  }

  @override
  Future<void> joinGroup(String groupId) async {
    throw ApiException(message: 'Group join not available on backend');
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    throw ApiException(message: 'Group leave not available on backend');
  }

  @override
  Future<List<Challenge>> getChallenges() async {
    throw ApiException(message: 'Challenges not available on backend');
  }

  @override
  Future<Challenge> getChallengeById(String id) async {
    throw ApiException(message: 'Challenges not available on backend');
  }

  @override
  Future<void> joinChallenge(String challengeId) async {
    throw ApiException(message: 'Challenges not available on backend');
  }

  @override
  Future<double> getChallengeProgress(String challengeId) async {
    throw ApiException(message: 'Challenges not available on backend');
  }
}
