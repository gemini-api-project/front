// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 사용자 정보 로드
  }

  void _loadUserData() {
    setState(() {
      _user = _auth.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("setting"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                _user != null ? _buildUserProfile(_user!) : _buildNoUser(),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              onTap: () async {
                await _signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              title: Text("github 로그아웃"),
            ),
            ListTile(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              title: Text("test 로그아웃"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user.photoURL != null
              ? NetworkImage(user.photoURL!)
              : AssetImage('assets/default_profile.png')
                  as ImageProvider, // 기본 이미지로 교체 가능
        ),
        SizedBox(height: 10),
        // 사용자 이름
        Text(
          user.displayName ?? 'No display name',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        // 사용자 이메일
        Text(
          user.email ?? 'No email',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNoUser() {
    return Text(
      "사용자 정보가 없습니다.",
    );
  }

  // logout 함수
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully logged out!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }
}
