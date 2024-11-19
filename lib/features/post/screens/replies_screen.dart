import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../models/comment_model.dart';
import '../../../models/post_model.dart';
import '../../../responsive/responsive.dart';
import '../../auth/controlller/auth_controller.dart';
import '../controller/post_controller.dart';
import '../widgets/comment_card.dart';

class RepliesScreen extends ConsumerStatefulWidget {
  final String commentId;
  final String postId;

  const RepliesScreen({
    super.key,
    required this.commentId,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<RepliesScreen> {
  final replyController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    replyController.dispose();
  }

  void addReply() {
    Post post = ref.watch(getPostByIdProvider(widget.postId)).value!;
    String newCommentId = const Uuid().v1();
    ref.read(postControllerProvider.notifier).addComment(
          context: context,
          isReply: true,
          commentIdForReplyStatus: newCommentId,
      parentCommentId: widget.commentId,
          text: replyController.text.trim(),
          post: post,
        );
    ref.read(postControllerProvider.notifier).addReply(
          context: context,
          commentIdForReplyStatus: newCommentId,
          parentCommentId: widget.commentId,
          postId: widget.postId,
          text: replyController.text.trim(),
        );
    setState(() {
      replyController.text = '';
    });
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${widget.postId}/comments');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: const Text('Replies'),
          leading: InkWell(
              onTap: () => navigateToComments(context),
              child: const Icon(Icons.arrow_back))),
      body: ref.watch(getPostCommentsProvider(widget.postId)).when(
            data: (data) {
              Comment parentComment =
                  data.firstWhere((element) => element.id == widget.commentId);
              return Column(
                children: [
                  CommentCard(
                      comment: parentComment, hideReplyForRepliedComment: true),
                  if (!isGuest)
                    Responsive(
                      child: TextField(
                        onSubmitted: (val) => addReply(),
                        controller: replyController,
                        decoration: const InputDecoration(
                          hintText: 'Add a Reply',
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ref.watch(getCommentRepliesProvider(widget.commentId)).when(
                        data: (data) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return CommentCard(
                                  comment: comment,
                                  hideReplyForRepliedComment: true,
                                  parentCommentId: comment.parentCommentId,
                                );
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) {
                          return ErrorText(
                            error: error.toString(),
                          );
                        },
                        loading: () => const Loader(),
                      ),
                ],
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
