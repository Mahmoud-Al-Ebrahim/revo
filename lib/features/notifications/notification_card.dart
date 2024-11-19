import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/notification_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../responsive/responsive.dart';
import '../../theme/pallete.dart';
import '../post/controller/post_controller.dart';

class NotificationCard extends ConsumerWidget {
  const NotificationCard({super.key, required this.notification});

  final MyNotification notification;

  @override
  Widget build(BuildContext context, ref) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return GestureDetector(
      onTap: notification.answer == null && notification.isForAcceptAPost
          ? () {
              Routemaster.of(context).push(
                  '/post-screen/${notification.postId}',
                  queryParameters: notification.toQueryParams());
            }
          : notification.inviteNotification &&  notification.answer == null
              ? () {
                  Routemaster.of(context).push('/r/',
                      queryParameters: {"name": notification.communityName});
                }
              : null,
      child: Responsive(
        child: Container(
          decoration: BoxDecoration(
            color: currentTheme.drawerTheme.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/logo.jpg'),
                    radius: 16,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      notification.content,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
              if (notification.answer != null) ...{
                Text(
                  notification.answer!,
                  style: TextStyle(fontSize: 17, color: Pallete.blueColor),
                ),
              } else if(notification.inviteNotification)...{
                GestureDetector(
                    child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                            child: Text(
                              'Ignore',
                              style:
                              TextStyle(color: Colors.white, fontSize: 16),
                            ))),
                    onTap: () {
                      ref
                          .read(userProfileControllerProvider.notifier)
                          .updateNotification(
                          notification.id, 'you Ignored this Invitation');
                    }),
              } else if (notification.isForAcceptAPost) ...{
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    GestureDetector(
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
                              .updatePostStatus(notification.postId);
                          String myId = ref.read(userProvider)!.uid;
                          String userName = ref.read(userProvider)!.firstName +
                              ref.read(userProvider)!.lastName;
                          ref
                              .read(postControllerProvider.notifier)
                              .sendNotificationForUploadingPostUser(
                                  userName,
                                  myId,
                                  notification.senderId,
                                  notification.postId,
                                  notification.communityName,
                                  true);
                          ref
                              .read(userProfileControllerProvider.notifier)
                              .updateNotification(
                                  notification.id, 'you accepted this post');
                        }),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
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
                          String userName = ref.read(userProvider)!.firstName +
                              ref.read(userProvider)!.lastName;
                          ref
                              .read(postControllerProvider.notifier)
                              .sendNotificationForUploadingPostUser(
                                  userName,
                                  myId,
                                  notification.senderId,
                                  notification.postId,
                                  notification.communityName,
                                  false);
                          ref
                              .read(userProfileControllerProvider.notifier)
                              .updateNotification(
                                  notification.id, 'you rejected this post');
                        })
                  ],
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}
