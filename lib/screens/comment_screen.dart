import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Data/firestore_methods.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import '../utils/color.dart';
import '../widgets/comment_card.dart';

class CommentScreen extends StatefulWidget {
  final String? postId;

  const CommentScreen({super.key, this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Posts')
            .doc(widget.postId)
            .collection('Comments')
            .snapshots(),
        builder:
            (
              context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  List<CommentModel> comments = snapshot.data!.docs
                      .map((e) => CommentModel.fromDoc(e))
                      .toList();

                  CommentModel comment = comments[index];
                  return CommentCard(comment: comment);
                },
              );
            },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(user.photoUrl!),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.userName}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  FirestoreMethods().postComment(
                    CommentModel(
                      name: user.userName ?? "",
                      userId: user.id ?? '',
                      profilePicture: user.photoUrl ?? "",
                      postId: widget.postId ?? "",
                      comment: commentController.text,
                      // createdAt: DateTime.now(),
                      // updatedAt: DateTime.now(),
                    ),
                  );
                  commentController.text = '';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: const Text('Post', style: TextStyle(color: blueColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
