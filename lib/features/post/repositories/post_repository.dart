import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/di/app_injection.dart';
import 'package:reddit_bunshin/core/error/app_error.dart';
import 'package:reddit_bunshin/core/util/extension/firestore_ext.dart';
import 'package:reddit_bunshin/models/comment_model.dart';
import 'package:reddit_bunshin/models/community.dart';
import 'package:reddit_bunshin/models/post_model.dart';

class PostRepository {
  String tag = "CommunityRepository::->";

  static final provider = Provider<PostRepository>((ref) {
    return PostRepository(
      firestore: ref.watch(AppInjection.firestore),
      storage: ref.watch(AppInjection.storage),
    );
  });

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  PostRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  Stream<List<Post>> watchUserPosts(List<Community> communities) => _firestore
      .postRef
      .where('communityName', whereIn: communities.map((e) => e.name).toList())
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (event) => event.docs
            .map(
              (e) => Post.fromMap(
                e.data() as Map<String, dynamic>,
              ),
            )
            .toList(),
      );

  Stream<List<Post>> watchGuestPosts() => _firestore.postRef
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map(
        (event) => event.docs
            .map(
              (e) => Post.fromMap(
                e.data() as Map<String, dynamic>,
              ),
            )
            .toList(),
      );

  Stream<Post> watchPostById(String postId) => _firestore.postRef
      .doc(postId)
      .snapshots()
      .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));

  Stream<List<Comment>> watchCommentsOfPost(String postId) =>
      _firestore.commentRef
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (event) => event.docs
                .map(
                  (e) => Comment.fromMap(
                    e.data() as Map<String, dynamic>,
                  ),
                )
                .toList(),
          );

  Future<Either<AppError, Unit>> addPost({
    File? file,
    required Post post,
    String? communityName,
  }) async {
    try {
      if (file != null) {
        final fileRef = _storage.ref().child('posts/$communityName').child(
              post.id,
            );
        final fileTask = await fileRef.putFile(file);

        await _firestore.postRef.doc(post.id).set(post
            .copyWith(
              link: await fileTask.ref.getDownloadURL(),
            )
            .toMap());
      } else {
        await _firestore.postRef.doc(post.id).set(post.toMap());
      }

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.code}: ${e.message}");
      throw "${e.code}: ${e.message}";
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  Future<Either<AppError, Unit>> deletePost(Post post) async {
    try {
      await _firestore.postRef.doc(post.id).delete();

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.code}: ${e.message}");
      throw "${e.code}: ${e.message}";
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  Future<Either<AppError, Unit>> addComment(Comment comment) async {
    try {
      await Future.wait([
        _firestore.commentRef.doc(comment.id).set(comment.toMap()),
        _firestore.postRef.doc(comment.postId).update({
          'commentCount': FieldValue.increment(1),
        }),
      ]);

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.code}: ${e.message}");
      throw "${e.code}: ${e.message}";
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  Future<Either<AppError, Unit>> awardPost(
    Post post,
    String award,
    String senderId,
  ) async {
    try {
      await Future.wait([
        _firestore.postRef.doc(post.id).update({
          'awards': FieldValue.arrayUnion([award]),
        }),
        _firestore.userRef.doc(senderId).update({
          'awards': FieldValue.arrayRemove([award]),
        }),
        _firestore.userRef.doc(post.uid).update({
          'awards': FieldValue.arrayUnion([award]),
        }),
      ]);

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.code}: ${e.message}");
      throw "${e.code}: ${e.message}";
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _firestore.postRef.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _firestore.postRef.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _firestore.postRef.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _firestore.postRef.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _firestore.postRef.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _firestore.postRef.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }
}
