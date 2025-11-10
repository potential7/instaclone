import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../models/post_Model.dart';
import '../provider/search_provider.dart';
import '../utils/color.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(labelText: 'Search for a User'),
          onFieldSubmitted: (String text) {
            provider.searchUser(text);
          },
        ),
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : provider.showUser
          ? provider.users.isEmpty
          ?  Center(child: Text('No users found'))
          : ListView.builder(
              itemCount: provider.users.length,
              itemBuilder: (context, index) {

                final user = provider.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.photoUrl!),
                  ),
                  title: Text(user.userName!),
                );
              },
            )
          : StaggeredGridView.countBuilder(
              itemCount: provider.posts.length,
              itemBuilder: (context, index) {
                PostModel post = provider.posts[index];
                return Image.network(post.photoUrl!);
              },
              mainAxisSpacing: 11,
              crossAxisSpacing: 10,
              crossAxisCount: 3,
              staggeredTileBuilder: (index) => StaggeredTile.count(
                (index % 7 == 0) ? 2 : 1,
                (index % 7 == 0) ? 2 : 1,
              ),
            ),
    );
  }
}
