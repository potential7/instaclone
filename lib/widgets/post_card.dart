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

class PostCard extends StatefulWidget {
  final PostModel? post;

  const PostCard({super.key, this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int numberOfComment = 0;
  bool isLoadingComments = true;

  @override
  void initState() {
    super.initState();
    getComment();
  }

  void getComment() async {
    try {
      // Safety checks before accessing Firestore
      if (widget.post?.postId == null || widget.post!.postId!.isEmpty) {
        setState(() => isLoadingComments = false);
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Posts')
          .doc(widget.post!.postId)
          .collection('Comments')
          .get();

      if (mounted) {
        setState(() {
          numberOfComment = snapshot.docs.length;
          isLoadingComments = false;
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
      if (mounted) {
        setState(() => isLoadingComments = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Early null checks - return empty widget if data is invalid
    final post = widget.post;
    if (post == null) {
      return const SizedBox.shrink();
    }

    // Get user from provider with null safety
    UserModel? user;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      user = userProvider.getUser;
    } catch (e) {
      print('Error getting user from provider: $e');
      return const SizedBox.shrink();
    }

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: mobileBackgroundColor,
      child: Column(
        children: [
          // Header - Profile picture and username
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (post.profileImage != null && post.profileImage!.isNotEmpty)
                      ? NetworkImage(post.profileImage!)
                      : null,
                  child: (post.profileImage == null || post.profileImage!.isEmpty)
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
                                  child: Text(e),
                                ),
                                onTap: () {
                                  // Add delete functionality here
                                  Navigator.pop(context);
                                },
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

          // Post Image with double-tap to like
          GestureDetector(
            onDoubleTap: () async {
              if (post.postId != null && user!.id != null && post.likes != null) {
                await FirestoreMethods().likePost(
                  postId: post.postId!,
                  userId: user.id!,
                  likes: post.likes!,
                );
                setState(() {
                  isLikeAnimating = true;
                });
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: (post.photoUrl != null && post.photoUrl!.isNotEmpty)
                      ? Image.network(
                    post.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
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

          // Action buttons - Like, Comment, Share, Bookmark
          Row(
            children: [
              LikeAnimation(
                isAnimation: post.likes?.contains(user.id) ?? false,
                smallLike: true,
                child: IconButton(
                  onPressed: () async {
                    if (post.postId != null && user!.id != null && post.likes != null) {
                      await FirestoreMethods().likePost(
                        postId: post.postId!,
                        userId: user.id!,
                        likes: post.likes!,
                      );
                    }
                  },
                  icon: (post.likes?.contains(user.id) ?? false)
                      ? const Icon(Icons.favorite, color: Colors.red)
                      : const Icon(Icons.favorite_border),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (post.postId != null) {
                    push(context, CommentScreen(postId: post.postId));
                  }
                },
                icon: const Icon(Icons.comment_outlined),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border),
                  ),
                ),
              ),
            ],
          ),

          // Post details - Likes, Description, Comments, Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Likes count
                DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    '${post.likes?.length ?? 0} likes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                // Username and description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: post.userName ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${post.description ?? ''}'),
                      ],
                    ),
                  ),
                ),

                // View comments
                GestureDetector(
                  onTap: () {
                    if (post.postId != null) {
                      push(context, CommentScreen(postId: post.postId));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: isLoadingComments
                        ? const Text(
                      'Loading comments...',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    )
                        : Text(
                      numberOfComment == 0
                          ? 'Be the first to comment'
                          : 'View all $numberOfComment comments',
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),

                // Time posted
                Text(
                  post.createdAt != null
                      ? timeago.format(DateTime.parse(post.createdAt!))
                      : 'Unknown time',
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