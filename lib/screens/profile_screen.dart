import 'package:flutter/material.dart';
import '../utils/color.dart';
import '../widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Username'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1660850889008-e26c9fd0772c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1770&q=80',
                  ),
                  radius: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(20, 'Posts'),
                    _buildStat(150, 'Followers'),
                    _buildStat(10, 'Followings'),
                  ],
                ),
                FollowButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(int number, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            margin:const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
