import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reddit_bunshin/models/user_model.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;

  const factory LoginState.loading() = _Loading;

  const factory LoginState.success(UserModel? user) = _Success;

  const factory LoginState.error(String? errorMessage) = _Error;
}
