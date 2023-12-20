import 'package:flutter/foundation.dart';

class UserModel {
  final String? uid;
  final String? name;
  final String? profile;
  final String? banner;
  final bool isGuest;
  final int karma;
  final List<String> awards;

  UserModel({
    this.uid,
    this.name,
    this.profile,
    this.banner,
    this.isGuest = true,
    this.karma = 0,
    this.awards = const [],
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? profile,
    String? banner,
    bool? isGuest,
    int? karma,
    List<String>? awards,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      profile: profile ?? this.profile,
      banner: banner ?? this.banner,
      isGuest: isGuest ?? this.isGuest,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'profile': profile,
      'banner': banner,
      'isGuest': isGuest,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      profile: map['profile'] as String,
      banner: map['banner'] as String,
      isGuest: map['isGuest'] as bool,
      karma: map['karma'] as int,
      awards: List<String>.from(
        (map['awards'] as List<dynamic>),
      ),
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, profile: $profile, banner: $banner, isGuest: $isGuest, karma: $karma, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.profile == profile &&
        other.banner == banner &&
        other.isGuest == isGuest &&
        other.karma == karma &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        profile.hashCode ^
        banner.hashCode ^
        isGuest.hashCode ^
        karma.hashCode ^
        awards.hashCode;
  }
}
