import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../auth/controlller/auth_controller.dart';
import '../../user_profile/controller/user_profile_controller.dart';

class PostScreenForReview extends ConsumerWidget {
  const PostScreenForReview ({super.key, required this.postId , required this.notification});

  final String postId;
  final Map<String , String> notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: ref.watch(getPostByIdProvider(postId)).when(
              data: (post) {
                return Column(
                  children: [
                    PostCard(post: post , hideVotingAndComment: true,),
                    SizedBox(height: 15,),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                      child: Text(
                                        'Accept',
                                        style:
                                        TextStyle(color: Colors.white, fontSize: 16),
                                      ))),
                              onTap: () {
                                ref
                                    .read(postControllerProvider.notifier)
                                    .updatePostStatus(notification['postId']!);
                                String myId = ref.read(userProvider)!.uid;
                                String userName = ref.read(userProvider)!.firstName + ref.read(userProvider)!.lastName ;
                                ref
                                    .read(postControllerProvider.notifier)
                                    .sendNotificationForUploadingPostUser(
                                    userName,
                                    myId,
                                    notification['senderId']!,
                                    notification['postId']!,
                                    notification['communityName']!,
                                    true);
                                ref
                                    .read(userProfileControllerProvider.notifier)
                                    .updateNotification(
                                    notification['id']!, 'you accepted this post');
                                Navigator.of(context).pop();
                              }),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: GestureDetector(
                              child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                      child: Text(
                                        'Reject',
                                        style:
                                        TextStyle(color: Colors.white, fontSize: 16),
                                      ))),
                              onTap: () {
                                String myId = ref.read(userProvider)!.uid;
                                String userName = ref.read(userProvider)!.firstName + ref.read(userProvider)!.lastName;
                                ref
                                    .read(postControllerProvider.notifier)
                                    .sendNotificationForUploadingPostUser(
                                    userName,
                                    myId,
                                    notification['senderId']!,
                                    notification['postId']!,
                                    notification['communityName']!,
                                    false);
                                ref
                                    .read(userProfileControllerProvider.notifier)
                                    .updateNotification(
                                    notification['id']!, 'you rejected this post');
                                Navigator.of(context).pop();
                              }),
                        )
                      ],
                    )

                  ],
                );
              },
              error: (error, stackTrace) {
                return ErrorText(error: error.toString());
              },
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
