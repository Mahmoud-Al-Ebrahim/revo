import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({
    super.key,
    required this.uid,
  });

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }
  void navigateToViewUsers(BuildContext context) {
    Routemaster.of(context).push('/view-friends/$uid');
  }

  void addOrRemoveFriend(WidgetRef ref, String friendId, BuildContext context) async {
    ref
        .read(userProfileControllerProvider.notifier)
        .addOrRemoveFriend( friendId);
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(userProvider)!;
    String myId = me.uid;
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
            data: (user) {
              print(user.toString());
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              user.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding:
                            const EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 45,
                            ),
                          ),
                          myId == uid ? Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20),
                            child: OutlinedButton(
                              onPressed: () => navigateToEditUser(context),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ): SizedBox.shrink(),
                          myId == uid && user.friends.length > 0? Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.all(20),
                            child: OutlinedButton(
                              onPressed: () => navigateToViewUsers(context),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                const EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: const Text('My Friends'),
                            ),
                          ): SizedBox.shrink(),
                          myId != uid ? Positioned(
                            top: 40,
                            right: 20,
                            child: IconButton(
                              icon: Icon(Icons.star , size: 30,color: me.friends.contains(uid) ? Colors.amber : Theme.of(context).iconTheme.color,),
                              onPressed: ()=> addOrRemoveFriend(ref , uid , context),
                            )
                          ): SizedBox.shrink(),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if(myId == uid)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'wallet balance: ${user.walletBalance}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'birth: ${user.birthDate}',
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bio: ${user.bio == null ? '' : user.bio}',
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                '${user.karma} karma',
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(thickness: 2),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: ref.watch(getUserPostsProvider(uid)).when(
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
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
