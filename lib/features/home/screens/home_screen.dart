import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reddit/core/common/helper_functions.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/home/delegates/search_community_delegate.dart';
import 'package:reddit/features/home/drawers/community_list_drawer.dart';
import 'package:reddit/features/home/drawers/profile_drawer.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../notifications/local_notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void displayEndDrawer(BuildContext context, bool isGuest) {
    if (isGuest) {
      notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
      return;
    }
    Scaffold.of(context).openEndDrawer();
  }


  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService()
          .showNotificationWithPayload(message: event);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => displayDrawer(context),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context, delegate: SearchCommunityDelegate(ref));
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              if (isGuest) {
                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                return;
              }
              Routemaster.of(context).push('/add-post');
            },
            icon: const Icon(Icons.add),
          ),
          Builder(builder: (context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePic),
              ),
              onPressed: () => displayEndDrawer(context, isGuest),
            );
          }),
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: Constants.currentPage,
        builder: (context , page , _) {
          return Constants.tabWidgets[page];
        }
      ),
      drawer: const CommunityListDrawer(),
      endDrawer: ProfileDrawer(),
      bottomNavigationBar: isGuest || kIsWeb
          ? null
          : ValueListenableBuilder<int>(
        valueListenable: Constants.currentPage,
            builder: (context , page , _) {
              return CupertinoTabBar(
                  activeColor: currentTheme.iconTheme.color,
                  backgroundColor: currentTheme.dialogBackgroundColor,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: '',
                    ),
                  ],
                  onTap: (index){
                    Constants.currentPage.value = index;
                  },
                  currentIndex: page,
                );
            }
          ),
    );
  }
}
