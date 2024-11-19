class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String uid;
  final String username;
  final String profilePic;
  final List<dynamic> likes;
  final List<dynamic> replies;
  final bool isReply;
  final String? parentCommentId;

  Comment(
      {required this.id,
        required this.text,
        required this.createdAt,
        required this.postId,
        required this.username,
        required this.profilePic,
        required this.uid,
        required this.likes,
        required this.replies,
        required this.isReply,
        this.parentCommentId});

  Comment copyWith(
      {String? id,
        String? text,
        DateTime? createdAt,
        String? postId,
        String? uid,
        String? username,
        String? profilePic,
        List<String>? likes,
        List<Comment>? replies,
        bool? isReply,
        String? parentCommentId}) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      uid: uid ?? this.uid,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      isReply: isReply ?? this.isReply,
      parentCommentId: parentCommentId ?? this.parentCommentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'username': username,
      'uid': uid,
      'profilePic': profilePic,
      'likes': likes,
      'replies': replies,
      'isReply': isReply,
      'parentCommentId': parentCommentId,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
      likes: map['likes'] ?? [],
      replies:
      List<Comment>.from(map["replies"]!.map((x) => Comment.fromMap(x))),
      isReply: map['isReply'],
      uid: map['uid'],
      parentCommentId: map['parentCommentId'],
    );
  }

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, username: $username, profilePic: $profilePic, likes : $likes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Comment &&
        other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.postId == postId &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.likes == likes &&
        other.replies == replies &&
        other.isReply == isReply &&
        other.parentCommentId == parentCommentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    text.hashCode ^
    createdAt.hashCode ^
    postId.hashCode ^
    username.hashCode ^
    profilePic.hashCode ^
    likes.hashCode ^
    replies.hashCode;
  }
}
