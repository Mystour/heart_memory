import 'package:flutter/material.dart';
class AppTheme{
  // 亮色主题
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.pink, // 使用粉色作为主色调
    scaffoldBackgroundColor: Colors.white, // 白色背景
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.pink, // 导航栏粉色
      foregroundColor: Colors.white, // 导航栏文字白色
      iconTheme: IconThemeData(color: Colors.white), // 导航栏图标白色
    ),
    cardTheme: CardTheme(
      color: Colors.white, // 卡片白色
      elevation: 4.0, // 卡片阴影
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // 卡片圆角
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent, // 按钮粉色
        foregroundColor: Colors.white, // 按钮文字白色
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // 按钮圆角
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.pinkAccent, // 文字按钮粉色
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.pinkAccent), // 聚焦时边框粉色
      ),
    ),
    // 可以根据需要添加更多的主题配置
  );
  // 暗色主题
  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.pink, // 使用粉色作为主色调
    scaffoldBackgroundColor: const Color(0xFF121212), // 深色背景 (Material Design 的深色背景)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.pink, // 导航栏粉色
      foregroundColor: Colors.white, // 导航栏文字白色
      iconTheme: IconThemeData(color: Colors.white), // 导航栏图标白色
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E), // 卡片深色
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xFF333333)), // 深色边框
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent, // 按钮粉色
        foregroundColor: Colors.white, // 按钮文字白色
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.pinkAccent, // 文字按钮粉色
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.pinkAccent), // 聚焦时边框粉色
      ),
      labelStyle: const TextStyle(color: Colors.white70), // 标签文字颜色
      hintStyle: const TextStyle(color: Colors.white54), // 提示文字颜色
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),

    // 添加 ListTileTheme
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white, // 设置 ListTile 文本颜色
      //iconColor: Colors.white70, // 如果需要，也可以设置图标颜色
    ),
  );
}
