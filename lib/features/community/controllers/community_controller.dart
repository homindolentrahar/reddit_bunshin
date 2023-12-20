import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/error/app_error.dart';
import 'package:reddit_bunshin/features/community/controllers/community_state.dart';
import 'package:reddit_bunshin/features/community/repositories/community_repository.dart';
import 'package:reddit_bunshin/models/community.dart';
import 'package:reddit_bunshin/models/post_model.dart';

class CommunityController extends StateNotifier<CommunityState> {
  String tag = "CommunityApplication::->";

  // Providers
  static final provider =
      StateNotifierProvider.autoDispose<CommunityController, CommunityState>(
    (ref) => CommunityController(
      communityRepository: ref.watch(CommunityRepository.provider),
      ref: ref,
    ),
  );
  static final communityProvider = StateProvider<Community?>((ref) => null);
  static final userCommunitiesProvider = StreamProvider.autoDispose(
    (ref) => ref
        .watch(provider.notifier)
        .watchUserCommunities(ref.read(userProvider)?.uid ?? ""),
  );
  static final communityByNameProvider = StreamProvider.autoDispose.family(
    (ref, String name) =>
        ref.watch(provider.notifier).watchCommunityByName(name),
  );
  static final searchCommunityProvider = StreamProvider.autoDispose.family(
    (ref, String query) => ref.watch(provider.notifier).searchCommunity(query),
  );
  static final communityPostsProvider = StreamProvider.autoDispose.family(
    (ref, String name) =>
        ref.watch(provider.notifier).watchCommunityPosts(name),
  );

  final Ref ref;
  final CommunityRepository _communityRepository;

  CommunityController({
    required this.ref,
    required CommunityRepository communityRepository,
  })  : _communityRepository = communityRepository,
        super(const CommunityState.initial());

  Stream<List<Community>> watchUserCommunities(String uid) =>
      _communityRepository.watchUserCommunities(uid);

  Stream<Community> watchCommunityByName(String name) =>
      _communityRepository.watchCommunityByName(name);

  Stream<List<Post>> watchCommunityPosts(String name) =>
      _communityRepository.watchCommunityPosts(name);

  Stream<List<Community>> searchCommunity(String query) =>
      ref.read(CommunityRepository.provider).searchCommunity(query);

  Future<void> createCommunity(Community community) async {
    state = const CommunityState.loading();

    final result = await _communityRepository.createCommunity(community);

    result.fold(
      (error) {
        state = CommunityState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const CommunityState.success();
      },
    );
  }

  Future<void> updateCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Community community,
  }) async {
    if (profileFile != null && bannerFile != null) {
      state = const CommunityState.loading();

      final result = await _communityRepository.updateCommunity(
        profileFile: profileFile,
        bannerFile: bannerFile,
        data: community,
      );

      result.fold(
        (error) {
          state = CommunityState.error(error.message);
          debugPrint("$tag [Error]: ${error.message}");
        },
        (data) {
          state = const CommunityState.success();
        },
      );
    }
  }

  Future<void> joinCommunity(Community community) async {
    state = const CommunityState.loading();

    final Either<AppError, Unit> result;
    final user = ref.read(userProvider);

    if (community.members.contains(user?.uid)) {
      result = await _communityRepository.leaveCommunity(
        community.name,
        user?.uid ?? "",
      );
    } else {
      result = await _communityRepository.joinCommunity(
        community.name,
        user?.uid ?? "",
      );
    }

    result.fold(
      (error) {
        state = CommunityState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const CommunityState.success();
      },
    );
  }

  Future<void> addMods(String name, List<String> uids) async {
    state = const CommunityState.loading();

    final result = await _communityRepository.addMods(name, uids);

    result.fold(
      (error) {
        state = CommunityState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (data) {
        state = const CommunityState.success();
      },
    );
  }
}
