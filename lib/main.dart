import 'package:flutter/material.dart';
import 'package:heart_memory/screens/home_screen.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/utils/app_constants.dart';
import 'package:heart_memory/utils/theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 Appwrite
  await AppwriteService.instance.initialize(
    endpoint: AppConstants.appwriteEndpoint,
    projectId: AppConstants.appwriteProjectId,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '心动瞬间',
      theme: AppTheme.lightTheme, // 使用自定义主题
      darkTheme: AppTheme.darkTheme,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false, // 移除debug标志
    );
  }
}