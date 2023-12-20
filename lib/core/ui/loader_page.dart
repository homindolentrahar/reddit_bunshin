import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';

class LoaderPage extends ConsumerWidget {
  const LoaderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      AuthController.provider,
      (previous, next) {
        next.maybeWhen(
          authenticated: (user, authToken) {
            context.go(RoutePaths.home);
          },
          orElse: () {
            context.go(RoutePaths.login);
          },
        );
      },
    );

    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
