import 'package:flutter/material.dart';

import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Data/firestore_methods.dart';
import '../models/post_Model.dart';
import '../models/user_model.dart';
import '../provider/user_provider.dart';
import '../screens/comment_screen.dart';
import '../screens/like_animation.dart';
import '../utils/color.dart';
import '../utils/utils.dart';

// ignore: must_be_immutable
class PostCard extends StatefulWidget {
  PostModel? post;

  PostCard({super.key, this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int numberOfComment = 0;

  @override
  void initState() {
    super.initState();
    getComment();
  }

  void getComment() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post!.id)
          .collection('Comments')
          .get();
      numberOfComment = snapshot.docs.length;
    } catch (e) {
      print(e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UserModel? user = Provider.of<UserProvider>(context).getUser;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: mobileBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.post!.profileImage!),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post!.userName!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            children: ['Delete']
                                .map(
                                  (e) => InkWell(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                postId: widget.post!.id!,
                userId: user.id!,
                likes: widget.post!.likes!,
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.post!.photoUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  },
                  child: LikeAnimation(
                    isAnimation: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              LikeAnimation(
                isAnimation: widget.post!.likes!.contains(user.id),
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                      postId: widget.post!.id!,
                      userId: user.id!,
                      likes: widget.post!.likes!,
                    );
                  },
                  icon: widget.post!.likes!.contains(user.id)
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(Icons.favorite_border),
                ),
              ),
              IconButton(
                onPressed: () {
                  push(context, CommentScreen(postId: widget.post!.id));
                },
                icon: const Icon(Icons.comment_outlined),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_add),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${widget.post!.likes!.length}likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: widget.post!.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${widget.post!.description}'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'View all $numberOfComment comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
                Text(
                  timeago.format(DateTime.parse(widget.post!.createdAt!)),
                  style: const TextStyle(fontSize: 16, color: secondaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
