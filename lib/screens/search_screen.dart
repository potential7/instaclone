import 'package:flutter/material.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/post_Model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  bool showUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userName',
                      isGreaterThanOrEqualTo: searchController.text)
                  .get(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    List<UserModel> users = snapshot.data!.docs
                        .map((e) => UserModel.fromMap(e))
                        .toList();
                    UserModel user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl!),
                      ),
                      title: Text(user.userName!),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('Posts').get(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }
                List<PostModel> posts = snapshot.data!.docs
                    .map((e) => PostModel.fromMap(e))
                    .toList();

                return StaggeredGridView.countBuilder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    PostModel post = posts[index];
                    return Image.network(post.photoUrl!);
                  },
                  mainAxisSpacing: 11,
                  crossAxisSpacing: 10,
                  crossAxisCount: 3,
                  staggeredTileBuilder: (index) => StaggeredTile.count(
                      (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
                );
              },
            ),
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a User',
          ),
          onFieldSubmitted: (String text) {
            setState(() {
              showUsers = true;
            });
          },
        ),
      ),
    );
  }
}
