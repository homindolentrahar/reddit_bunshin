import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/di/app_injection.dart';
import 'package:reddit_bunshin/core/error/app_error.dart';
import 'package:reddit_bunshin/core/util/extension/firestore_ext.dart';
import 'package:reddit_bunshin/models/post_model.dart';
import 'package:reddit_bunshin/models/user_model.dart';

class ProfileRepository {
  String tag = "UserProfileRepository::->";

  static final provider = Provider<ProfileRepository>((ref) {
    return ProfileRepository(
      firestore: ref.watch(AppInjection.firestore),
      storage: ref.watch(AppInjection.storage),
    );
  });

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  Stream<List<Post>> watchUserPosts(String uid) => _firestore.postRef
      .where('uid', isEqualTo: uid)
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

  Future<Either<AppError, Unit>> editProfile({
    required File? profileFile,
    required File? bannerFile,
    required UserModel user,
  }) async {
    try {
      final profileRef =
          _storage.ref().child('users/profile').child(user.uid ?? "");
      final bannerRef =
          _storage.ref().child('users/banner').child(user.uid ?? "");
      final profileTask = await profileRef.putFile(profileFile!);
      final bannerTask = await bannerRef.putFile(bannerFile!);

      await _firestore.userRef.doc(user.uid).update(
            user
                .copyWith(
                  profile: await profileTask.ref.getDownloadURL(),
                  banner: await bannerTask.ref.getDownloadURL(),
                )
                .toMap(),
          );

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.code}: ${e.message}");
      throw "${e.code}: ${e.message}";
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }

  Future<Either<AppError, Unit>> updateUserKarma(UserModel user) async {
    try {
      await _firestore.userRef.doc(user.uid).update({'karma': user.karma});

      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint("$tag [Error]: ${e.code}: ${e.message}");
      throw "${e.code}: ${e.message}";
    } catch (e) {
      return left(AppError(e.toString()));
    }
  }
}
