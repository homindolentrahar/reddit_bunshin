import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/controllers/auth_controller.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/core/ui/widgets/buttons.dart';
import 'package:reddit_bunshin/core/ui/widgets/fields.dart';
import 'package:reddit_bunshin/core/util/constant/app_constants.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:reddit_bunshin/models/community.dart';

final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

class CreateCommunityPage extends ConsumerWidget {
  const CreateCommunityPage({super.key});

  void createCommunity(WidgetRef ref) {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final name = _formKey.currentState?.value['community'];
      final uid = ref.read(userProvider)?.uid ?? "";
      final community = Community(
        id: name,
        name: name,
        banner: AppConstants.bannerDefault,
        avatar: AppConstants.avatarDefault,
        members: [uid],
        mods: [uid],
      );

      ref
          .read(CommunityController.provider.notifier)
          .createCommunity(community);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              (route) => route.settings.name == RoutePaths.home,
            );
          },
          error: (message) {
            if (EasyLoading.isShow) {
              EasyLoading.dismiss();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$message"),
              ),
            );
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
        title: const Text("Create a community"),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              const MainTextField(
                name: 'community',
                hint: 'r/Community_name',
              ),
              const SizedBox(height: 16),
              MainPrimaryButton(
                title: "Create Community",
                onPressed: () {
                  createCommunity(ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
