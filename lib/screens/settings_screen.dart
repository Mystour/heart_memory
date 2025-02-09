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
  final _partnerEmailController = TextEditingController(); // 用于输入对方邮箱的控制器
  User? _currentUser;
  Couple? _couple;
  User? _partner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // 在 initState 中加载当前用户信息
  }
  @override
  void dispose() {
    _partnerEmailController.dispose();
    super.dispose();
  }

  // 加载当前用户信息和情侣信息
  Future<void> _loadCurrentUser() async {
    setState(() {
      _isLoading = true; // 开始加载
    });

    try {
      final user = await AppwriteService.instance.getCurrentUser();
      if (user != null) {
        final couple = await AppwriteService.instance.getCoupleByUser(user.id);
        User? partner;
        if(couple != null){
          if(couple.user1Id != user.id){
            partner = await AppwriteService.instance.getUserById(couple.user1Id);
          } else {
            partner = await AppwriteService.instance.getUserById(couple.user2Id);
          }
        }
        setState(() {
          _currentUser = user;
          _couple = couple;
          _partner = partner;
          _isLoading = false; // 加载完成
        });
      } else {
        setState(() {
          _isLoading = false; // 加载完成
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // 加载失败
      });
      // 处理错误
      print("Error loading user or couple: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取用户信息失败: $e')),
      );
    }
  }

  // 显示绑定情侣的对话框
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
                  // 根据邮箱查找对方用户 ID
                  final partnerId =
                  await AppwriteService.instance.findUserIdByEmail(partnerEmail);
                  if (partnerId != null) {
                    // 创建情侣关系
                    try {
                      await AppwriteService.instance.createCouple(
                        _currentUser!.id,
                        partnerId,
                      );
                      // 刷新界面
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
  // 显示修改昵称的对话框
  void _showChangeNicknameDialog(BuildContext context) {
    final _newNicknameController = TextEditingController(); // 用于输入新昵称的控制器

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
                    // 更新成功，刷新用户信息
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

  // 解除绑定
  Future<void> _unbindCouple(BuildContext context) async {
    if (_couple == null) return;

    try {
      await AppwriteService.instance.deleteCouple(_couple!.id);
      // 刷新
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
                title:  Text('浅色模式', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                leading: const Icon(Icons.light_mode),
                onTap: () {
                  settings.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title:  Text('深色模式', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                leading: const Icon(Icons.dark_mode),
                onTap: () {
                  settings.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title:  Text('跟随系统', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
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
          ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
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
            subtitle:  Text(_currentUser != null ? '${_currentUser!.nickname ?? _currentUser!.name} (${_currentUser!.email})'
                : '未登录'), // 显示昵称，如果没有昵称，则显示用户名
            trailing:  TextButton(
              child: const Text('退出登录'),
              onPressed: () async {
                await AppwriteService.instance.logout();
                // ignore: use_build_context_synchronously
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
          // 修改昵称
          ListTile(
            title: const Text('修改昵称'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showChangeNicknameDialog(context); // 显示修改昵称对话框
            },
          ),
          // 情侣绑定/解除绑定
          if (_currentUser != null)
            ListTile(
              title:  Text(_couple == null ? '绑定情侣' : '解除绑定'), // 根据是否已绑定显示不同的文本
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (_couple == null) {
                  _showBindCoupleDialog(context); // 显示绑定情侣对话框
                } else {
                  _unbindCouple(context); // 解除绑定
                }
              },
            ),
          // 如果已绑定，显示对方信息
          if (_couple != null && _partner != null)
            ListTile(
              title: const Text('情侣信息'),
              subtitle: Text('${_partner!.nickname ?? _partner!.name} (${_partner!.email})'),
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