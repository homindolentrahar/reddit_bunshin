import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/features/login/controllers/login_application.dart';
import 'package:reddit_bunshin/features/login/widgets/sign_in_button.dart';
import 'package:reddit_bunshin/gen/assets.gen.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      AuthController.provider,
      (previous, next) {
        next.maybeWhen(
          loading: () {
            EasyLoading.show();
          },
          authenticated: (user, authToken) {
            context.go(RoutePaths.home);
          },
          orElse: () {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }

            context.go(RoutePaths.login);
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          Assets.images.logo.path,
          height: 40,
        ),
        actions: [
          TextButton(
            child: const Text(
              "Skip",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              ref.read(LoginController.provider.notifier).signInAsGeust();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Dive into anything",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              Image.asset(
                Assets.images.loginEmote.path,
                width: MediaQuery.of(context).size.width,
                height: 320,
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) {
                  return SignInButton(
                    onPressed: () {
                      ref
                          .read(LoginController.provider.notifier)
                          .signInWithGoogle(true);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
