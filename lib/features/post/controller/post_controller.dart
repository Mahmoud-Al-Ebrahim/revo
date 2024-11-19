import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/models/notification_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/enums.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../models/comment_model.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';
import '../../auth/controlller/auth_controller.dart';
import '../../notifications/notification_process.dart';
import '../../user_profile/controller/user_profile_controller.dart';
import '../repository/post_repository.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final user = ref.watch(userProvider)!;
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities, user.uid);
});

final guestPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});
final getCommentRepliesProvider =
    StreamProvider.family((ref, String commentId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchCommentReplies(commentId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository? storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository!,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      downVotesCount: 0,
      upVotesCount: 0,
      commentCount: 0,
      username: user.firstName + ' ' + user.lastName,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      isShowEnabled: selectedCommunity.ownerId == user.uid ||
          selectedCommunity.mods.contains(user.uid),
      description: description,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(
          context,
          selectedCommunity.ownerId == user.uid ||
                  selectedCommunity.mods.contains(user.uid)
              ? 'Posted successfully!'
              : 'The post is currently pending, waiting for the admin to accept it');
      if (selectedCommunity.ownerId != user.uid &&
          !selectedCommunity.mods.contains(user.uid)) {
        sendNotificationForAcceptOrRejectPost(selectedCommunity,
            '${user.firstName} ${user.lastName}', user.uid, postId);
      } else {
        sendNotificationAfterUploadPost(
            selectedCommunity, '${user.firstName} ${user.lastName}', user.uid);
      }
      Constants.currentPage.value = 0;
      Navigator.of(context)
        ..pop()
        ..pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      downVotesCount: 0,
      upVotesCount: 0,
      username: '${user.firstName} ${user.lastName}',
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      isShowEnabled: selectedCommunity.ownerId == user.uid ||
          selectedCommunity.mods.contains(user.uid),
      link: link,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(
          context,
          selectedCommunity.ownerId == user.uid ||
                  selectedCommunity.mods.contains(user.uid)
              ? 'Posted successfully!'
              : 'The post is currently pending, waiting for the admin to accept it');
      if (selectedCommunity.ownerId != user.uid &&
          !selectedCommunity.mods.contains(user.uid)) {
        sendNotificationForAcceptOrRejectPost(selectedCommunity,
            '${user.firstName} ${user.lastName}', user.uid, postId);
      } else {
        sendNotificationAfterUploadPost(
            selectedCommunity, '${user.firstName} ${user.lastName}', user.uid);
      }
      Constants.currentPage.value = 0;
      Navigator.of(context)
        ..pop()
        ..pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required Uint8List? webFile,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
      webFile: webFile,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        downVotesCount: 0,
        upVotesCount: 0,
        commentCount: 0,
        username: '${user.firstName} ${user.lastName}',
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        isShowEnabled: selectedCommunity.ownerId == user.uid ||
            selectedCommunity.mods.contains(user.uid),
        link: r,
      );

      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(
            context,
            selectedCommunity.ownerId == user.uid ||
                    selectedCommunity.mods.contains(user.uid)
                ? 'Posted successfully!'
                : 'The post is currently pending, waiting for the admin to accept it');
        if (selectedCommunity.ownerId != user.uid &&
            !selectedCommunity.mods.contains(user.uid)) {
          sendNotificationForAcceptOrRejectPost(selectedCommunity,
              '${user.firstName} ${user.lastName}', user.uid, postId);
        } else {
          sendNotificationAfterUploadPost(selectedCommunity,
              '${user.firstName} ${user.lastName}', user.uid);
        }
        Constants.currentPage.value = 0;
        Navigator.of(context)
          ..pop()
          ..pop();
      });
    });
  }

  void shareVideoPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final videoRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
      webFile: null,
    );

    videoRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        downVotesCount: 0,
        upVotesCount: 0,
        commentCount: 0,
        username: '${user.firstName} ${user.lastName}',
        uid: user.uid,
        type: 'video',
        createdAt: DateTime.now(),
        awards: [],
        isShowEnabled: selectedCommunity.ownerId == user.uid ||
            selectedCommunity.mods.contains(user.uid),
        link: r,
      );

      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.videoPost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(
            context,
            selectedCommunity.ownerId == user.uid ||
                    selectedCommunity.mods.contains(user.uid)
                ? 'Posted successfully!'
                : 'The post is currently pending, waiting for the admin to accept it');
        if (!selectedCommunity.mods.contains(user.uid)) {
          sendNotificationForAcceptOrRejectPost(selectedCommunity,
              '${user.firstName} ${user.lastName}', user.uid, postId);
        } else {
          sendNotificationAfterUploadPost(selectedCommunity,
              '${user.firstName} ${user.lastName}', user.uid);
        }
        Constants.currentPage.value = 0;
        Navigator.of(context)
          ..pop()
          ..pop();
      });
    });
  }

  void sendNotificationForAcceptOrRejectPost(Community selectedCommunity,
      String userName, String myId, String postId) {
    List<String> ids = selectedCommunity.mods;
    String id = const Uuid().v4();
    String notificationContent =
        '$userName wants to add a Post in ${selectedCommunity.name} Community';
    ids.forEach((adminId) {
      _postRepository.addNotification(MyNotification(
          id: id,
          senderId: myId,
          content: notificationContent,
          postId: postId,
          receiverId: adminId,
          communityName: selectedCommunity.name,
          createdAt: DateTime.now(),
          isForAcceptAPost: true));
    });

    _ref.listen(
      getAllTokens(ids),
      (previous, next) {
        if (next.value != null) {
          NotificationProcess.sendNotifications(
            tokens: next.value!,
            senderUserName: userName,
            description: notificationContent,
          );
        }
      },
    );
  }

  void sendNotificationAfterUploadPost(
      Community selectedCommunity, String userName, String myId) {
    List<String> ids = selectedCommunity.members;
    ids.remove(myId);
    _ref.listen(
      getAllTokens(ids),
      (previous, next) {
        if (next.value != null) {
          NotificationProcess.sendNotifications(
            tokens: next.value!,
            senderUserName: userName,
            description:
                '$userName added a Post in ${selectedCommunity.name} Community',
          );
        }
      },
    );
  }

  void sendNotificationForUploadingPostUser(String userName, String myId,
      String receiverId, String postId, String communityName, bool isAccepted) {
    List<String> ids = [receiverId];
    String id = const Uuid().v4();
    String notificationContent =
        '$userName ${isAccepted ? 'approved' : 'rejected'} your post in $communityName';
    _postRepository.addNotification(MyNotification(
        id: id,
        senderId: myId,
        postId: postId,
        content: notificationContent,
        receiverId: receiverId,
        communityName: communityName,
        createdAt: DateTime.now(),
        isForAcceptAPost: true,
        answer: ''));
    _ref.listen(
      getAllTokens(ids),
      (previous, next) {
        if (next.value != null) {
          NotificationProcess.sendNotifications(
            tokens: next.value!,
            senderUserName: userName,
            description: notificationContent,
          );
        }
      },
    );
    if (isAccepted) {
      _ref.listen(getCommunityByNameProvider(communityName),
          (previous, community) {
        if (community.value != null) {
          ids = community.value!.members;
          ids.remove(myId);
          ids.remove(receiverId);
          _ref.listen(
            getAllTokens(ids),
            (previous, next) {
              if (next.value != null) {
                NotificationProcess.sendNotifications(
                  tokens: next.value!,
                  senderUserName: userName,
                  description:
                      '$userName added a Post in ${community.value!.name} Community',
                );
              }
            },
          );
        }
      });
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities, String uid) {
    try {
      communities.removeWhere((element) => element.blockMembers.contains(uid));
    } catch (e, st) {
      print(e);
    }
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities, uid);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold((l) => null,
        (r) => showSnackBar(context, 'Post Deleted successfully!'));
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void giveReaction(
      Post post, String userId, int reaction, bool removeReaction) async {
    _postRepository.giveReaction(post, userId, reaction, removeReaction);
  }

  void updatePostStatus(String postId) async {
    _postRepository.updatePostStatus(postId);
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addReply({
    required BuildContext context,
    required String text,
    required String parentCommentId,
    String? commentIdForReplyStatus,
    required String postId,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = commentIdForReplyStatus ?? const Uuid().v1();
    Comment replay = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: postId,
        username: '${user.firstName} ${user.lastName}',
        profilePic: user.profilePic,
        uid: user.uid,
        isReply: true,
        likes: [],
        replies: []);
    await _postRepository.addReply(replay, parentCommentId);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
  }

  void addComment({
    required BuildContext context,
    required String text,
    String? parentCommentId,
    String? commentIdForReplyStatus,
    bool isReply = false,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = commentIdForReplyStatus ?? const Uuid().v1();
    Comment comment = Comment(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: '${user.firstName} ${user.lastName}',
        profilePic: user.profilePic,
        uid: user.uid,
        isReply: isReply,
        likes: [],
        replies: [],
        parentCommentId: parentCommentId);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(post, award, user.uid);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  Stream<List<Comment>> fetchCommentReplies(String commentId) {
    return _postRepository.getCommentReplies(commentId);
  }
}
