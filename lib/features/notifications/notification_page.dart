import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/notifications/notification_card.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';



class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({Key? key , required this.uid,}) : super(key: key);
  final String uid;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      ref.refresh(getUserNotificationsProvider(widget.uid));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(widget.uid)).when(
            data: (user) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 60,
                    floating: true,
                    snap: true,
                    flexibleSpace: Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          'My Notification',
                          style:
                              TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getUserNotificationsProvider(widget.uid)).when(
                    data: (data) {
                      return ListView.builder(
                        itemCount: data.length,
                        padding: EdgeInsets.all(10),
                        itemBuilder: (BuildContext context, int index) {
                          final notification = data[index];
                          return NotificationCard(notification: notification);
                        },
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorText(error: error.toString());
                    },
                    loading: () => const Loader(),
                  ),
            ),
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
