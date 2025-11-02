import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart'as timeago;

import '../models/comment_model.dart';

class CommentCard extends StatefulWidget {
 final CommentModel? comment;

  const CommentCard({super.key, this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
           CircleAvatar(
            backgroundImage: NetworkImage(
             // 'https://images.unsplash.com/photo-1660850889008-e26c9fd0772c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80,',
              widget.comment!.profilePicture,
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text:  TextSpan(children: [
                      TextSpan(
                        text: '${widget.comment!.name} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: widget.comment!.comment,
                      )
                    ]),
                  ),
                   Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      timeago.format(widget.comment!.createdAt!),


    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.favorite,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}
