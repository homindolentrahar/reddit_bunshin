import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/core/util/constant/app_constants.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:reddit_bunshin/features/post/controllers/post_controller.dart';
import 'package:reddit_bunshin/models/post_model.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(PostController.provider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(PostController.provider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(PostController.provider.notifier).downvote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(PostController.provider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    context.push("${RoutePaths.user}/${post.uid}");
  }

  void navigateToCommunity(BuildContext context) {
    context.push("${RoutePaths.post}/${post.communityName}");
  }

  void navigateToComments(BuildContext context) {
    context.push("${RoutePaths.post}/${post.id}/comments");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = user.isGuest;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ).copyWith(right: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => navigateToCommunity(context),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      post.communityProfilePic,
                                    ),
                                    radius: 16,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'r/${post.communityName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToUser(context),
                                          child: Text(
                                            'u/${post.username}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (post.uid == user.uid) ...[
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () => deletePost(ref, context),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ]
                        ],
                      ),
                      if (post.awards.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 25,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: post.awards.length,
                            itemBuilder: (BuildContext context, int index) {
                              final award = post.awards[index];
                              return Image.asset(
                                AppConstants.awards[award]!,
                                height: 23,
                              );
                            },
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isTypeImage)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          width: double.infinity,
                          child: Image.network(
                            post.link!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (isTypeLink)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          child: AnyLinkPreview(
                            displayDirection: UIDirection.uiDirectionHorizontal,
                            link: post.link!,
                          ),
                        ),
                      if (isTypeText)
                        Container(
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(
                            post.description!,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // if (!kIsWeb)
                          //   Row(
                          //     children: [
                          //       IconButton(
                          //         onPressed: isGuest
                          //             ? () {}
                          //             : () => upvotePost(ref),
                          //         icon: Icon(
                          //           Constants.up,
                          //           size: 30,
                          //           color: post.upvotes.contains(user.uid)
                          //               ? Pallete.redColor
                          //               : null,
                          //         ),
                          //       ),
                          //       Text(
                          //         '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                          //         style: const TextStyle(fontSize: 17),
                          //       ),
                          //       IconButton(
                          //         onPressed: isGuest
                          //             ? () {}
                          //             : () => downvotePost(ref),
                          //         icon: Icon(
                          //           Constants.down,
                          //           size: 30,
                          //           color: post.downvotes.contains(user.uid)
                          //               ? Pallete.blueColor
                          //               : null,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  navigateToComments(context);
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.comment),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          ref
                              .watch(
                                CommunityController.communityByNameProvider(
                                  post.communityName,
                                ),
                              )
                              .when(
                                data: (data) {
                                  return const SizedBox();
                                },
                                error: (error, stackTrace) => Text(
                                  error.toString(),
                                ),
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          IconButton(
                            onPressed: isGuest
                                ? () {}
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: GridView.builder(
                                            shrinkWrap: true,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                            ),
                                            itemCount: user.awards.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final award = user.awards[index];

                                              return GestureDetector(
                                                onTap: () => awardPost(
                                                    ref, award, context),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Image.asset(
                                                    AppConstants.awards[award]!,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.card_giftcard_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
