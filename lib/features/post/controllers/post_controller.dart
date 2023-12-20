import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/util/enum/enums.dart';
import 'package:reddit_bunshin/features/post/controllers/post_state.dart';
import 'package:reddit_bunshin/features/post/repositories/post_repository.dart';
import 'package:reddit_bunshin/features/profile/controllers/profile_controller.dart';
import 'package:reddit_bunshin/models/comment_model.dart';
import 'package:reddit_bunshin/models/community.dart';
import 'package:reddit_bunshin/models/post_model.dart';
import 'package:uuid/uuid.dart';

class PostController extends StateNotifier<PostState> {
  String tag = "PostController::->";

  // Providers
  static final provider = StateNotifierProvider<PostController, PostState>(
    (ref) => PostController(
      postRepository: ref.watch(PostRepository.provider),
      ref: ref,
    ),
  );

  static final userPostsProvider = StreamProvider.family(
    (ref, List<Community> communities) =>
        ref.watch(provider.notifier).watchUserPosts(communities),
  );

  static final guestPostsProvider = StreamProvider(
    (ref) => ref.watch(provider.notifier).watchGuestPosts(),
  );

  static final getPostByIdProvider = StreamProvider.family(
    (ref, String postId) => ref.watch(provider.notifier).watchPostById(postId),
  );

  static final getPostCommentsProvider = StreamProvider.family(
    (ref, String postId) =>
        ref.watch(provider.notifier).watchPostComments(postId),
  );

  final PostRepository _postRepository;
  final Ref _ref;

  PostController({
    required PostRepository postRepository,
    required Ref ref,
  })  : _postRepository = postRepository,
        _ref = ref,
        super(const PostState.initial());

  Stream<List<Comment>> watchPostComments(String postId) =>
      _postRepository.watchCommentsOfPost(postId);

  Stream<List<Post>> watchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.watchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> watchGuestPosts() => _postRepository.watchGuestPosts();

  Stream<Post> watchPostById(String postId) =>
      _postRepository.watchPostById(postId);

  void resetState() {
    state = const PostState.initial();
  }

  void shareTextPost({
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = const PostState.loading();

    final postId = const Uuid().v4();
    final user = _ref.read(userProvider);
    final post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user?.name ?? "",
      uid: user?.uid ?? "",
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final result = await _postRepository.addPost(post: post);
    _ref
        .read(ProfileController.provider.notifier)
        .updateUserKarma(UserKarma.textPost);

    result.fold(
      (error) {
        state = PostState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const PostState.success();
      },
    );
  }

  void shareLinkPost({
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = const PostState.loading();

    final postId = const Uuid().v4();
    final user = _ref.read(userProvider)!;
    final post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name ?? "",
      uid: user.uid ?? "",
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final result = await _postRepository.addPost(post: post);
    _ref
        .read(ProfileController.provider.notifier)
        .updateUserKarma(UserKarma.linkPost);

    result.fold(
      (error) {
        state = PostState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const PostState.success();
      },
    );
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
  }) async {
    state = const PostState.loading();

    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name ?? "",
      uid: user.uid ?? "",
      type: 'image',
      createdAt: DateTime.now(),
      awards: [],
    );

    final result = await _postRepository.addPost(
      post: post,
      communityName: selectedCommunity.name,
      file: file,
    );

    _ref
        .read(ProfileController.provider.notifier)
        .updateUserKarma(UserKarma.imagePost);

    result.fold(
      (error) {
        state = PostState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const PostState.success();
      },
    );
  }

  void deletePost(Post post, BuildContext context) async {
    final result = await _postRepository.deletePost(post);
    _ref
        .read(ProfileController.provider.notifier)
        .updateUserKarma(UserKarma.deletePost);

    result.fold(
      (error) {
        state = PostState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const PostState.success();
      },
    );
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid ?? "");
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid ?? "");
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.name ?? "",
      profilePic: user.profile ?? "",
    );
    final res = await _postRepository.addComment(comment);
    _ref
        .read(ProfileController.provider.notifier)
        .updateUserKarma(UserKarma.comment);

    res.fold(
      (error) {
        state = PostState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {},
    );
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final result = await _postRepository.awardPost(
      post,
      award,
      user.uid ?? "",
    );

    result.fold(
      (error) {
        state = PostState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        _ref
            .read(ProfileController.provider.notifier)
            .updateUserKarma(UserKarma.awardPost);
        _ref.read(userProvider.notifier).update((state) {
          state?.awards.remove(award);
          return state;
        });
        // Navigate Back
      },
    );
  }
}
