import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:reddit_bunshin/features/profile/widgets/post_card.dart';

class CommunityPage extends ConsumerWidget {
  final String? name;

  const CommunityPage({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      CommunityController.provider,
      (previous, next) {
        next.maybeWhen(
          loading: () {},
          success: (message) {
            // EasyLoading.showSuccess(message);
          },
          orElse: () {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
          },
        );
      },
    );
    final user = ref.watch(userProvider);
    final isGuest = user?.isGuest ?? true;
    // final isMember = community?.members.contains(user?.uid) ?? false;

    return Scaffold(
      body: SafeArea(
        child: ref
            .watch(CommunityController.communityByNameProvider(name ?? ""))
            .maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (community) {
                return NestedScrollView(
                  headerSliverBuilder: (ctx, innerBoxisScrolled) {
                    return [
                      SliverAppBar(
                        expandedHeight: 160,
                        floating: true,
                        snap: true,
                        flexibleSpace: Stack(
                          children: [
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: community.banner,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    community.avatar,
                                  ),
                                  radius: 32,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "r/${community.name}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (!isGuest)
                                    community.mods.contains(user?.uid)
                                        ? OutlinedButton(
                                            onPressed: () {
                                              context.push(
                                                "${RoutePaths.community}/${community.name}/mod-tools",
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Text("Mod Tools"),
                                          )
                                        : OutlinedButton(
                                            onPressed: () => ref
                                                .read(CommunityController
                                                    .provider.notifier)
                                                .joinCommunity(community),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Text(
                                              community.members
                                                      .contains(user?.uid)
                                                  ? "Joined"
                                                  : "Join",
                                            ),
                                          ),
                                ],
                              ),
                              Text(
                                "${community.members.length} members",
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ];
                  },
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ref
                        .watch(
                          CommunityController.communityPostsProvider(
                              name ?? ""),
                        )
                        .when(
                          data: (data) => ListView.separated(
                            itemCount: data.length,
                            separatorBuilder: (ctx, index) => Divider(
                              color: Colors.grey.shade800,
                              thickness: 1,
                            ),
                            itemBuilder: (ctx, index) => PostCard(
                              post: data[index],
                            ),
                          ),
                          error: (error, trace) => Text(error.toString()),
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  ),
                );
              },
              orElse: () => const SizedBox(),
            ),
      ),
    );
  }
}
