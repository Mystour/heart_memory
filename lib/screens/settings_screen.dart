import 'package:flutter/material.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import 'package:heart_memory/providers/settings_provider.dart'; // 引入 SettingsProvider
import 'package:heart_memory/models/user.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final settings = Provider.of<SettingsProvider>(context); // 获取 SettingsProvider
    final settings = context.watch<SettingsProvider>(); //更简洁
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 主题切换
          ListTile(
            title: const Text('主题'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showThemeDialog(context, settings); // 显示主题选择对话框
            },
          ),
          // 通知设置
          SwitchListTile(
            title: const Text('通知'),
            value: settings.notificationsEnabled,
            onChanged: (value) {
              settings.setNotificationsEnabled(value);
            },
          ),
          // 纪念日提醒
          SwitchListTile(
            title: const Text('纪念日提醒'),
            value: settings.anniversaryRemindersEnabled,
            onChanged: (value) {
              settings.setAnniversaryRemindersEnabled(value);
            },
          ),
          // 账号
          FutureBuilder<User?>(
            future: AppwriteService.instance.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                final user = snapshot.data!;
                return ListTile(
                  title: const Text('账号'),
                  subtitle: Text('${user.name} (${user.email})'),
                  trailing:  TextButton(
                    child: const Text('退出登录'),
                    onPressed: () async{
                      await AppwriteService.instance.logout();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink(); // 不显示账号信息
              }
            },
          ),

          // 关于
          ListTile(
            title: const Text('关于'),
            onTap: () {
              _showAboutDialog(context); // 显示关于对话框
            },
          ),
          // 可以在这里添加更多设置项...
        ],
      ),
    );
  }
  // 显示主题选择对话框
  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // 使对话框内容尽可能小
            children: [
              ListTile(
                title: const Text('浅色模式'),
                leading: const Icon(Icons.light_mode),
                onTap: () {
                  settings.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('深色模式'),
                leading: const Icon(Icons.dark_mode),
                onTap: () {
                  settings.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('跟随系统'),
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

  // 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '心动瞬间',
      applicationVersion: '1.0.0', // 版本号
      applicationIcon: const Icon(Icons.favorite), // 应用图标
      applicationLegalese: '© 2025 陈子昂/花菜组合', // 版权信息
      children: [
        // 可以在这里添加更多关于信息，例如隐私政策链接、服务条款链接等
        const Text('这是一个记录你和你的另一半美好回忆的应用。'),
      ],
    );
  }
}