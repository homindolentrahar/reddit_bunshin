import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reddit_bunshin/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.loading() = _Loading;
  const factory ProfileState.success({UserModel? user}) = _Success;
  const factory ProfileState.error(String? errorMessage) = _Error;
}
