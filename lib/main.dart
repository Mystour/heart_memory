import 'package:flutter/material.dart';
import 'package:heart_memory/screens/home_screen.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/utils/app_constants.dart';
import 'package:heart_memory/utils/theme.dart';
import 'package:provider/provider.dart'; // 引入 provider
import 'package:heart_memory/providers/settings_provider.dart'; // 引入 SettingsProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppwriteService.instance.initialize(
    endpoint: AppConstants.appwriteEndpoint,
    projectId: AppConstants.appwriteProjectId,
  );

  runApp(
    ChangeNotifierProvider( // 使用 ChangeNotifierProvider
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 获取 SettingsProvider
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: '菜花回忆', //修改应用标题
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode, // 根据 SettingsProvider 中的 themeMode 设置
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}