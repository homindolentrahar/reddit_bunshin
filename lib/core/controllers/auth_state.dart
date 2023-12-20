import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reddit_bunshin/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    UserModel? user,
    String? authToken,
  }) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
}
