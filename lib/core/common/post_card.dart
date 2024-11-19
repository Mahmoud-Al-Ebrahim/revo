import 'dart:math';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/helper_functions.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/app/vedio_player.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/responsive/responsive.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

import '../../features/app/post_reaction_button/reaction_button.dart';
import '../utils.dart';

class PostCard extends ConsumerWidget {
  final Post post;

  PostCard({
    super.key,
    required this.post,
    this.hideVotingAndComment = false,
  });

  final bool hideVotingAndComment;

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref , BuildContext context) async {
    ref.read(postControllerProvider.notifier).upvote(post);
    showSnackBar(context , 'You Voted UP, The Positive Votes Will Be Increased');
  }

  void downvotePost(WidgetRef ref , BuildContext context) async {
    ref.read(postControllerProvider.notifier).downvote(post);
    showSnackBar(context , 'You Voted DOWN, The Negative Votes Will Be Increased');
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/',queryParameters: {"name"  : post.communityName});
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  final ValueNotifier<int> mode = ValueNotifier(0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeVideo = post.type == 'video';
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    final currentTheme = ref.watch(themeNotifierProvider);

    return Responsive(
      child: GestureDetector(
        onTap: () {
          mode.value = 0;
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: currentTheme.drawerTheme.backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kIsWeb)
                    Column(
                      children: [
                        IconButton(
                          onPressed: isGuest
                              ? () {
                                  notifyDialog(context,
                                      'You are a Guest Right Now , Please Sign In to Continue');
                                }
                              : () => upvotePost(ref,context),
                          icon: Icon(
                            Constants.up,
                            size: 30,
                            color: post.upvotes.contains(user.uid)
                                ? Pallete.blueColor
                                : null,
                          ),
                        ),
                        Text(
                          '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                          style: const TextStyle(fontSize: 17),
                        ),
                        IconButton(
                          onPressed: isGuest
                              ? () {
                                  notifyDialog(context,
                                      'You are a Guest Right Now , Please Sign In to Continue');
                                }
                              : () => downvotePost(ref,context),
                          icon: Icon(
                            Constants.down,
                            size: 30,
                            color: post.downvotes.contains(user.uid)
                                ? Pallete.redColor
                                : null,
                          ),
                        ),
                      ],
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            navigateToCommunity(context),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            post.communityProfilePic,
                                          ),
                                          radius: 16,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${post.communityName}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  navigateToUser(context),
                                              child: Text(
                                                '${post.username}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(children: [
                                    GestureDetector(
                                        onTap: () {
                                          notifyDialog(context,
                                              'Post is Where You or Someone share its knowledge about a specific idea of the community concept');
                                        },
                                        child: Icon(Icons.info_outline,
                                            size: 30,
                                            color: Colors.deepOrange)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    if (post.uid == user.uid)
                                      IconButton(
                                        onPressed: () =>
                                            deletePost(ref, context),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Pallete.redColor,
                                        ),
                                      ),
                                  ])
                                ],
                              ),
                              if (post.awards.isNotEmpty) ...[
                                const SizedBox(height: 5),
                                SizedBox(
                                  height: 25,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.awards.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final award = post.awards[index];
                                      return Image.asset(
                                        Constants.awards[award]!,
                                        height: 23,
                                      );
                                    },
                                  ),
                                ),
                              ],
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isTypeVideo)
                                MYVideoPlayer(videoUrl: post.link!),
                              if (isTypeImage)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                          0.35,
                                  width: double.infinity,
                                  child: Image.network(
                                    post.link!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (isTypeLink)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  child: AnyLinkPreview(
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                    link: post.link!,
                                  ),
                                ),
                              if (isTypeText)
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Text(
                                    post.description!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              if (!hideVotingAndComment)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (!kIsWeb)
                                          Row(
                                            children: [
                                              Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                children: [
                                                  IconButton(
                                                    onPressed: isGuest
                                                        ? () {
                                                            notifyDialog(
                                                                context,
                                                                'You are a Guest Right Now , Please Sign In to Continue');
                                                          }
                                                        : () =>
                                                            upvotePost(ref,context),
                                                    icon: Icon(
                                                      Constants.up,
                                                      size: 30,
                                                      color: post.upvotes
                                                              .contains(
                                                                  user.uid)
                                                          ? Pallete
                                                              .blueColor
                                                          : null,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${post.upvotes.isEmpty ? 'Vote' : post.upvotes.length}',
                                                    style: const TextStyle(
                                                        fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                children: [
                                                  IconButton(
                                                    onPressed: isGuest
                                                        ? () {
                                                            notifyDialog(
                                                                context,
                                                                'You are a Guest Right Now , Please Sign In to Continue');
                                                          }
                                                        : () =>
                                                            downvotePost(
                                                                ref,context),
                                                    icon: Icon(
                                                      Constants.down,
                                                      size: 30,
                                                      color: post.downvotes
                                                              .contains(
                                                                  user.uid)
                                                          ? Pallete.redColor
                                                          : null,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${post.downvotes.isEmpty ? 'Vote' : post.downvotes.length}',
                                                    style: const TextStyle(
                                                        fontSize: 17),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  navigateToComments(
                                                      context),
                                              icon: const Icon(
                                                Icons.comment,
                                              ),
                                            ),
                                            Text(
                                              '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                              style: const TextStyle(
                                                  fontSize: 17),
                                            ),
                                          ],
                                        ),
                                        ref
                                            .watch(
                                                getCommunityByNameProvider(
                                                    post.communityName))
                                            .when(
                                              data: (data) {
                                                if (data.mods.contains(
                                                        user.uid) ||
                                                    post.uid == user.uid) {
                                                  return IconButton(
                                                    onPressed: () =>
                                                        deletePost(
                                                            ref, context),
                                                    icon: const Icon(
                                                      Icons.delete,
                                                    ),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                              error: (error, stackTrace) =>
                                                  ErrorText(
                                                error: error.toString(),
                                              ),
                                              loading: () => const Loader(),
                                            ),
                                        IconButton(
                                          onPressed: isGuest
                                              ? () {
                                                  notifyDialog(context,
                                                      'You are a Guest Right Now , Please Sign In to Continue');
                                                }
                                              : () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: GridView
                                                            .builder(
                                                          shrinkWrap: true,
                                                          gridDelegate:
                                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount:
                                                                4,
                                                          ),
                                                          itemCount: user
                                                                  .awards
                                                                  .length +
                                                              1,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            if (index ==
                                                                (user.awards
                                                                    .length)) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  Routemaster.of(
                                                                          context)
                                                                      .pop();
                                                                  Routemaster.of(
                                                                          context)
                                                                      .push(
                                                                          '/buy-awards-screen');
                                                                },
                                                                child:
                                                                    Padding(
                                                                  padding: const EdgeInsets
                                                                      .all(
                                                                      8.0),
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius:
                                                                        30,
                                                                    backgroundColor:
                                                                        Colors.deepOrangeAccent,
                                                                    child: Center(
                                                                        child: Icon(
                                                                      Icons
                                                                          .add,
                                                                      color:
                                                                          Colors.white,
                                                                    )),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                            final award =
                                                                user.awards[
                                                                    index];
                                                            return GestureDetector(
                                                              onTap: () =>
                                                                  awardPost(
                                                                      ref,
                                                                      award,
                                                                      context),
                                                              child: Image
                                                                  .asset(
                                                                Constants
                                                                        .awards[
                                                                    award]!,
                                                                width: 50,
                                                                height: 50,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                          icon: const Icon(
                                              Icons.card_giftcard_outlined),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ReactionButton(
                                      mode: mode,
                                      post: post,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
