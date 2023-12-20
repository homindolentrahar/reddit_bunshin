import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/core/ui/themes.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:reddit_bunshin/features/post/controllers/post_controller.dart';
import 'package:reddit_bunshin/models/community.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AddPostTypePage extends ConsumerStatefulWidget {
  final String type;

  const AddPostTypePage({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypePageState();
}

class _AddPostTypePageState extends ConsumerState<AddPostTypePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  final speechToText = SpeechToText();
  File? bannerFile;
  List<Community> communities = [];
  Community? selectedCommunity;
  bool isListening = false;

  @override
  void initState() {
    super.initState();

    _initSpeech();

    ref.read(PostController.provider.notifier).resetState();
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void _initSpeech() async {
    await speechToText.initialize(debugLogging: true);
  }

  void _startListening() async {
    await speechToText.listen(
      onResult: (result) {
        setState(() {
          titleController.text = result.recognizedWords;
        });
      },
      listenMode: ListenMode.search,
    );
  }

  void _stopListening() async {
    await speechToText.stop();
  }

  void selectBannerImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);

    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(PostController.provider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            file: bannerFile,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(PostController.provider.notifier).shareTextPost(
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            description: descriptionController.text.trim(),
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(PostController.provider.notifier).shareLinkPost(
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            link: linkController.text.trim(),
          );
    } else {
      // showSnackBar(context, 'Please enter all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';

    ref.listen(
      PostController.provider,
      (previous, next) {
        next.maybeWhen(
          loading: () {
            EasyLoading.show();
          },
          success: (data) {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }

            Navigator.popUntil(
              context,
              (route) => route.settings.name == RoutePaths.home,
            );
          },
          error: (error) {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }

            EasyLoading.showError(error ?? "");
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
        title: Text('Post ${widget.type}'),
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter Title here',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isListening = !isListening;
                      });

                      if (isListening) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mic is Listening"),
                            duration: Duration(days: 1),
                          ),
                        );

                        _startListening();
                      } else {
                        ScaffoldMessenger.of(context).clearSnackBars();

                        _stopListening();
                      }
                    },
                    child: Icon(isListening ? Icons.mic_off : Icons.mic),
                  )),
              maxLength: 30,
            ),
            const SizedBox(height: 10),
            if (isTypeImage)
              GestureDetector(
                onTap: selectBannerImage,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(16),
                  dashPattern: const [10, 10],
                  strokeCap: StrokeCap.round,
                  color: AppColors.greyColor,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: bannerFile != null
                        ? Image.file(bannerFile!)
                        : const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
            if (isTypeText)
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter Description here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
                maxLines: 5,
              ),
            if (isTypeLink)
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Enter link here',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                ),
              ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Community',
              ),
            ),
            ref.watch(CommunityController.userCommunitiesProvider).when(
                  data: (data) {
                    communities = data;

                    if (data.isEmpty) {
                      return const SizedBox();
                    }

                    return DropdownButton(
                      value: selectedCommunity ?? data[0],
                      items: data
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCommunity = val;
                        });
                      },
                    );
                  },
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const CircularProgressIndicator(),
                ),
          ],
        ),
      ),
    );
  }
}
