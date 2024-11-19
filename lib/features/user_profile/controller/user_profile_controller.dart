import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../models/notification_model.dart';
import '../../notifications/notification_process.dart';
import '../../post/repository/post_repository.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

final getUserNotificationsProvider = StreamProvider.family((ref, String uid) {
  return ref
      .read(userProfileControllerProvider.notifier)
      .getUserNotifications(uid);
});

final getUserFriendsProvider = StreamProvider.family((ref, List<String> uids) {
  return ref.read(userProfileControllerProvider.notifier).getUserFriends(uids);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required String firstName,
    required String lastName,
    String? bio,
    String? birthDate,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    if (profileFile != null || profileWebFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    if (bannerFile != null || bannerWebFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    user = user.copyWith(
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        birthDate: birthDate);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  Stream<List<MyNotification>> getUserNotifications(String uid) {
    return _userProfileRepository.getUserNotifications(uid);
  }

  Stream<List<UserModel>> getUserFriends(List<String> uids) {
    if (uids.isNotEmpty) {
      return _userProfileRepository.getUserFriends(uids);
    }
    return Stream.value([]);
  }

  void updateNotification(String notificationId, String answer) async {
    _userProfileRepository.updateNotification(notificationId, answer);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  void sendInviteNotifications(String communityName, List<String> friends,
      String myName, String myId, BuildContext context) {
    int i = 0;
    _ref.listen(
      getAllTokens(friends),
      (previous, next) {
        if (next.value != null) {
          String id = const Uuid().v4();
          _ref.watch(postRepositoryProvider).addNotification(MyNotification(
              id: id,
              senderId: myId,
              postId: 'not required here',
              content: '$myName Invites You to Join $communityName Community',
              receiverId: friends[i],
              communityName: communityName,
              createdAt: DateTime.now(),
              inviteNotification: true,
          ));
          i++;
          NotificationProcess.sendNotifications(
            tokens: next.value!,
            senderUserName: myName,
            description: '$myName Invites You to Join $communityName Community',
          );
        }
      },
    );
    if (i == friends.length) {
      Routemaster.of(context).pop();
    } else if (i == 0) {
      showSnackBar(context, 'Send Successfully');
    } else {
      showSnackBar(context, 'Send Successfully');
    }
  }

  void addOrRemoveFriend(String friendId) async {
    UserModel user = _ref.read(userProvider)!;
    List<String> friends = List.of(user.friends);
    bool delete = friends.contains(friendId);
    if (delete) {
      friends.remove(friendId);
    } else {
      friends.add(friendId);
    }
    user = user.copyWith(friends: friends);

    final res = await _userProfileRepository.updateUserFriends(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  void updateUserWallet(double amount) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(walletBalance: user.walletBalance - amount);

    final res = await _userProfileRepository.updateUserWallet(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }

  void updateUserFcmToken() async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(fcmToken: NotificationProcess.myFcmToken);

    final res = await _userProfileRepository.updateUserFcmToken(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
