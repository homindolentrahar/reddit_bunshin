import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/util/enum/enums.dart';
import 'package:reddit_bunshin/features/profile/controllers/profile_state.dart';
import 'package:reddit_bunshin/features/profile/repositories/profile_repository.dart';
import 'package:reddit_bunshin/models/post_model.dart';
import 'package:reddit_bunshin/models/user_model.dart';

class ProfileController extends StateNotifier<ProfileState> {
  String tag = "UserProfileController::->";

  // Providers
  static final provider =
      StateNotifierProvider<ProfileController, ProfileState>(
    (ref) => ProfileController(
      profileRepository: ref.watch(ProfileRepository.provider),
      ref: ref,
    ),
  );
  static final userPostsProvider = StreamProvider.family(
    (ref, String uid) =>
        ref.read(ProfileRepository.provider).watchUserPosts(uid),
  );

  final ProfileRepository _userProfileRepository;
  final Ref _ref;

  ProfileController({
    required ProfileRepository profileRepository,
    required Ref ref,
  })  : _userProfileRepository = profileRepository,
        _ref = ref,
        super(const ProfileState.initial());

  Stream<List<Post>> getUserPosts(String uid) =>
      _userProfileRepository.watchUserPosts(uid);

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required String name,
  }) async {
    if (profileFile != null && bannerFile != null) {
      state = const ProfileState.loading();

      UserModel user = _ref.read(userProvider)!;
      user = user.copyWith(name: name);

      final result = await _userProfileRepository.editProfile(
        profileFile: profileFile,
        bannerFile: bannerFile,
        user: user,
      );

      result.fold(
        (error) {
          state = ProfileState.error(error.message);
          debugPrint("$tag [Error]: ${error.message}");
        },
        (data) {
          state = const ProfileState.success();
        },
      );
    }
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }
}
