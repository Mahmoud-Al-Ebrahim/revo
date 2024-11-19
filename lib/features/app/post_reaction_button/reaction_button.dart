import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/theme/pallete.dart';

import '../../../core/common/helper_functions.dart';
import '../../../models/post_model.dart';
import '../../auth/controlller/auth_controller.dart';
import '../../post/controller/post_controller.dart';
import 'const.dart';


class ReactionButton extends ConsumerWidget {
     ReactionButton({super.key, required this.mode, required this.post});

  final ValueNotifier<int> mode;
  final Post post;

  final List<String> image =  [
    "assets/interactions/ic_like_fill.png",
    "assets/interactions/love2.png",
    "assets/interactions/angry2.png",
    "assets/interactions/sad2.png",
    "assets/interactions/haha2.png",
    "assets/interactions/wow2.png",
  ];
    final List<String> text =  ["Like", "Love", "Angry", "Sad", "Haha", "Wow"];
    final List<Color> colors =  [
    Color(0xff3b5998),
    Colors.redAccent,
    Colors.deepOrange,
    Colors.yellow,
    Colors.yellow,
    Colors.yellow,
  ];
   late String userId;


  void giveReaction(WidgetRef ref , int reaction, bool removeReaction) async {
    ref
        .read(postControllerProvider.notifier)
        .giveReaction(post, userId, reaction, removeReaction);
  }

  int getWhereIamReacted() {
    if (post.likes.contains(userId)) {
      return 0;
    } else if (post.loves.contains(userId)) {
      return 1;
    } else if (post.angry.contains(userId)) {
      return 2;
    } else if (post.sad.contains(userId)) {
      return 3;
    } else if (post.haha.contains(userId)) {
      return 4;
    } else if (post.wow.contains(userId)) {
      return 5;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context , WidgetRef ref) {
    userId = ref.watch(userProvider)!.uid;
    final isGuest = !ref.watch(userProvider)!.isAuthenticated;
    int focusedIndex = getWhereIamReacted();
    return ValueListenableBuilder<int>(
        valueListenable: mode,
        builder: (context, currentMode, _) {
          return SizedBox(
            height: currentMode != 0 ? 70 : 40,
            width: currentMode != 0 ? 280 : 90,
            child: GestureDetector(
              onLongPressStart: (details) {
                if(isGuest){
                  notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                  return;
                }
                mode.value = 1;
              },
              onLongPressCancel: () {
                if(isGuest){
                  notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                  return;
                }
                if (focusedIndex != -1) {
                  giveReaction(ref , focusedIndex, true);
                }else{
                  giveReaction(ref ,0, false);
                }
              },
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).iconTheme.color!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            focusedIndex >= 0
                                ? image[focusedIndex]
                                : AssetImages.icLike,
                            width: 20,
                            height: 20,
                            color:
                                focusedIndex >= 0 ? null : Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            focusedIndex >= 0
                                ? '${getCountOfReaction(focusedIndex)} ${text[focusedIndex]}'
                                : 'Like',
                            style: TextStyle(
                                color: focusedIndex >= 0
                                    ? colors[focusedIndex]
                                    : Theme.of(context).iconTheme.color),
                          )
                        ],
                      ),
                    ),
                  ),
                  currentMode == 1
                      ? Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                              child: Row(children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 225,
                                      height: 40,
                                      padding: EdgeInsets.symmetric(
                                           horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xfffafafa),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x29000000),
                                            offset: Offset(0, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MessageActionWidget(
                                            onTap: () {
                                              if(isGuest){
                                                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                                                return;
                                              }
                                              giveReaction(ref , 0, false);
                                              mode.value = 0;
                                            },
                                            iconUrl: AssetImages.likeGif,
                                            myIndex: 0,
                                            focusedIndex: focusedIndex,
                                          ),
                                          MessageActionWidget(
                                            onTap: () {
                                              if(isGuest){
                                                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                                                return;
                                              }
                                              giveReaction(ref , 1, false);
                                              mode.value = 0;
                                            },
                                            iconUrl: AssetImages.loveGif,
                                            myIndex: 1,
                                            focusedIndex: focusedIndex,
                                          ),
                                          MessageActionWidget(
                                            onTap: () {
                                              if(isGuest){
                                                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                                                return;
                                              }
                                              giveReaction(ref , 2, false);
                                              mode.value = 0;
                                            },
                                            iconUrl: AssetImages.angryGif,
                                            myIndex: 2,
                                            focusedIndex: focusedIndex,
                                          ),
                                          MessageActionWidget(
                                            onTap: () {
                                              if(isGuest){
                                                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                                                return;
                                              }
                                              giveReaction(ref , 3, false);
                                              mode.value = 0;
                                            },
                                            iconUrl: AssetImages.sadGif,
                                            myIndex: 3,
                                            focusedIndex: focusedIndex,
                                          ),
                                          MessageActionWidget(
                                            onTap: () {
                                              if(isGuest){
                                                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                                                return;
                                              }
                                              giveReaction(ref , 4, false);
                                              mode.value = 0;
                                            },
                                            iconUrl: AssetImages.hahaGif,
                                            myIndex: 4,
                                            focusedIndex: focusedIndex,
                                          ),
                                          MessageActionWidget(
                                            onTap: () {
                                              if(isGuest){
                                                notifyDialog(context , 'You are a Guest Right Now , Please Sign In to Continue');
                                                return;
                                              }
                                              giveReaction(ref , 5, false);
                                              mode.value = 0;
                                            },
                                            iconUrl: AssetImages.wowGif,
                                            myIndex: 5,
                                            focusedIndex: focusedIndex,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ])),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }

  int getCountOfReaction(int reaction) {
    switch (reaction) {
      case 0:
        return post.likes.length;
      case 1:
        return post.loves.length;
      case 2:
        return post.angry.length;
      case 3:
        return post.sad.length;
      case 4:
        return post.haha.length;
      default:
        return post.wow.length;
    }
  }
}

class MessageActionWidget extends StatelessWidget {
  const MessageActionWidget({
    Key? key,
    required this.onTap,
    required this.focusedIndex,
    required this.myIndex,
    required this.iconUrl,
  }) : super(key: key);
  final void Function() onTap;
  final int focusedIndex;
  final int myIndex;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 30,
        color: Colors.transparent,
        child: Image.asset(
          iconUrl,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
