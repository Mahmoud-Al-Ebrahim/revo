import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/user_model.dart';

import '../../../core/common/helper_functions.dart';
import '../../notifications/notification_process.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel?> createAccountWithGoogle(
      BuildContext context, bool isFromLogin,
      {String? firstName, String? lastName, String? birthDate}) async {
    try {
      UserCredential userCredential;
      User user;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      }
      {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);

          user = userCredential.user!;
        } else {
          try {
            userCredential =
                await _auth.currentUser!.linkWithCredential(credential);
          } on FirebaseAuthException catch (e) {
            if (e.code == 'credential-already-in-use') {
              return left(Failure('Google account is already linked.'));
            } else {
              rethrow;
            }
          }
          user = userCredential.user!;
        }
      }
      UserModel userModel;
      //userCredential.additionalUserInfo!.isNewUser ||
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          firstName: firstName!,
          lastName: lastName!,
          birthDate: birthDate!,
          profilePic: user.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          fcmToken: NotificationProcess.myFcmToken ?? '',
          uid: user.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userModel.uid).set(userModel.toMap());
        return right(userModel);
      } else {
        toastMessage('this email already used , try log in');
        logOut();
        return Left(Failure('this email already used , try log in'));
      }
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel?> signInWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential;
      User? user;
      {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        );

        userCredential = await _auth.signInWithCredential(credential);

        user = userCredential.user;
      }
      print('userCredential $userCredential');
      UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _auth.currentUser!.delete();
        await _googleSignIn.signOut();
        toastMessage(
            'there is no account with this email , try create account');
        logOut();
        return Left(Failure(
            'there is no account with this email , try create account'));
      } else {
        userModel = await getUserData(user!.uid).first;
        return right(userModel);
      }
    } on FirebaseException catch (e) {
      return left(Failure(e.toString()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user!;

      final userModel = UserModel(
        firstName: 'Guest',
        lastName: '.revo',
        birthDate: 'UnSpecified',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: user.uid,
        isAuthenticated: false,
        fcmToken: NotificationProcess.myFcmToken ?? '',
        karma: 0,
        awards: [],
      );
      await _users.doc(userModel.uid).set(userModel.toMap());
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
        (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<List<String>> getAllTokens(List<String> usersId) {
    return _users
        .where(
          'uid',
          whereIn: usersId,
        )
        .snapshots()
        .map((event) {
      var tokens = event.docs
          .map((e) =>
              UserModel.fromMap(e.data() as Map<String, dynamic>).fcmToken)
          .toList();
      return tokens;
    });
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
