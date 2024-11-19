import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';

import '../../../core/common/helper_functions.dart';
import '../../../models/user_model.dart';

class ChooseFriendsToInviteScreen extends ConsumerStatefulWidget {
  const ChooseFriendsToInviteScreen({
    required this.communityName,
    super.key,
  });

  final String communityName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChooseFriendsToInviteScreenState();
}

class _ChooseFriendsToInviteScreenState
    extends ConsumerState<ChooseFriendsToInviteScreen> {
  Set<String> uids = {};

  void addUid(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUid(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void sendInvites() {
    final me = ref.watch(userProvider);
    ref.read(userProfileControllerProvider.notifier).sendInviteNotifications(
        widget.communityName,
        uids.toList(),
        me!.firstName + ' ' + me.lastName,
        me.uid,
        context);
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(userProvider)!;
    String myId = me.uid;
    return Scaffold(
        appBar: AppBar(
          actions: [
            SizedBox(width: 15,),
            InkWell(
              onTap: () {
                if (uids.length == 0) {
                  toastMessage('You Must Choose At least one Friend To Invite');
                  return;
                }
                sendInvites();
              },
              child: Text(
                'Invite',
              ),
            ),
            SizedBox(width: 15,)
          ],
        ),
        body: ref.watch(getUserFriendsProvider(me.friends)).when(
              data: (users) => ListView.builder(
                itemCount: users.length,
                itemBuilder: (BuildContext context, int index) {
                  final UserModel user = users[index];
                  return Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 30,
                        child: CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUid(user.uid);
                            } else {
                              removeUid(user.uid);
                            }
                          },
                          title: Text(
                            '${user.firstName} ${user.lastName}',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
              loading: () => const Loader(),
            ));
  }
}
