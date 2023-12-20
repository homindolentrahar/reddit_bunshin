import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:reddit_bunshin/features/login/controllers/login_application.dart';
import 'package:reddit_bunshin/features/login/widgets/sign_in_button.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isGuest = user?.isGuest ?? true;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? SignInButton(
                    onPressed: () {
                      ref
                          .read(LoginController.provider.notifier)
                          .signInWithGoogle(false);
                    },
                  )
                : ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Create a community"),
                    onTap: () {
                      context.push("${RoutePaths.community}/create");
                    },
                  ),
            if (!isGuest) ...[
              const SizedBox(height: 16),
              ref.watch(CommunityController.userCommunitiesProvider).maybeWhen(
                    loading: () => const CircularProgressIndicator(),
                    data: (data) => ListView.separated(
                      shrinkWrap: true,
                      itemCount: data.length,
                      separatorBuilder: (ctx, index) => Divider(
                        color: Colors.grey.shade800,
                      ),
                      itemBuilder: (ctx, index) => ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(360),
                          child: CachedNetworkImage(
                            imageUrl: data[index].avatar,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        title: Text(
                          'r/${data[index].name}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          context.push(
                            "${RoutePaths.community}/${data[index].name}",
                          );
                        },
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
            ]
          ],
        ),
      ),
    );
  }
}
