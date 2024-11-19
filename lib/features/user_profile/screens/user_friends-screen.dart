import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

class ViewFriendsScreen extends ConsumerWidget {
  final String uid;

  const ViewFriendsScreen({
    super.key,
    required this.uid,
  });


  void addOrRemoveFriend(WidgetRef ref, String friendId,
      BuildContext context) async {
    ref
        .read(userProfileControllerProvider.notifier)
        .addOrRemoveFriend(friendId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
        data: (user) =>
            NestedScrollView(
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
                          'My Friends',
                          style:
                          TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: ref.watch(getUserFriendsProvider(me.friends)).when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (BuildContext context, int index) {
                      final UserModel user = users[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 45,
                              ),
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.star, size: 30,
                              color: me.friends.contains(user.uid)
                                  ? Colors.amber
                                  : Theme
                                  .of(context)
                                  .iconTheme
                                  .color,),
                            onPressed: () =>
                                addOrRemoveFriend(ref, user.uid, context),
                          )
                        ],
                      );
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
