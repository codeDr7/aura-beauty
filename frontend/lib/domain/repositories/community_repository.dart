import '../entities/community.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> getFeed({int page, int limit});
  Future<CommunityPost> getPostById(String id);
  Future<CommunityPost> createPost(String content, {String? imageUrl});
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<List<Comment>> getComments(String postId);
  Future<Comment> addComment(String postId, String content);

  Future<List<CommunityGroup>> getGroups();
  Future<CommunityGroup> getGroupById(String id);
  Future<void> joinGroup(String groupId);
  Future<void> leaveGroup(String groupId);

  Future<List<Challenge>> getChallenges();
  Future<Challenge> getChallengeById(String id);
  Future<void> joinChallenge(String challengeId);
  Future<double> getChallengeProgress(String challengeId);
}
