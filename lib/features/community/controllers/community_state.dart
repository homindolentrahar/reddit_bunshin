import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reddit_bunshin/models/community.dart';

part 'community_state.freezed.dart';

@freezed
class CommunityState with _$CommunityState {
  const factory CommunityState.initial() = _Initial;
  const factory CommunityState.loading() = _Loading;
  const factory CommunityState.success({
    @Default([]) List<Community> communities,
  }) = _Success;
  const factory CommunityState.error(String? errorMessage) = _Error;
}
