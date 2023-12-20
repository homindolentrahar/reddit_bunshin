import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/route/routes.dart';

class ModToolsPage extends StatelessWidget {
  final String? name;

  const ModToolsPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mod Tools"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add_moderator),
                title: const Text("Add Moderators"),
                onTap: () {
                  context.push("${RoutePaths.mods}/$name");
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Community"),
                onTap: () {
                  context.push("${RoutePaths.community}/$name/edit");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
