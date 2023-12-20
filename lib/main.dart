import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/initializer.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/core/util/helper/theme_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Initializer.init();

  runApp(
    const ProviderScope(
      child: RedditApp(),
    ),
  );
}

class RedditApp extends StatelessWidget {
  const RedditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeHelper.instance.getTheme(),
      routerConfig: Routes.routeDelegate,
      title: "Reddit Bunshin",
      builder: EasyLoading.init(),
    );
  }
}
