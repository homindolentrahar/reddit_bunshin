import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/di/app_injection.dart';
import 'package:reddit_bunshin/core/error/app_error.dart';
import 'package:reddit_bunshin/core/util/extension/firestore_ext.dart';
import 'package:reddit_bunshin/models/community.dart';
import 'package:reddit_bunshin/models/post_model.dart';

class CommunityRepository {
  String tag = "CommunityRepository::->";

  static final provider = Provider<CommunityRepository>(
    (ref) => CommunityRepository(
      firestore: ref.read(AppInjection.firestore),
      storage: ref.read(AppInjection.storage),
    ),
  );

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CommunityRepository(
      {required FirebaseFirestore firestore, required FirebaseStorage storage})
      : _firestore = firestore,
        _storage = storage;

  Future<Either<AppError, Unit>> createCommunity(Community data) async {
    try {
      final communityDoc = await _firestore.communityRef.doc(data.name).get();

      if (communityDoc.exists) {
        throw 'Community already exists with the name';
      }

      await _firestore.communityRef.doc(data.name).set(data.toMap());

      return right(unit);
    } on FirebaseException catch (error) {
      debugPrint("$tag [Error]: ${error.message}");
      return left(AppError("${error.code}: ${error.message}"));
    }
  }

  Future<Either<AppError, Unit>> updateCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Community data,
  }) async {
    try {
      final profileRef =
          _storage.ref().child('communities/profile').child(data.name);
      final bannerRef =
          _storage.ref().child('communities/banner').child(data.name);
      final profileTask = await profileRef.putFile(profileFile!);
      final bannerTask = await bannerRef.putFile(bannerFile!);

      await _firestore.communityRef.doc(data.name).update(
            data
                .copyWith(
                  avatar: await profileTask.ref.getDownloadURL(),
                  banner: await bannerTask.ref.getDownloadURL(),
                )
                .toMap(),
          );

      return right(unit);
    } on FirebaseException catch (error) {
      debugPrint("$tag [Error]: ${error.message}");
      return left(AppError("${error.code}: ${error.message}"));
    }
  }

  Future<Either<AppError, Unit>> joinCommunity(
    String communityName,
    String userId,
  ) async {
    try {
      await _firestore.communityRef.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      });

      return right(unit);
    } on FirebaseException catch (error) {
      debugPrint("$tag [Error]: ${error.message}");
      return left(AppError("${error.code}: ${error.message}"));
    }
  }

  Future<Either<AppError, Unit>> leaveCommunity(
    String communityName,
    String userId,
  ) async {
    try {
      await _firestore.communityRef.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      });

      return right(unit);
    } on FirebaseException catch (error) {
      debugPrint("$tag [Error]: ${error.message}");
      return left(AppError("${error.code}: ${error.message}"));
    }
  }

  Stream<List<Community>> watchUserCommunities(String uid) =>
      _firestore.communityRef
          .where('members', arrayContains: uid)
          .snapshots()
          .map(
            (event) => event.docs
                .map((e) => Community.fromMap(e.data() as Map<String, dynamic>))
                .toList(),
          );

  Stream<Community> watchCommunityByName(String name) =>
      _firestore.communityRef.doc(name).snapshots().map(
            (value) => Community.fromMap(
              value.data() as Map<String, dynamic>,
            ),
          );

  Stream<List<Post>> watchCommunityPosts(String name) => _firestore.postRef
      .where('communityName', isEqualTo: name)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList(),
      );

  Stream<List<Community>> searchCommunity(String query) {
    return _firestore.communityRef
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Community.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<Either<AppError, Unit>> addMods(
    String communityName,
    List<String> uids,
  ) async {
    try {
      await _firestore.communityRef.doc(communityName).update({'mods': uids});

      return right(unit);
    } on FirebaseException catch (error) {
      debugPrint("$tag [Error]: ${error.message}");
      return left(AppError("${error.code}: ${error.message}"));
    }
  }
}
