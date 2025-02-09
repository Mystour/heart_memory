// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:heart_memory/screens/login_screen.dart';
import 'package:heart_memory/screens/timeline_screen.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/models/user.dart';
import 'package:heart_memory/screens/settings_screen.dart';
import 'package:heart_memory/screens/anniversary_screen.dart';
import 'package:heart_memory/screens/album_screen.dart';
import 'package:heart_memory/screens/message_screen.dart';
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
    // 判断当前是否为深色模式
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_user?.nickname ?? _user?.name ?? "未登录"),
            accountEmail: Text(_user?.email ?? ""), // 即使 _user 为 null 也提供一个值
            currentAccountPicture: CircleAvatar(
              backgroundImage: _user?.avatarUrl != null
                  ? NetworkImage(_user!.avatarUrl!)
                  : null,
              child: _user?.avatarUrl == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
          // 不再需要 Theme 包裹，直接在 ListTile 中设置
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.timeline),
                title: Text('回忆墙',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)), // 动态设置颜色
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimelineScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('纪念日',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
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
                title: Text('相册',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
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
                title: Text('消息',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
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
                title: Text('设置',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text('退出登录',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                onTap: () async {
                  try {
                    await AppwriteService.instance.logout();
                    setState(() {
                      _user = null;
                    });
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('退出登录失败: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('菜花回忆'),
      ),
      drawer: _user != null ? _buildDrawer(context) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const LoginScreen()
          : const TimelineScreen(),
    );
  }
}