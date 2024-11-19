import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/helper_functions.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../app/post_reaction_button/const.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;

  const CommunityScreen({super.key, required this.name});

  // http://localhost:4000/r/flutter

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context)
        .push('/mod-tools/', queryParameters: {"name": name});
  }

  void navigateToChooseFriendsToInviteScreen(BuildContext context) {
    Routemaster.of(context)
        .push('/choose-friends-to-invite/', queryParameters: {"name": name});
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  void likeCommunity(WidgetRef ref, bool giveLike) async {
    ref
        .read(communityControllerProvider.notifier)
        .likeCommunity(name, giveLike);
  }

  void deleteCommunity(WidgetRef ref, BuildContext context) async {
    ref
        .read(communityControllerProvider.notifier)
        .deleteCommunity(name, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
            data: (community) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 150,
                    floating: true,
                    snap: true,
                    flexibleSpace: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            community.banner,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                            top: 30,
                            right: 10,
                            child: Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      notifyDialog(context,
                                          'Community is Where the people learn and share its information about a specific concept.');
                                    },
                                    child: Icon(Icons.info_outline,
                                        size: 40, color: Colors.purple)),
                                if (user.uid == community.ownerId) ...{
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                      onTap: () async{
                                        await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Are You Sure you want to delete ${name} community?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    deleteCommunity(ref , context);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('YES')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('NO')),
                                            ],
                                          );
                                        });
                                      },
                                      child: Icon(Icons.delete,
                                          size: 25, color: Colors.purple)),
                                }
                              ],
                            ))
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${community.name}',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (isGuest) {
                                        notifyDialog(context,
                                            'You are a Guest Right Now , Please Sign In to Continue');
                                        return;
                                      }
                                      if (community.likes.contains(user.uid)) {
                                        likeCommunity(ref, false);
                                      } else {
                                        likeCommunity(ref, true);
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          community.likes.contains(user.uid)
                                              ? "assets/interactions/ic_like_fill.png"
                                              : AssetImages.icLike,
                                          width: 20,
                                          height: 20,
                                          color:
                                              community.likes.contains(user.uid)
                                                  ? null
                                                  : Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '${community.likes.length} Like',
                                          style: TextStyle(
                                              color: community.likes
                                                      .contains(user.uid)
                                                  ? Color(0xff3b5998)
                                                  : Theme.of(context)
                                                      .iconTheme
                                                      .color),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if (!isGuest)
                                community.mods.contains(user.uid)
                                    ? OutlinedButton(
                                        onPressed: () {
                                          navigateToModTools(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25),
                                        ),
                                        child: const Text('Mod Tools'),
                                      )
                                    : OutlinedButton(
                                        onPressed: community.blockMembers
                                                .contains(user.uid)
                                            ? null
                                            : () => joinCommunity(
                                                ref, community, context),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25),
                                        ),
                                        child: Text(community.blockMembers
                                                .contains(user.uid)
                                            ? 'Blocked'
                                            : community.members
                                                    .contains(user.uid)
                                                ? 'Joined'
                                                : 'Join'),
                                      ),
                            ],
                          ),
                          if (community.members.contains(user.uid)) ...{
                            SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.mail_outline,
                                color: Colors.purple,
                              ),
                              title: const Text(
                                'Send Invites',
                                style:
                                    TextStyle(color: Colors.purple),
                              ),
                              onTap: () =>
                                  navigateToChooseFriendsToInviteScreen(
                                      context),
                            ),
                          },
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Bio: ${community.bio}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              '${community.members.length} members',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: community.blockMembers.contains(user.uid)
                  ? Center(
                      child: Text(
                        'Content Forbidden!',
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    )
                  : ref.watch(getCommunityPostsProvider(name)).when(
                        data: (data) {
                          return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final post = data[index];
                              return PostCard(post: post);
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
