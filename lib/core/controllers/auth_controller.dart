import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_state.dart';
import 'package:reddit_bunshin/core/util/contract/app_contracts.dart';
import 'package:reddit_bunshin/core/util/helper/secure_storage_helper.dart';
import 'package:reddit_bunshin/core/util/helper/storage_helper.dart';
import 'package:reddit_bunshin/features/login/repositories/auth_repository.dart';
import 'package:reddit_bunshin/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthController extends StateNotifier<AuthState> {
  String tag = "AuthApplication::->";

  // Providers
  static final provider = StateNotifierProvider<AuthController, AuthState>(
    (ref) => AuthController(
      authRepository: ref.watch(AuthRepository.provider),
      ref: ref,
    ),
  );
  static final authStateProvider = StreamProvider(
    (ref) => ref.watch(provider.notifier).authStateChange,
  );
  static final userDataProvider = StreamProvider.family(
    (ref, String uid) => ref.watch(provider.notifier).watchUserData(uid),
  );

  final Ref ref;
  final AuthRepository _authRepository;

  AuthController({
    required this.ref,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState.initial()) {
    checkAuth();
  }

  Stream<Option<User>> get authStateChange => _authRepository.authStateChange;

  Stream<UserModel> watchUserData(String uid) =>
      _authRepository.watchUserData(uid);

  void checkAuth() {
    authStateChange.listen((option) {
      debugPrint("$tag [Auth State]: $option");

      option.fold(
        () {
          _unauthenticate();
        },
        (user) async {
          final savedUser = await ref
              .watch(AuthRepository.provider)
              .watchUserData(user.uid)
              .first;

          ref.read(userProvider.notifier).update((state) => savedUser);

          _authenticate(savedUser);
        },
      );
    });
  }

  Future<void> saveAuthData(UserModel? user) async {
    ref.read(userProvider.notifier).update((state) => user);

    SecureStorageHelper.instance.saveUser(user?.uid ?? "");
    StorageHelper.instance.writeValue(
      key: AppContracts.user,
      value: user?.toMap(),
    );

    _authenticate(user);
  }

  Future<void> logout() async {
    await _authRepository.signOut();

    _unauthenticate();
    _clearAuthData();
  }

  Future<void> _clearAuthData() async {
    SecureStorageHelper.instance.clearData();
    StorageHelper.instance.clearData();
  }

  void _unauthenticate() {
    state = const AuthState.unauthenticated();
  }

  void _authenticate(UserModel? user) {
    state = AuthState.authenticated(user: user);
  }
}
