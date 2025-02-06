// timeline_screen.dart 基本结构 (与之前版本相似，但现在从 AppwriteService 获取数据)
import 'package:flutter/material.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/widgets/memory_card.dart';
import 'package:heart_memory/screens/add_memory_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    try {
      final memories = await AppwriteService.instance.getMemories();
      setState(() {
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载回忆失败: $e')),
      );
    }
  }

  Future<void> _refreshMemories() async {
    await _loadMemories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('回忆墙'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToAddMemoryScreen(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty
          ? const Center(child: Text('还没有回忆，快去添加吧！'))
          : RefreshIndicator(
        onRefresh: _refreshMemories,
        child: ListView.builder(
          itemCount: _memories.length,
          itemBuilder: (context, index) {
            return MemoryCard(memory: _memories[index]);
          },
        ),
      ),
    );
  }

  void _navigateToAddMemoryScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMemoryScreen()),
    );

    if (result == true) {
      _loadMemories();
    }
  }
}