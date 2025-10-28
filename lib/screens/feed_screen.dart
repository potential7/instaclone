import 'package:flutter/material.dart';
import 'package:instagram/models/post_Model.dart';
import 'package:instagram/utils/colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram/widgets/post_card.dart';
class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset('assets/ic_instagram.svg',color: Colors.white,height: 32,),
        actions: [
          IconButton(onPressed:(){

          }, icon: const Icon(Icons.messenger_outline_rounded)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){
                List<PostModel> posts = snapshot.data!.docs.map((e)=>PostModel.fromMap(e)).toList();
                PostModel? post = posts[index];
                return  PostCard(
                  post: post,
                );
              },
            );

          }
           return Container();
        },
      ),
    );
  }
}
