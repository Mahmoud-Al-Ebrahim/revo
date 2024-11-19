import 'package:flutter/foundation.dart';

class Community {
  final String id;
  final String ownerId;
  final String name;
  final String banner;
  final String avatar;
  final List<String> members;
  final List<String> mods;
  final List<String> likes;
  final List<String> blockMembers;
  final String bio;
  Community({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.banner,
    required this.avatar,
    required this.members,
    required this.mods,
    required this.bio,
    this.likes = const [],
    this.blockMembers = const [],
  });

  Community copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? banner,
    String? avatar,
    String? bio,
    List<String>? members,
    List<String>? mods,
     List<String>? likes,
     List<String>? blockMembers,
  }) {
    return Community(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      likes: likes ?? this.likes,
      blockMembers: blockMembers ?? this.blockMembers,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      members: members ?? this.members,
      mods: mods ?? this.mods,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'banner': banner,
      'avatar': avatar,
      'members': members,
      'likes': likes,
      'blockMembers': blockMembers,
      'mods': mods,
      'bio': bio,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      banner: map['banner'] ?? '',
      avatar: map['avatar'] ?? '',
      bio: map['bio'] ?? 'You must update your bio!',
      members: List<String>.from(map['members']),
      mods: List<String>.from(map['mods']),
      likes: List<String>.from(map['likes'] ?? []),
      blockMembers: List<String>.from(map['blockMembers'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Community(id: $id, name: $name, banner: $banner, avatar: $avatar, members: $members, mods: $mods , bio: $bio, blockMembers: $blockMembers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Community &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.bio == bio &&
        other.name == name &&
        other.blockMembers == blockMembers &&
        other.banner == banner &&
        other.avatar == avatar &&
        listEquals(other.members, members) &&
        listEquals(other.likes, likes) &&
        listEquals(other.mods, mods);
  }

  @override
  int get hashCode {
    return id.hashCode ^ ownerId.hashCode ^ bio.hashCode ^ blockMembers.hashCode ^ name.hashCode ^ banner.hashCode ^ avatar.hashCode ^ members.hashCode ^ mods.hashCode^ likes.hashCode;
  }
}
