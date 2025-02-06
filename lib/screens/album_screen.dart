import 'package:flutter/material.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/widgets/memory_card.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  List<Memory> _memories = [];
  bool _isLoading = true;
  // 这里可以添加一个 Map<String, List<Memory>> 来按相册分组
  // 例如: Map<String, List<Memory>> _albums = {};

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {    try {
    final memories = await AppwriteService.instance.getMemories();
    setState(() {
      _memories = memories;
      _isLoading = false;
      // 在这里对 _memories 进行分组，例如按标签分组
      // _createAlbums();
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

  // (可选) 创建相册分组的函数
  // void _createAlbums() {
  //   _albums.clear();
  //   for (var memory in _memories) {
  //     for (var tag in memory.tags) {
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
            : _memories.isEmpty //或者 _albums.isEmpty
            ? const Center(child: Text('还没有照片，快去添加吧！'))
            : RefreshIndicator(
          onRefresh: _refreshMemories,
          child: GridView.builder(
            // 如果使用了 _albums, 这里要改为 _albums.keys.length 和 _albums[_albums.keys.elementAt(index)]
            itemCount: _memories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 每行3列
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemBuilder: (context, index) {
              //这里需要修改为只显示图片
              if(_memories[index].images.isNotEmpty){
                return Image.network(
                  AppwriteService.instance.getFilePreviewUrl(_memories[index].images[0]), //只展示第一张
                  fit: BoxFit.cover,
                );
              } else {
                return Container(); // 没有图片时显示空容器
              }
              // return MemoryCard(memory: _memories[index]); // 或者自定义一个 AlbumItem Widget
            },
          ),
        )
    );
  }
}