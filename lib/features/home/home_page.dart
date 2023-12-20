import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:reddit_bunshin/features/community/widget/community_list_drawer.dart';
import 'package:reddit_bunshin/features/post/controllers/post_controller.dart';
import 'package:reddit_bunshin/features/profile/widgets/post_card.dart';
import 'package:reddit_bunshin/features/profile/widgets/profile_drawer.dart';
import 'package:reddit_bunshin/features/search/search_community_delegate.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isGuest = user?.isGuest ?? true;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: false,
        leading: Builder(
          builder: (ctx) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(ctx).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(ref),
              );
            },
          ),
          Builder(builder: (ctx) {
            return IconButton(
              icon: user?.profile?.contains("https://") ?? false
                  ? CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(user?.profile ?? ""),
                      radius: 24,
                    )
                  : CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 24,
                      child: Text(
                        user?.name?.substring(0, 1) ?? "N/A",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
              onPressed: () {
                Scaffold.of(ctx).openEndDrawer();
              },
            );
          }),
        ],
      ),
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.push("${RoutePaths.post}/create");
        },
      ),
      body: SafeArea(
        child: isGuest
            ? ref.watch(CommunityController.userCommunitiesProvider).when(
                  data: (communities) =>
                      ref.watch(PostController.guestPostsProvider).when(
                            data: (data) {
                              return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final post = data[index];
                                  return PostCard(post: post);
                                },
                              );
                            },
                            error: (error, stackTrace) {
                              return Text(error.toString());
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            : ref.watch(CommunityController.userCommunitiesProvider).when(
                  data: (communities) => ref
                      .watch(PostController.userPostsProvider(communities))
                      .when(
                        data: (data) {
                          return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final post = data[index];
                              return PostCard(post: post);
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return Text(error.toString());
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
      ),
    );
  }
}
