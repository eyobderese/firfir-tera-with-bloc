import 'package:firfir_tera/application/bloc/auth/auth_bloc.dart';
import 'package:firfir_tera/application/bloc/comment/comment_bloc.dart';
import 'package:firfir_tera/presentation/pages/comment/bloc/comment_event.dart';
import 'package:firfir_tera/presentation/pages/comment/bloc/comment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentScreen extends StatelessWidget {
  final String recipeId;

  CommentScreen({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    String? userId = context.read<AuthBloc>().state.userId;
    return Scaffold(
      key: const Key('comment_page'),
      appBar: AppBar(
        leading: IconButton(
          key: const Key('comment_back_button'),
          icon: Icon(Icons.arrow_back_sharp),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text('Comments'),
      ),
      body: BlocProvider(
        create: (_) => CommentBloc()..add(LoadComments(recipeId: recipeId)),
        child: CommentView(recipeId: recipeId, userId: userId!),
      ),
    );
  }
}

class CommentView extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final String recipeId;
  final String userId;
  CommentView({required this.recipeId, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is CommentLoaded) {
                return ListView.builder(
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(comment.user.image),
                        ),
                        title: Text(comment.user.firstName +
                            ' ' +
                            comment.user.lastName),
                        subtitle: Text(
                          comment.text,
                        ),
                        trailing:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          if (comment.user.id == userId)
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                final TextEditingController _controller =
                                    TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Comment'),
                                      content: TextField(
                                        controller: _controller,
                                        decoration: InputDecoration(
                                            hintText: "Enter new comment"),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Save'),
                                          onPressed: () {
                                            context.read<CommentBloc>().add(
                                                UpdateComment(
                                                    comment.id,
                                                    _controller.text,
                                                    recipeId));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ).then((value) {
                                  context
                                      .read<CommentBloc>()
                                      .add(LoadComments(recipeId: recipeId));
                                });
                              },
                            ),
                          if (comment.user.id == userId)
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                final isdeleted = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete this comment?'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            context.read<CommentBloc>().add(
                                                DeleteComment(
                                                    comment.id, recipeId));
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (isdeleted == true) {
                                  context
                                      .read<CommentBloc>()
                                      .add(LoadComments(recipeId: recipeId));
                                }
                              },
                            ),
                        ]));
                  },
                );
              } else if (state is CommentError) {
                return Center(child: Text(state.message));
              }
              return Center(child: Text('No comments yet.'));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('comment_textfield'),
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Enter your comment'),
                ),
              ),
              IconButton(
                key: const Key('send_comment'),
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    context
                        .read<CommentBloc>()
                        .add(AddComment(_controller.text, recipeId));
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
