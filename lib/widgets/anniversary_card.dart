import 'package:flutter/material.dart';
import 'package:heart_memory/models/anniversary.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../services/appwrite_service.dart';

class AnniversaryCard extends StatelessWidget {
  final Anniversary anniversary;

  const AnniversaryCard({Key? key, required this.anniversary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 计算距离纪念日的天数
    final now = DateTime.now();
    final nextAnniversaryDate = DateTime(
      // 如果纪念日已经过了，就计算下一年的
      now.year,
      anniversary.date.month,
      anniversary.date.day,
    );
    // 如果纪念日已经过了，就计算下一年的
    final daysUntilAnniversary = nextAnniversaryDate.isBefore(now)
        ? nextAnniversaryDate.add(const Duration(days: 365)).difference(now).inDays
        : nextAnniversaryDate.difference(now).inDays;
    // 计算纪念日过去的百分比
    final double percent = 1 - (daysUntilAnniversary / 365);
    return Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    anniversary.name,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 8),
    Text(
    DateFormat('yyyy-MM-dd').format(anniversary.date),
    style: const TextStyle(color: Colors.grey),
    ),
    const SizedBox(height: 8),

    // 倒计时和进度条
    Row(
    children: [
    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
    const SizedBox(width: 4),
    Text(
    '$daysUntilAnniversary 天',
    style: const TextStyle(color: Colors.grey),
    ),
    const Spacer(), // 将进度条推到右边
    CircularPercentIndicator( // 使用 CircularPercentIndicator
    radius: 30.0, // 半径
    lineWidth: 6.0, // 线宽
    percent: percent, // 百分比
    center: Text(                      "${(percent * 100).toInt()}%", // 显示百分比
      style: const TextStyle(fontSize: 12.0),
    ),
      progressColor: Colors.pinkAccent, // 进度条颜色
    ),
    ],
    ),
      //删除按钮
      Row(
        mainAxisAlignment: MainAxisAlignment.end, // 将按钮放在右侧
        children: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context, anniversary.id);
            },
          ),
        ],
      ),
    ],
    ),
        ),
    );
  }
  void _showDeleteConfirmationDialog(BuildContext context, String anniversaryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这条纪念日吗？'),
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
                _deleteAnniversary(context, anniversaryId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnniversary(BuildContext context, String anniversaryId) async {
    try {
      await AppwriteService.instance.deleteAnniversary(anniversaryId);
      // 删除成功后，刷新列表或从列表中移除该项
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('纪念日已删除')),
      );
    } catch (e) {
      // 处理错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除纪念日失败: $e')),
      );
    }
  }
}