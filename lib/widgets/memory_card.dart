import 'package:flutter/material.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class MemoryCard extends StatelessWidget {
  final Memory memory;

  const MemoryCard({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              memory.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(memory.date),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(memory.content),
            const SizedBox(height: 8),
            if (memory.images.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: memory.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FutureBuilder<Uint8List>( // 使用 FutureBuilder
                        future: AppwriteService.instance.getFilePreview(
                            fileId: memory.images[index]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // 加载中
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}'); // 显示错误
                          } else if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!, // 显示图片
                              fit: BoxFit.cover,
                            );
                          } else {
                            return const SizedBox(); // 没有数据
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            if (memory.video != null && memory.video!.isNotEmpty)
            // Text('这里可以放视频播放器'), // TODO: 添加视频播放器
              AspectRatio(
                aspectRatio: 16 / 9, // 根据你的视频比例调整
                child:  FutureBuilder<Uint8List>( // 使用 FutureBuilder
                  future: AppwriteService.instance.getFilePreview(
                      fileId: memory.video!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // 加载中
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // 显示错误
                    } else if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!, // 显示图片
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const SizedBox(); // 没有数据
                    }
                  },
                ),
              ),
            if (memory.location != null && memory.location!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    memory.location!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            if (memory.tags.isNotEmpty)
              Wrap(
                spacing: 4.0,
                children: memory.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                ))
                    .toList(),
              ),
            // 删除按钮（根据需要显示）
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // 将按钮放在右侧
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, memory.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showDeleteConfirmationDialog(BuildContext context, String memoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条回忆吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('删除'),
              onPressed: () {
                _deleteMemory(context, memoryId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMemory(BuildContext context, String memoryId) async {
    try {
      await AppwriteService.instance.deleteMemory(memoryId);
      // 删除成功后，刷新列表或从列表中移除该项
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('回忆已删除')),
      );
    } catch (e) {
      // 处理错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除回忆失败: $e')),
      );
    }
  }
}