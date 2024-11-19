import 'package:flutter/foundation.dart';

class UserModel {
  final String firstName;
  final String lastName;
  final String profilePic;
  final String banner;
  final String birthDate;
  final String uid;
  final bool isAuthenticated; // if guest or not
  final int karma;
  final List<String> awards;
  final List<String> friends;
  final String fcmToken;
  final String? bio;
  final double walletBalance;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.profilePic,
    required this.banner,
    this.friends = const [],
    this.bio,
    this.walletBalance = 0,
    required this.uid,
    required this.isAuthenticated,
    required this.karma,
    required this.awards,
    required this.fcmToken,
  });

  UserModel copyWith(
      {
        String? firstName,
        String? lastName,
      String? profilePic,
      String? banner,
      String? uid,
      String? birthDate,
      String? bio,
      double? walletBalance,
      bool? isAuthenticated,
      int? karma,
      List<String>? awards,
      List<String>? friends,
      String? fcmToken}) {
    return UserModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      walletBalance: walletBalance ?? this.walletBalance,
      birthDate: birthDate ?? this.birthDate,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      friends: friends ?? this.friends,
      uid: uid ?? this.uid,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'friends': friends,
      'walletBalance': walletBalance,
      'birthDate': birthDate,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
      'awards': awards,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '',
        bio: map['bio'],
        birthDate: map['birthDate'] ?? '',
        profilePic: map['profilePic'] ?? '',
        banner: map['banner'] ?? '',
        uid: map['uid'] ?? '',
        isAuthenticated: map['isAuthenticated'] ?? false,
        karma: map['karma']?.toInt() ?? 0,
        walletBalance: map['walletBalance'] ?? 0,
        awards: List<String>.from(map['awards']),
        friends: List<String>.from(map['friends'] ?? []),
        fcmToken: map['fcmToken']);
  }

  @override
  String toString() {
    return 'UserModel(firstName: $firstName,lastName: $lastName, profilePic: $profilePic, banner: $banner, uid: $uid, isAuthenticated: $isAuthenticated, karma: $karma, awards: $awards, fcmToken: $fcmToken, birthDate: $birthDate, bio: $bio, walletBalance: $walletBalance, friends: $friends)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.firstName == firstName &&
        other.walletBalance == walletBalance &&
        other.lastName == lastName &&
        other.friends == friends &&
        other.bio == bio &&
        other.birthDate == birthDate &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.uid == uid &&
        other.isAuthenticated == isAuthenticated &&
        other.karma == karma &&
        other.fcmToken == fcmToken &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return
      firstName.hashCode ^
      lastName.hashCode ^
        profilePic.hashCode ^
      walletBalance.hashCode ^
      friends.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        bio.hashCode ^
        birthDate.hashCode ^
        isAuthenticated.hashCode ^
        karma.hashCode ^
        fcmToken.hashCode ^
        awards.hashCode;
  }
}
