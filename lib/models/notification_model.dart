class MyNotification {
  const MyNotification(
      {required this.id,
      required this.receiverId,
      required this.senderId,
      required this.content,
      required this.communityName,
      required this.postId,
      required this.createdAt,
      this.answer,
      this.inviteNotification = false,
      this.isForAcceptAPost = false});

  final String id;
  final String postId;
  final String communityName;
  final String content;
  final String receiverId;
  final String senderId;
  final String? answer;
  final DateTime createdAt;
  final bool isForAcceptAPost;
  final bool inviteNotification;

  MyNotification copyWith(
      {String? receiverId,
      String? id,
      String? content,
      String? answer,
      String? communityName,
      String? postId,
      String? senderId,
      bool? isForAcceptAPost,
      bool? inviteNotification,
      DateTime? createdAt}) {
    return MyNotification(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      content: content ?? this.content,
      communityName: communityName ?? this.communityName,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
      inviteNotification: inviteNotification ?? this.inviteNotification,
      answer: answer ?? this.answer,
      isForAcceptAPost: isForAcceptAPost ?? this.isForAcceptAPost,
    );
  }

  factory MyNotification.fromMap(Map<String, dynamic> map) {
    return MyNotification(
      id: map['id'],
      content: map['content'],
      senderId: map['senderId'],
      communityName: map['communityName'],
      postId: map['postId'],
      receiverId: map['receiverId'],
      answer: map['answer'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isForAcceptAPost: map['isForAcceptAPost'] ?? false,
      inviteNotification: map['inviteNotification'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'senderId': senderId,
      'answer': answer,
      'communityName': communityName,
      'receiverId': receiverId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isForAcceptAPost': isForAcceptAPost,
      'inviteNotification': inviteNotification,
    };
  }

  Map<String, String> toQueryParams() {
    return {
      'id': id,
      'postId': postId,
      'content': content,
      'senderId': senderId,
      'answer': answer ?? '',
      'communityName': communityName,
      'receiverId': receiverId,
      'createdAt': createdAt.millisecondsSinceEpoch.toString(),
      'isForAcceptAPost': isForAcceptAPost.toString(),
      'inviteNotification': inviteNotification.toString(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyNotification &&
        other.id == id &&
        other.content == content &&
        other.postId == postId &&
        other.communityName == communityName &&
        other.inviteNotification == inviteNotification &&
        other.receiverId == receiverId &&
        other.createdAt == createdAt &&
        other.isForAcceptAPost == isForAcceptAPost;
  }

  @override
  int get hashCode {
    return receiverId.hashCode ^
        id.hashCode ^
        communityName.hashCode ^
    inviteNotification.hashCode ^
        content.hashCode ^
        postId.hashCode ^
        isForAcceptAPost.hashCode ^
        createdAt.hashCode ^
    answer.hashCode;
  }
}
