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
      ApiConstants.posts,
      queryParameters: {'page': page, 'limit': limit},
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
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.postById}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return CommunityPostModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Post not found');
  }

  @override
  Future<CommunityPost> createPost(String content, {String? imageUrl}) async {
    final response = await _remote.post<Map<String, dynamic>>(
      ApiConstants.posts,
      data: {'content': content, 'image_url': imageUrl},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return CommunityPostModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Failed to create post');
  }

  @override
  Future<void> likePost(String postId) async {
    await _remote.post('${ApiConstants.postLikes}/$postId');
  }

  @override
  Future<void> unlikePost(String postId) async {
    await _remote.delete('${ApiConstants.postLikes}/$postId');
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    final response = await _remote.get<List<dynamic>>(
      '${ApiConstants.postComments}/$postId',
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load comments');
  }

  @override
  Future<Comment> addComment(String postId, String content) async {
    final response = await _remote.post<Map<String, dynamic>>(
      '${ApiConstants.postComments}/$postId',
      data: {'content': content},
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
      ApiConstants.groups,
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
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.groupById}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return CommunityGroupModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Group not found');
  }

  @override
  Future<void> joinGroup(String groupId) async {
    await _remote.post('${ApiConstants.joinGroup}/$groupId');
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    await _remote.post('${ApiConstants.leaveGroup}/$groupId');
  }

  @override
  Future<List<Challenge>> getChallenges() async {
    final response = await _remote.get<List<dynamic>>(
      ApiConstants.challenges,
      fromJson: (json) => json as List<dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!
          .map((e) => ChallengeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(message: response.message ?? 'Failed to load challenges');
  }

  @override
  Future<Challenge> getChallengeById(String id) async {
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.challengeById}/$id',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return ChallengeModel.fromJson(response.data!);
    }
    throw ApiException(message: response.message ?? 'Challenge not found');
  }

  @override
  Future<void> joinChallenge(String challengeId) async {
    await _remote.post('${ApiConstants.joinChallenge}/$challengeId');
  }

  @override
  Future<double> getChallengeProgress(String challengeId) async {
    final response = await _remote.get<Map<String, dynamic>>(
      '${ApiConstants.challengeProgress}/$challengeId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (response.isSuccess && response.data != null) {
      return (response.data!['progress'] as num?)?.toDouble() ?? 0.0;
    }
    throw ApiException(message: response.message ?? 'Failed to get progress');
  }
}

