// loggedOut
// loggedIn

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reddit/features/auth/screens/login_screen.dart';
import 'package:reddit/features/community/screens/add_mods_screen.dart';
import 'package:reddit/features/community/screens/community_members_screen.dart';
import 'package:reddit/features/community/screens/community_screen.dart';
import 'package:reddit/features/community/screens/create_community_screen.dart';
import 'package:reddit/features/community/screens/edit_community_screen.dart';
import 'package:reddit/features/community/screens/mod_tools_screen.dart';
import 'package:reddit/features/home/screens/home_screen.dart';
import 'package:reddit/features/on%20boarding/on_boarding_screen.dart';
import 'package:reddit/features/post/screens/add_post_screen.dart';
import 'package:reddit/features/post/screens/add_post_type_screen.dart';
import 'package:reddit/features/post/screens/comments_screen.dart';
import 'package:reddit/features/post/screens/post_screen_for_review.dart';
import 'package:reddit/features/post/screens/replies_screen.dart';
import 'package:reddit/features/user_profile/screens/edit_profile_screen.dart';
import 'package:reddit/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

import 'features/community/screens/choose_friends_to_invite.dart';
import 'features/community/screens/community_blocked_members.dart';
import 'features/notifications/notification_page.dart';
import 'features/post/screens/buy_awards_screen.dart';
import 'features/user_profile/screens/user_friends-screen.dart';



final loggedOutRouteWithOnBoardingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: OnBoardingScreen()),
  '/login-screen': (_) => const MaterialPage(
      child: LoginScreen()),
});

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/create-community': (_) =>
        const MaterialPage(child: CreateCommunityScreen()),
    '/r/': (route) => MaterialPage(
          child: CommunityScreen(
            name: route.queryParameters['name']!,
          ),
        ),
    '/mod-tools/': (routeData) => MaterialPage(
          child: ModToolsScreen(
            name: routeData.queryParameters['name']!,
          ),
        ),
    '/blocked-screen/': (routeData) => MaterialPage(
      child: CommunityBlockedMembersScreen(
        name: routeData.queryParameters['name']!,
      ),
    ),
    '/members-screen/': (routeData) => MaterialPage(
      child: CommunityMembersScreen(
        name: routeData.queryParameters['name']!,
      ),
    ),
    '/edit-community/': (routeData) => MaterialPage(
          child: EditCommunityScreen(
            name: routeData.queryParameters['name']!,
          ),
        ),
    '/add-mods/': (routeData) => MaterialPage(
          child: AddModsScreen(
            name: routeData.queryParameters['name']!,
          ),
        ),
    '/choose-friends-to-invite/': (routeData) => MaterialPage(
          child: ChooseFriendsToInviteScreen(
            communityName: routeData.queryParameters['name']!,
          ),
        ),
    '/u/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/notification/:uid': (routeData) => MaterialPage(
      child: NotificationScreen(
        uid: routeData.pathParameters['uid']!,
      ),
    ),
    '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/view-friends/:uid': (routeData) => MaterialPage(
          child: ViewFriendsScreen(
            uid: routeData.pathParameters['uid']!,
          ),
        ),
    '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(
            type: routeData.pathParameters['type']!,
          ),
        ),
    '/post/:postId/comments': (route) => MaterialPage(
          child: CommentsScreen(
            postId: route.pathParameters['postId']!,
          ),
        ),
    '/comments/:commentId/:postId/replies': (route) => MaterialPage(
          child: RepliesScreen(
            commentId: route.pathParameters['commentId']!,
            postId: route.pathParameters['postId']!,
          ),
        ),
    '/add-post': (routeData) => const MaterialPage(
          child: AddPostScreen(),
        ),
    '/post-screen/:postId': (route) => MaterialPage(
      child: PostScreenForReview(
        postId: route.pathParameters['postId']!,
        notification: route.queryParameters,
      ),
    ),
    '/buy-awards-screen': (route) => MaterialPage(
      child: BuyAwardsScreen(),
    ),
  },
);
