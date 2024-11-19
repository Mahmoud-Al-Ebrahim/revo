import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/models/notification_model.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';
import '../../../models/comment_model.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';

final postRepositoryProvider = Provider((ref) {
  return PostRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class PostRepository {
  final FirebaseFirestore firestore;

  PostRepository({required FirebaseFirestore firestore})
      : firestore = firestore;

  CollectionReference get _posts =>
      firestore.collection(FirebaseConstants.postsCollection);

  CollectionReference get _comments =>
      firestore.collection(FirebaseConstants.commentsCollection);

  CollectionReference get _users =>
      firestore.collection(FirebaseConstants.usersCollection);

  CollectionReference get _notifications =>
      firestore.collection(FirebaseConstants.notificationsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addNotification(MyNotification myNotification) async {
    try {
      return right(
          _notifications.doc(myNotification.id).set(myNotification.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities , String uid) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .where('isShowEnabled', isEqualTo: true)
        .orderBy('upVotesCount', descending: true)
        .orderBy('downVotesCount', descending: false)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _posts
        .where('isShowEnabled', isEqualTo: true)
        .orderBy('upVotesCount', descending: true)
        .orderBy('downVotesCount', descending: false)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void giveReaction(Post post, String userId, int reaction , bool removeReaction) async {
    // if (post.downvotes.contains(userId)) {
    //   _posts.doc(post.id).update({
    //     'downvotes': FieldValue.arrayRemove([userId]),
    //     'totalVotes': FieldValue.increment(2),
    //     'downVotesCount': FieldValue.increment(-1),
    //   });
    // }
    // if (post.upvotes.contains(userId)) {
    //   _posts.doc(post.id).update({
    //     'upvotes': FieldValue.arrayRemove([userId]),
    //     'upVotesCount': FieldValue.increment(-1),
    //     'totalVotes': FieldValue.increment(-2)
    //   });
    // }
    if (post.likes.contains(userId)) {
      _posts.doc(post.id).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.wow.contains(userId)) {
      _posts.doc(post.id).update({
        'wow': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.loves.contains(userId)) {
      _posts.doc(post.id).update({
        'loves': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.angry.contains(userId)) {
      _posts.doc(post.id).update({
        'angry': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.haha.contains(userId)) {
      _posts.doc(post.id).update({
        'haha': FieldValue.arrayRemove([userId]),
      });
    }
    if (post.sad.contains(userId)) {
      _posts.doc(post.id).update({
        'sad': FieldValue.arrayRemove([userId]),
      });
    }

    if(removeReaction) return;

    switch (reaction) {
      case 0:
        _posts.doc(post.id).update({
          'likes': FieldValue.arrayUnion([userId]),
        });
        break;
      case 1:
        _posts.doc(post.id).update({
          'loves': FieldValue.arrayUnion([userId]),
        });
        break;
      case 2:
        _posts.doc(post.id).update({
          'angry': FieldValue.arrayUnion([userId]),
        });
        break;
      case 3:
        _posts.doc(post.id).update({
          'sad': FieldValue.arrayUnion([userId]),
        });
        break;
      case 4:
        _posts.doc(post.id).update({
          'haha': FieldValue.arrayUnion([userId]),
        });
        break;
      case 5:
        _posts.doc(post.id).update({
          'wow': FieldValue.arrayUnion([userId]),
        });
        break;
    }
  }

  void upvote(Post post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
        'totalVotes': FieldValue.increment(2),
        'downVotesCount': FieldValue.increment(-1),
      });
    }

    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
        'upVotesCount': FieldValue.increment(-1),
        'totalVotes': FieldValue.increment(-2)
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
        'upVotesCount': FieldValue.increment(1),
        'totalVotes': FieldValue.increment(1)
      });
    }
  }

  void updatePostStatus(String postId) async {
    _posts.doc(postId).update({'isShowEnabled': true});
  }

  void downvote(Post post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
        'upVotesCount': FieldValue.increment(-1),
        'totalVotes': FieldValue.increment(-2)
      });
    }

    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
        'downVotesCount': FieldValue.increment(-1),
        'totalVotes': FieldValue.increment(2)
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
        'downVotesCount': FieldValue.increment(1),
        'totalVotes': FieldValue.increment(-1)
      });
    }
  }

  Stream<Post> getPostById(String postId) {
    return _posts
        .doc(postId)
        .snapshots()
        .map((event) => Post.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());

      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  addReply(Comment reply, String parentCommentId) async {
    try {
      await _comments.doc(parentCommentId).update({
        'replies': FieldValue.arrayUnion([reply.toMap()])
      });
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfPost(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .where('isReply', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Stream<List<Comment>> getCommentReplies(String commentId) {
    return _comments
        .where('parentCommentId', isEqualTo: commentId)
        .where('isReply', isEqualTo: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  awardPost(Post post, String award, String senderId) async {
    try {
      _posts.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award]),
      });
      return right(_users.doc(post.uid).update({
        'awards': FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
