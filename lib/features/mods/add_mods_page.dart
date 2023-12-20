import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';

class AddModsPage extends ConsumerStatefulWidget {
  final String name;

  const AddModsPage({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsPage> {
  Set<String> uids = {};
  int ctr = 0;

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref.read(CommunityController.provider.notifier).addMods(
          widget.name,
          uids.toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ref
          .watch(CommunityController.communityByNameProvider(widget.name))
          .when(
            data: (community) => ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (BuildContext context, int index) {
                final member = community.members[index];

                return ref.watch(AuthController.userDataProvider(member)).when(
                      data: (user) {
                        if (community.mods.contains(member) && ctr == 0) {
                          uids.add(member);
                        }
                        ctr++;
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUid(user.uid ?? "");
                            } else {
                              removeUid(user.uid ?? "");
                            }
                          },
                          title: Text(user.name ?? ""),
                        );
                      },
                      error: (error, stackTrace) => Text(
                        error.toString(),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    );
              },
            ),
            error: (error, stackTrace) => Text(
              error.toString(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
    );
  }
}
