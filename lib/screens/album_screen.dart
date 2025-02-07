import 'package:flutter/material.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'dart:typed_data';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;
  // Map<String, List<Memory>> _albums = {}; // 用于按标签分组

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
        // _createAlbums(); // 对数据进行分组
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

  Future<void> _refreshMemories() async {
    await _loadMemories();
  }

  // // 按标签创建相册分组
  // void _createAlbums() {
  //   _albums.clear();
  //   for (var memory in _memories) {
  //     for (var tag in memory.tags) { // 遍历每个回忆的每个标签
  //       if (_albums.containsKey(tag)) {
  //         _albums[tag]!.add(memory);
  //       } else {
  //         _albums[tag] = [memory];
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('相册'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memories.isEmpty // 或 _albums.isEmpty
          ? const Center(child: Text('还没有照片，快去添加吧！'))
          : RefreshIndicator(
        onRefresh: _refreshMemories,
        child: GridView.builder(
          // itemCount: _albums.keys.length, // 如果按相册分组, 使用 _albums.keys.length
          itemCount: _memories.length, // 不分组, 直接显示所有照片
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemBuilder: (context, index) {
            // final albumKey = _albums.keys.elementAt(index); // 如果按相册分组
            // final memoriesInAlbum = _albums[albumKey]!;      // 如果按相册分组

            // return Column( // 如果按相册分组, 可以用 Column 显示相册标题和图片
            //   children: [
            //     Text(albumKey), // 相册标题
            //     Expanded(
            //       child: GridView.builder(
            //         itemCount: memoriesInAlbum.length,
            //         gridDelegate:
            //             const SliverGridDelegateWithFixedCrossAxisCount(
            //           crossAxisCount: 3,
            //           crossAxisSpacing: 4.0,
            //           mainAxisSpacing: 4.0,
            //         ),
            //         itemBuilder: (context, index) {
            //           // 显示 memoriesInAlbum[index] 中的图片
            //         },
            //       ),
            //     ),
            //   ],
            // );

            // 不分组, 直接显示图片
            if (_memories[index].images.isNotEmpty) {
              return FutureBuilder<Uint8List>(
                future: AppwriteService.instance.getFilePreview(
                    fileId: _memories[index].images[0]), // 只显示第一张图片
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
              );
            } else {
              return Container(); // 没有图片时显示空容器
            }
          },
        ),
      ),
    );
  }
}