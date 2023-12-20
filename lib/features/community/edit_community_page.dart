import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/core/util/constant/app_constants.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';

class EditCommunityPage extends ConsumerStatefulWidget {
  final String? name;

  const EditCommunityPage({super.key, required this.name});

  @override
  ConsumerState<EditCommunityPage> createState() => _EditCommunityPageState();
}

class _EditCommunityPageState extends ConsumerState<EditCommunityPage> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        bannerFile = File(result.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      setState(() {
        profileFile = File(result.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      CommunityController.provider,
      (previous, next) {
        next.maybeWhen(
          loading: () {
            EasyLoading.show();
          },
          success: (_) {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }

            Navigator.popUntil(
              context,
              (route) =>
                  route.settings.name ==
                  "${RoutePaths.community}/${widget.name}",
            );
          },
          error: (message) {
            EasyLoading.showError("Failed edit community");
          },
          orElse: () {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Community"),
        actions: [
          TextButton(
            onPressed: () {
              final community = ref.watch(
                CommunityController.communityByNameProvider(widget.name ?? ""),
              );

              community.maybeWhen(
                data: (data) {
                  ref
                      .read(CommunityController.provider.notifier)
                      .updateCommunity(
                        profileFile: profileFile,
                        bannerFile: bannerFile,
                        community: data,
                      );
                },
                orElse: () {},
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ref
            .watch(
                CommunityController.communityByNameProvider(widget.name ?? ""))
            .maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              data: (community) {
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: selectBannerImage,
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 10],
                              strokeCap: StrokeCap.round,
                              color: Colors.grey.shade700,
                              child: Container(
                                width: double.infinity,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: bannerFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          bannerFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (community.banner.isEmpty) ||
                                            community.banner ==
                                                AppConstants.bannerDefault
                                        ? const Center(
                                            child:
                                                Icon(Icons.camera_alt_outlined),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: community.banner ?? "",
                                          ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            child: GestureDetector(
                              onTap: selectProfileImage,
                              child: profileFile != null
                                  ? CircleAvatar(
                                      backgroundImage: FileImage(profileFile!),
                                      radius: 32,
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        community.avatar,
                                      ),
                                      radius: 32,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
      ),
    );
  }
}
