import 'package:flutter/material.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import 'package:heart_memory/providers/settings_provider.dart';
import 'package:heart_memory/models/user.dart';
import 'package:heart_memory/models/couple.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _partnerEmailController = TextEditingController();
  User? _currentUser;
  Couple? _couple;
  User? _partner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentUser(); // 在 didChangeDependencies 中加载当前用户信息
  }

  @override
  void dispose() {
    _partnerEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AppwriteService.instance.getCurrentUser();
      if (user != null) {
        final couple =
        await AppwriteService.instance.getCoupleByUser(user.id);
        User? partner;
        if (couple != null) {
          if (couple.user1Id[0] != user.id) {
            partner =
            await AppwriteService.instance.getUserById(couple.user1Id[0]);
          } else {
            partner =
            await AppwriteService.instance.getUserById(couple.user2Id[0]);
          }
        }
        setState(() {
          _currentUser = user;
          _couple = couple;
          _partner = partner;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading user or couple: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取用户信息失败: $e')),
      );
      return; // 重要：阻止进一步执行
    }
  }

  void _showBindCoupleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('绑定情侣'),
          content: TextField(
            controller: _partnerEmailController,
            decoration: const InputDecoration(labelText: '对方邮箱'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('绑定'),
              onPressed: () async {
                final partnerEmail = _partnerEmailController.text;
                if (partnerEmail.isNotEmpty) {
                  final partnerId =
                  await AppwriteService.instance.findUserIdByEmail(partnerEmail);
                  if (partnerId != null) {
                    try {
                      await AppwriteService.instance.createCouple(
                        _currentUser!.id,
                        partnerId,
                      );
                      _loadCurrentUser();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('情侣绑定成功！')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('绑定失败: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('未找到该用户')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangeNicknameDialog(BuildContext context) {
    final _newNicknameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改昵称'),
          content: TextField(
            controller: _newNicknameController,
            decoration: const InputDecoration(labelText: '新昵称'),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('保存'),
              onPressed: () async {
                final newNickname = _newNicknameController.text;
                if (newNickname.isNotEmpty) {
                  try {
                    await AppwriteService.instance
                        .updateUserName(_currentUser!.id, newNickname);
                    _loadCurrentUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('昵称修改成功！')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('昵称修改失败: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _unbindCouple(BuildContext context) async {
    if (_couple == null) return;

    try {
      await AppwriteService.instance.deleteCouple(_couple!.id);
      _loadCurrentUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已解除绑定')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('解除绑定失败: $e')),
      );
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('浅色模式',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                leading: const Icon(Icons.light_mode),
                onTap: () {
                  settings.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('深色模式',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                leading: const Icon(Icons.dark_mode),
                onTap: () {
                  settings.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('跟随系统',
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black)),
                leading: const Icon(Icons.brightness_auto),
                onTap: () {
                  settings.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showAboutDialog(
      context: context,
      applicationName: '菜花的回忆',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.favorite),
      applicationLegalese: '© 2025 小陈子 & 小郑子 (菜花组合)',
      children: [
        Text(
          '这是小陈子送给小郑子的专属回忆记录应用，记录我们在一起的点点滴滴。',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          ListTile(
            title: const Text('主题'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showThemeDialog(context, settings);
            },
          ),
          SwitchListTile(
            title: const Text('通知'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              settings.setNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            title: const Text('纪念日提醒'),
            value: settings.anniversaryRemindersEnabled,
            onChanged: (value) {
              settings.setAnniversaryRemindersEnabled(value);
            },
          ),
          ListTile(
            title: const Text('账号'),
            subtitle: Text(_currentUser != null
                ? '${_currentUser!.nickname ?? _currentUser!.name} (${_currentUser!.email})'
                : '未登录'),
            trailing: TextButton(
              child: const Text('退出登录'),
              onPressed: () async {
                await AppwriteService.instance.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          ListTile(
            title: const Text('修改昵称'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showChangeNicknameDialog(context);
            },
          ),
          if (_currentUser != null)
            ListTile(
              title: Text(_couple == null ? '绑定情侣' : '解除绑定'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (_couple == null) {
                  _showBindCoupleDialog(context);
                } else {
                  _unbindCouple(context);
                }
              },
            ),
          if (_couple != null && _partner != null)
            ListTile(
              title: const Text('情侣信息'),
              subtitle: Text(
                  '${_partner!.nickname ?? _partner!.name} (${_partner!.email})'),
            ),
          ListTile(
            title: const Text('关于'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}