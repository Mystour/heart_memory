// screens/photo_view_screen.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';

class PhotoViewScreen extends StatelessWidget {
  final Uint8List imageData; // 图片数据 (Uint8List)
  final String? title; // 可选的标题

  const PhotoViewScreen({Key? key, required this.imageData, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
        backgroundColor: Colors.black, // 设置 AppBar 背景颜色为黑色
        iconTheme: const IconThemeData(color: Colors.white), // 设置图标颜色
      ),
      body: Container(
        color: Colors.black, // 设置背景颜色为黑色
        child: Center(
          child: InteractiveViewer( // 使用 InteractiveViewer，允许缩放、平移
            child: Image.memory(
              imageData,
              fit: BoxFit.contain, // 图片适应屏幕
            ),
          ),
        ),
      ),
    );
  }
}