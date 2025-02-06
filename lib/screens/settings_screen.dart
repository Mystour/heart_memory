import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('主题'),
            onTap: () {
              // 切换主题的逻辑 (你可以使用 Provider 或 GetX 来管理主题状态)
            },
          ),
          ListTile(
            title: const Text('通知'),
            onTap: () {
              // 设置通知的逻辑
            },
          ),
          // 其他设置项...
        ],
      ),
    );
  }
}