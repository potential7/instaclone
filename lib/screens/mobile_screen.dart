import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/feed_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/utils/colors.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({Key? key}) : super(key: key);

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  int page = 0;
  late PageController pageController;
void onTapped(int index){
  pageController.jumpToPage(index);
}
  onPageChanged(int page){
  setState(() {
    this.page = page;
  });
  }
@override
  void initState() {
    super.initState();
    pageController = PageController();
  }
  @override
  Widget build(BuildContext context) {
   // UserModel user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body:PageView(
        children: const [
          FeedScreen(),
          SearchScreen(),
          AddPostScreen(),
          Text('like'),
          ProfileScreen(),

        ],
        controller: pageController,
        onPageChanged:onPageChanged ,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home,color:  page ==0? primaryColor :secondaryColor,),label: '',backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.search,color:  page ==1? primaryColor :secondaryColor,),label: '',backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle,color:  page ==2? primaryColor :secondaryColor),label: '',backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.favorite,color:  page ==3? primaryColor :secondaryColor),label: '',backgroundColor: primaryColor),
          BottomNavigationBarItem(icon: Icon(Icons.person,color:  page ==4? primaryColor :secondaryColor),label: '',backgroundColor: primaryColor),
        ],
        onTap: onTapped,
      ),
    );
  }
}
