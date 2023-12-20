import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_bunshin/core/route/routes.dart';
import 'package:reddit_bunshin/features/community/controllers/community_controller.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  final SpeechToText speechToText = SpeechToText();
  bool isListening = false;

  SearchCommunityDelegate(this.ref) {
    _initSpeech();
  }

  void _initSpeech() async {
    await speechToText.initialize();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          isListening = !isListening;
        },
        icon: isListening ? const Icon(Icons.mic_off) : const Icon(Icons.mic),
      ),
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(CommunityController.searchCommunityProvider(query)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (communities) => ListView.builder(
            itemCount: communities.length,
            itemBuilder: (ctx, index) => ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  communities[index].avatar,
                ),
              ),
              title: Text('r/${communities[index].name}'),
              onTap: () {
                context.beamToNamed(
                  "${RoutePaths.community}/${communities[index].name}",
                );
              },
            ),
          ),
          error: (error, stackTrace) => Text(error.toString()),
        );
  }
}
