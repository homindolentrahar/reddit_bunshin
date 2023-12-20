import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/features/login/controllers/login_state.dart';
import 'package:reddit_bunshin/features/login/repositories/auth_repository.dart';

class LoginController extends StateNotifier<LoginState> {
  String tag = "LoginApplication::->";

  static final provider = StateNotifierProvider<LoginController, LoginState>(
    (ref) => LoginController(
      authRepository: ref.watch(AuthRepository.provider),
      ref: ref,
    ),
  );

  final Ref ref;
  final AuthRepository _authRepository;

  LoginController({
    required this.ref,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState.initial());

  Future<void> signInWithGoogle(bool isFromLogin) async {
    EasyLoading.show(dismissOnTap: false);

    state = const LoginState.loading();

    final result = await _authRepository.signInWithGoogle(isFromLogin);

    result.fold(
      (error) {
        EasyLoading.dismiss();

        state = LoginState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (userModel) {
        EasyLoading.dismiss();

        state = LoginState.success(userModel);

        ref.read(AuthController.provider.notifier).saveAuthData(userModel);
      },
    );
  }

  Future<void> signInAsGeust() async {
    EasyLoading.show(dismissOnTap: false);

    state = const LoginState.loading();

    final result = await _authRepository.signInAsGuest();

    result.fold(
      (error) {
        EasyLoading.dismiss();

        state = LoginState.error(error.message);
        debugPrint("$tag [Error]: ${error.message}");
      },
      (userModel) {
        EasyLoading.dismiss();

        state = LoginState.success(userModel);

        ref.read(AuthController.provider.notifier).saveAuthData(userModel);
      },
    );
  }
}
