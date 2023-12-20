import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    ref.listen(
      AuthController.provider,
      (previous, next) {
        next.maybeWhen(
          unauthenticated: () {
            context.replace(RoutePaths.login);
          },
          orElse: () {},
        );
      },
    );

    return Drawer(
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                user?.profile ?? "",
              ),
              radius: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "u/${user?.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey.shade800,
            ),
            ListTile(
              title: const Text("My Profile"),
              leading: const Icon(Icons.person),
              onTap: () {
                context.push("${RoutePaths.user}/${user?.uid}");
              },
            ),
            ListTile(
              title: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              onTap: () {
                ref.read(AuthController.provider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
