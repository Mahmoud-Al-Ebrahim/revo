import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/helper_functions.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../models/comment_model.dart';
import '../../../responsive/responsive.dart';
import '../../auth/controlller/auth_controller.dart';
import '../controller/post_controller.dart';
import '../repository/post_repository.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final bool hideReplyForRepliedComment;
  final String? parentCommentId;

  CommentCard({
    super.key,
    this.parentCommentId,
    this.hideReplyForRepliedComment = false,
    required this.comment,
  });

  void navigateToReplies(BuildContext context) {
    Routemaster.of(context)
        .push('/comments/${comment.id}/${comment.postId}/replies');
  }

  void navigateToUser(BuildContext context , String uid) {
    Routemaster.of(context).push('/u/${uid}');
  }

  final postRepositoryProvider = Provider((ref) {
    return PostRepository(
      firestore: ref.watch(firestoreProvider),
    );
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Responsive(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      navigateToUser(context , comment.uid);
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            comment.profilePic,
                          ),
                          radius: 18,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${comment.username}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(comment.text)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (parentCommentId != null) const Icon(Icons.reply),
              ],
            ),
            if(!hideReplyForRepliedComment)
            Row(
              children: [
                IconButton(
                  onPressed: () => navigateToReplies(context),
                  icon: const Icon(Icons.reply),
                ),
                 Text('${comment.replies.length} Replies'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
