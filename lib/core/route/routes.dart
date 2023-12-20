import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/ui/loader_page.dart';
import 'package:reddit_bunshin/features/community/community_page.dart';
import 'package:reddit_bunshin/features/community/create_community_page.dart';
import 'package:reddit_bunshin/features/community/edit_community_page.dart';
import 'package:reddit_bunshin/features/community/mod_tools_page.dart';
import 'package:reddit_bunshin/features/home/home_page.dart';
import 'package:reddit_bunshin/features/login/login_page.dart';
import 'package:reddit_bunshin/features/mods/add_mods_page.dart';
import 'package:reddit_bunshin/features/post/add_post_page.dart';
import 'package:reddit_bunshin/features/post/add_post_type_page.dart';
import 'package:reddit_bunshin/features/post/comments_page.dart';
import 'package:reddit_bunshin/features/profile/edit_profile_page.dart';
import 'package:reddit_bunshin/features/profile/profile_page.dart';

abstract class Routes {
  static final GoRouter routeDelegate = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.initial,
        builder: (context, state) => const LoaderPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: "${RoutePaths.community}/create",
        builder: (context, state) => const CreateCommunityPage(),
      ),
      GoRoute(
        path: "${RoutePaths.community}/:name",
        builder: (context, state) => CommunityPage(
          name: state.pathParameters['name'],
        ),
        routes: [
          GoRoute(
            path: "mod-tools",
            builder: (context, state) => ModToolsPage(
              name: state.pathParameters['name'],
            ),
          ),
          GoRoute(
            path: "edit",
            builder: (context, state) => EditCommunityPage(
              name: state.pathParameters['name'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: "${RoutePaths.post}/create",
        builder: (context, state) => const AddPostPage(),
        routes: [
          GoRoute(
            path: ":type",
            builder: (context, state) => AddPostTypePage(
              type: state.pathParameters['type'] ?? "",
            ),
          ),
        ],
      ),
      GoRoute(
        path: "${RoutePaths.post}/:id",
        builder: (context, state) => const AddPostPage(),
        routes: [
          GoRoute(
            path: "comments",
            builder: (context, state) => CommentsPage(
              postId: state.pathParameters['id'] ?? "",
            ),
          ),
        ],
      ),
      GoRoute(
          path: "${RoutePaths.user}/:uid",
          builder: (context, state) => ProfilePage(
                uid: state.pathParameters['uid'] ?? "",
              ),
          routes: [
            GoRoute(
              path: "edit",
              builder: (context, state) => EditProfilePage(
                uid: state.pathParameters['uid'] ?? "",
              ),
            ),
          ]),
      GoRoute(
        path: "${RoutePaths.mods}/:name",
        builder: (context, state) => AddModsPage(
          name: state.pathParameters['name'] ?? "",
        ),
      ),
    ],
  );
}

abstract class RoutePaths {
  static const String initial = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String community = '/community';
  static const String post = '/post';
  static const String createCommunity = '/create-community';
  static const String createPost = '/post/create';
  static const String user = '/u';
  static const String mods = '/mods';

  static List<String> get protectedPaths => [
        home,
        "$community/:name",
        createCommunity,
        "$community/:name/mod-tools",
        "$community/:name/edit",
      ];
}
