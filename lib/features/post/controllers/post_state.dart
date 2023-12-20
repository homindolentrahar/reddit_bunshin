import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reddit_bunshin/models/post_model.dart';

part 'post_state.freezed.dart';

@freezed
class PostState with _$PostState {
  const factory PostState.initial() = _Initial;

  const factory PostState.loading() = _Loading;

  const factory PostState.success({@Default([]) List<Post> posts}) = _Success;

  const factory PostState.error(String? message) = _Error;
}
