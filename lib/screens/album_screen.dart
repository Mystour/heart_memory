import 'package:flutter/material.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/screens/photo_view_screen.dart'; // 引入 PhotoViewScreen
import 'package:intl/intl.dart';
import 'dart:typed_data';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;
  String _selectedCategory = '标签'; // 默认分类方式
  Map<String, List<Memory>> _categorizedMemories = {}; // 分类后的数据

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
        _categorizeMemories(); // 加载数据后进行分类
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载相册失败: $e')),
      );
    }
  }
  Future<void> _refreshMemories() async{
    await _loadMemories();
  }

  // 根据选择的分类方式进行分类
  void _categorizeMemories() {
    _categorizedMemories.clear();

    if (_selectedCategory == '标签') {
      // 按标签分类
      for (var memory in _memories) {
        for (var tag in memory.tags) {
          if (_categorizedMemories.containsKey(tag)) {
            _categorizedMemories[tag]!.add(memory);
          } else {
            _categorizedMemories[tag] = [memory];
          }
        }
      }
    } else if (_selectedCategory == '年份') {
      // 按年份分类
      for (var memory in _memories) {
        final year = memory.date.year.toString();
        if (_categorizedMemories.containsKey(year)) {
          _categorizedMemories[year]!.add(memory);
        } else {
          _categorizedMemories[year] = [memory];
        }
      }
    } else if (_selectedCategory == '月份') {
      // 按月份分类
      for (var memory in _memories) {
        final yearMonth = DateFormat('yyyy-MM').format(memory.date);
        if (_categorizedMemories.containsKey(yearMonth)) {
          _categorizedMemories[yearMonth]!.add(memory);
        } else {
          _categorizedMemories[yearMonth] = [memory];
        }
      }
    }
  }

  // 构建分类下拉菜单
  Widget _buildCategoryDropdown() {
    return DropdownButton<String>(
      value: _selectedCategory,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
            _categorizeMemories(); // 切换分类方式后重新分类
          });
        }
      },
      items: <String>['标签', '年份', '月份']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('相册'),
        actions: [
          _buildCategoryDropdown(), // 添加分类下拉菜单
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categorizedMemories.isEmpty
          ? const Center(child: Text('还没有照片，快去添加吧！'))
          : RefreshIndicator(
        onRefresh: _refreshMemories,
        child: ListView.builder(
          // 使用 ListView.builder
          itemCount: _categorizedMemories.keys.length,
          itemBuilder: (context, index) {
            final category = _categorizedMemories.keys.elementAt(index);
            final memoriesInCategory = _categorizedMemories[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    category, // 显示分类标题 (标签、年份或月份)
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.builder(
                  // 使用 GridView 显示图片
                  shrinkWrap:
                  true, // 允许 GridView 在 ListView 中滚动  非常重要，避免错误
                  physics:
                  const NeverScrollableScrollPhysics(), // 禁止 GridView 自身的滚动
                  itemCount: memoriesInCategory.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemBuilder: (context, index) {
                    final memory = memoriesInCategory[index];
                    if (memory.images.isNotEmpty) {
                      return InkWell( // 使用 InkWell 包裹，添加点击效果
                        onTap: () async {
                          // 点击图片，打开 PhotoViewScreen
                          final imageData =
                          await AppwriteService.instance.getFilePreview(
                              fileId: memory.images[0]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoViewScreen(
                                imageData: imageData,
                                title: memory.title, // 传递标题
                              ),
                            ),
                          );
                        },
                        child: FutureBuilder<Uint8List>(
                          future: AppwriteService.instance.getFilePreview(
                              fileId: memory.images[0]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            } else {
                              return const SizedBox();
                            }
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}