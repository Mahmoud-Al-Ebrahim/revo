import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final List<String> likes;
  final List<String> haha;
  final List<String> loves;
  final List<String> angry;
  final List<String> wow;
  final List<String> sad;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String username;
  final String uid;
  final String type;
  final DateTime createdAt;
  final List<String> awards;
  final bool isShowEnabled;
  final int upVotesCount;
  final int downVotesCount;

  Post({
    required this.id,
    required this.title,
    this.link,
    this.description,
    this.isShowEnabled = false,
    required this.communityName,
    required this.communityProfilePic,
    this.wow = const [],
    this.sad = const [],
    this.likes = const [],
    this.angry = const [],
    this.loves = const [],
    this.haha = const [],
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.username,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.awards,
    required this.upVotesCount,
    required this.downVotesCount,
  });

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityProfilePic,
    bool? isShowEnabled,
    List<String>? upvotes,
    List<String>? downvotes,
    List<String>? likes,
    List<String>? haha,
    List<String>? loves,
    List<String>? angry,
    List<String>? wow,
    List<String>? sad,
    int? commentCount,
    int? upVotesCount,
    int? downVotesCount,
    String? username,
    String? uid,
    String? type,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      upVotesCount: upVotesCount ?? this.upVotesCount,
      downVotesCount: downVotesCount ?? this.downVotesCount,
      isShowEnabled: isShowEnabled ?? this.isShowEnabled,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      wow: wow ?? this.wow,
      loves: loves ?? this.loves,
      haha: haha ?? this.haha,
      angry: angry ?? this.angry,
      sad: sad ?? this.sad,
      likes: likes ?? this.likes,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'isShowEnabled': isShowEnabled,
      'description': description,
      'communityName': communityName,
      'communityProfilePic': communityProfilePic,
      'likes': likes,
      'wow': wow,
      'sad': sad,
      'loves': loves,
      'angry': angry,
      'haha': haha,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'downVotesCount': downVotesCount,
      'upVotesCount': upVotesCount,
      'commentCount': commentCount,
      'username': username,
      'uid': uid,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'awards': awards,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      description: map['description'],
      communityName: map['communityName'] ?? '',
      isShowEnabled: map['isShowEnabled'] ?? true,
      communityProfilePic: map['communityProfilePic'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      wow: List<String>.from(map['wow'] ?? []),
      sad: List<String>.from(map['sad'] ?? []),
      haha: List<String>.from(map['haha'] ?? []),
      angry: List<String>.from(map['angry'] ?? []),
      loves: List<String>.from(map['loves'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      downvotes: List<String>.from(map['downvotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      upVotesCount: map['upVotesCount']?.toInt() ?? 0,
      downVotesCount: map['downVotesCount']?.toInt() ?? 0,
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      awards: List<String>.from(map['awards']),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, link: $link, description: $description, communityName: $communityName, communityProfilePic: $communityProfilePic, upvotes: $upvotes, downvotes: $downvotes, commentCount: $commentCount, username: $username, uid: $uid, type: $type, createdAt: $createdAt, awards: $awards, downVotesCount: $downVotesCount, upVotesCount: $upVotesCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Post &&
        other.id == id &&
        other.isShowEnabled == isShowEnabled &&
        other.upVotesCount == upVotesCount &&
        other.downVotesCount == downVotesCount &&
        other.title == title &&
        other.link == link &&
        other.description == description &&
        other.communityName == communityName &&
        other.communityProfilePic == communityProfilePic &&
        listEquals(other.upvotes, upvotes) &&
        listEquals(other.wow, wow) &&
        listEquals(other.sad, sad) &&
        listEquals(other.angry, angry) &&
        listEquals(other.likes, likes) &&
        listEquals(other.loves, loves) &&
        listEquals(other.haha, haha) &&
        listEquals(other.downvotes, downvotes) &&
        other.commentCount == commentCount &&
        other.username == username &&
        other.uid == uid &&
        other.type == type &&
        other.createdAt == createdAt &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isShowEnabled.hashCode ^
        link.hashCode ^
        description.hashCode ^
        downVotesCount.hashCode ^
        upVotesCount.hashCode ^
        communityName.hashCode ^
        communityProfilePic.hashCode ^
        upvotes.hashCode ^
        wow.hashCode ^
        sad.hashCode ^
        likes.hashCode ^
        loves.hashCode ^
        angry.hashCode ^
        haha.hashCode ^
        downvotes.hashCode ^
        commentCount.hashCode ^
        username.hashCode ^
        uid.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        awards.hashCode;
  }
}
