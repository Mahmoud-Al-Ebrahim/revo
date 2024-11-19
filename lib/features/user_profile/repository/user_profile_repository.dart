import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/notification_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';

import '../../../core/providers/firebase_providers.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _notifications =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
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

  Stream<List<MyNotification>> getUserNotifications(String uid) {
    return _notifications
        .where('receiverId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) {
                  print(e.data());
                  return MyNotification.fromMap(
                    e.data() as Map<String, dynamic>,
                  );
                },
              )
              .toList(),
        );
  }

  Stream<List<UserModel>> getUserFriends(List<String> uids) {
    return _users
        .where('uid',whereIn: uids)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) {
                  return UserModel.fromMap(
                    e.data() as Map<String, dynamic>,
                  );
                },
              )
              .toList(),
        );
  }

  void updateNotification(String notificationId , String answer) async {
    _notifications.doc(notificationId).update({
      'answer': answer
    });
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karma': user.karma,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateUserFriends(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'friends': user.friends,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateUserWallet(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'walletBalance': user.walletBalance,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateUserFcmToken(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'fcmToken': user.fcmToken,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
