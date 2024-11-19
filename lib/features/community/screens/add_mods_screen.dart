import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';

import '../../../core/common/helper_functions.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;

  const AddModsScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
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

  void saveMods() {
    ref.read(communityControllerProvider.notifier).addMods(
          widget.name,
          uids.toList(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
            data: (community) {
              if(uids.isEmpty) {
                community.mods.forEach((element) {
                  uids.add(element);
                });
              }
              return ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (BuildContext context, int index) {
                  final member = community.members[index];
                  return ref.watch(getUserDataProvider(member)).when(
                    data: (user) {
                      return Row(
                        children: [
                          user.uid == community.ownerId
                              ? Icon(
                            Icons.admin_panel_settings,
                            size: 30,
                          )
                              : SizedBox(width: 30,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 30,
                            child: CheckboxListTile(
                              value: uids.contains(user.uid),
                              onChanged: (val) {
                                if (user.uid == community.ownerId) {
                                  notifyDialog(context,
                                      'this is the owner of the community , can\'t be modified');
                                  return;
                                }
                                if (val!) {
                                  addUid(user.uid);
                                } else {
                                  removeUid(user.uid);
                                }
                              },
                              title: Text('${user.firstName} ${user.lastName}' , ),
                            ),
                          ),
                        ],
                      );
                    },
                    error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                    loading: () => const Loader(),
                  );
                },
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
