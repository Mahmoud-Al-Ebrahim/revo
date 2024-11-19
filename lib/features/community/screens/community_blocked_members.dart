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

class CommunityBlockedMembersScreen extends ConsumerStatefulWidget {
  final String name;

  const CommunityBlockedMembersScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunityBlockedMembersScreenState();
}

class _CommunityBlockedMembersScreenState
    extends ConsumerState<CommunityBlockedMembersScreen> {
  void unBlockUser(String uid) {
    ref.read(communityControllerProvider.notifier).unBlockUser(
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
          'Blocked Members',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SvgPicture.asset('assets/svg/personalization.svg', fit: BoxFit.fitHeight,height: 300,),
          ref.watch(getCommunityByNameProvider(widget.name)).when(
                data: (community) {
                  List<String> members = community.blockMembers;
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${user.firstName} ${user.lastName}',
                                    ),
                                    InkWell(
                                        onTap: () {
                                          unBlockUser(user.uid);
                                        },
                                        child: Container(
                                            padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.settings_backup_restore,
                                                color: Colors.green,
                                                size: 30,
                                              ),
                                              Text(
                                                'unBlock',
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
