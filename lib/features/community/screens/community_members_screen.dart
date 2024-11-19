import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';

import '../../../core/common/helper_functions.dart';

class CommunityMembersScreen extends ConsumerStatefulWidget {
  final String name;

  const CommunityMembersScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunityMembersScreenState();
}

class _CommunityMembersScreenState
    extends ConsumerState<CommunityMembersScreen> {
  void movToBlockList(String uid) {
    ref.read(communityControllerProvider.notifier).blockUser(
          widget.name,
          uid,
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Community Members',
          style: TextStyle(fontSize: 18,),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SvgPicture.asset('assets/svg/personalization.svg', fit: BoxFit.fitHeight,height: 300,),
          ref.watch(getCommunityByNameProvider(widget.name)).when(
                data: (community) {
                  List<String> members = community.members;
                  members.remove(community.ownerId);
                  if (user.uid != community.ownerId) {
                    members.removeWhere(
                        (element) => community.mods.contains(element));
                  }
                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (members.isEmpty) {
                        return SizedBox.shrink();
                      }
                      final member = members[index];
                      return ref.watch(getUserDataProvider(member)).when(
                            data: (user) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${user.firstName} ${user.lastName}',
                                    ),
                                    InkWell(
                                        onTap: () {
                                          movToBlockList(user.uid);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.block,
                                                    color: Colors.deepOrange,
                                                    size: 30,
                                                  ),
                                                  Text(
                                                    'Block',
                                                    style: TextStyle(
                                                        color:  Theme.of(context).iconTheme.color),
                                                  )
                                                ]
                                            )
                                        )

                                        )
                                  ],
                                ),
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
        ],
      ),
    );
  }
}
