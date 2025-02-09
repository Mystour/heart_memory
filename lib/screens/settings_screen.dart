import 'package:flutter/material.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import 'package:heart_memory/providers/settings_provider.dart';
import 'package:heart_memory/models/user.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
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
          FutureBuilder<User?>(
            future: AppwriteService.instance.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                final user = snapshot.data!;
                return ListTile(
                  title: const Text('账号'),
                  subtitle: Text('小陈子 (${user.email})'), // 使用你的昵称
                  trailing: TextButton(
                    child: const Text('退出登录'),
                    onPressed: () async {
                      await AppwriteService.instance.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
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

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; //判断是否是深色模式
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; //判断是否是深色模式
    showAboutDialog(
      context: context,
      applicationName: '菜花回忆',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.favorite),
      applicationLegalese: '© 2025 小陈子 & 小郑子 (菜花组合)',
      children: [
        // 不再需要 Theme 包裹，直接设置 style
        Text(
          '这是小陈子送给小郑子的专属回忆记录应用，记录我们在一起的点点滴滴。',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87), // 动态设置颜色
        ),
      ],
    );
  }
}