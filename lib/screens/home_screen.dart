import 'package:flutter/material.dart';
import 'package:heart_memory/screens/login_screen.dart';
import 'package:heart_memory/screens/settings_screen.dart';
import 'package:heart_memory/screens/timeline_screen.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/models/user.dart';

import 'album_screen.dart';
import 'anniversary_screen.dart';
import 'message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final user = await AppwriteService.instance.getCurrentUser();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      // 处理错误，例如导航到登录页面
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 构建抽屉 (Drawer)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_user?.name ?? "未登录"),
            accountEmail: Text(_user != null ? "已登录" : ""), // 可以显示用户的邮箱，如果没有，可以留空
            currentAccountPicture: CircleAvatar(
              backgroundImage: _user?.avatarUrl != null
                  ? NetworkImage(_user!.avatarUrl!)
                  : null,
              child: _user?.avatarUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('回忆墙'),
            onTap: () {
              Navigator.pop(context); // 关闭抽屉
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimelineScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('纪念日'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnniversaryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('相册'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlbumScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('消息'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessageScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          const Divider(), // 分隔线
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () async {
              try {
                await AppwriteService.instance.logout();
                setState(() {
                  _user = null; // 更新 UI
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()));
              } catch (e) {
                // 处理错误
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('退出登录失败: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('心动瞬间'),
      ),
      drawer: _user != null ? _buildDrawer(context) : null, // 已登录才显示抽屉
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const LoginScreen() // 未登录，显示登录页面
          : const TimelineScreen(), // 已登录，显示时间轴 (或其他主页面)
      // Center(
      //     child: Text('欢迎回来, ${_user!.name}!'), // 简单的欢迎信息
      //   ),
    );
  }
}