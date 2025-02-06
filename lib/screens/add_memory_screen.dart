import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({Key? key}) : super(key: key);

  @override
  _AddMemoryScreenState createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<String> _imagePaths = []; // 存储本地图片路径
  List<String> _uploadedImageIds = []; // 存储上传后的图片ID
  String? _videoPath;  // 存储本地视频路径
  String? _uploadedVideoId; // 存储上传后的视频ID
  String? _location;
  List<String> _tags = [];
  bool _isPrivate = false;
  // 获取地理位置
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查是否启用了定位服务
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请打开定位服务')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有定位权限')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 用户永久拒绝了权限，引导用户到设置中开启
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请在设置中打开定位权限')),
      );
      return;
    }

    // 获取当前位置
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _location = "${position.latitude}, ${position.longitude}";
      });
      print('获取位置成功');
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取位置失败: $e')),
      );
    }
  }
  // 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  // 添加标签
  void _addTag() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = '';
        return AlertDialog(
          title: const Text('添加标签'),
          content: TextField(
            onChanged: (value) {
              newTag = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (newTag.isNotEmpty) {
                  setState(() {
                    _tags.add(newTag);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  // 从相册选择图片
  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images != null) {
      setState(() {
        _imagePaths.addAll(images.map((image) => image.path).toList());
      });
    }
  }
  // 使用相机拍照
  Future<void> _takePhoto() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePaths.add(image.path);
      });
    }
  }
  // 从相册选择视频
  Future<void> _pickVideo() async {
    final XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoPath = video.path;
      });
    }
  }
  // 拍摄视频
  Future<void> _recordVideo() async {
    final XFile? video = await ImagePicker().pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        _videoPath = video.path;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('添加回忆'),
    ),
    body: Form(
    key: _formKey,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: ListView(
    //crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    TextFormField(
    controller: _titleController,
    decoration: const InputDecoration(labelText: '标题'),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return '请输入标题';
    }
    return null;
    },
    ),
    TextFormField(
    controller: _contentController,
    decoration: const InputDecoration(labelText: '内容'),
    maxLines: null, // 允许多行输入
    validator: (value) {
    if (value == null || value.isEmpty) {
    return '请输入内容';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    Row(
    children: [
    const Text('日期: '),
    TextButton(
    onPressed: () => _selectDate(context),
    child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
    ),
    ],
    ),
    const SizedBox(height: 16),
    // 图片选择
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text('图片: '),
    const SizedBox(height: 8),
    Row(
    children: [
    ElevatedButton(
    onPressed: _pickImages,
    child: const Text('选择图片'),
    ),
    const SizedBox(width: 8),
    ElevatedButton(
    onPressed: _takePhoto,
    child: const Text('拍照'),
    ),
    ],
    ),
    const SizedBox(height: 8),
    if (_imagePaths.isNotEmpty)
    Container(
    height: 100,
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: _imagePaths.length,
    itemBuilder: (context, index) {
    return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Image.file(
    File(_imagePaths[index]),
    width: 80,
    height: 80,
    fit: BoxFit.cover,
    ),
    );
    },
    ),
    ),
    ],
    ),
    // 视频选择
    const SizedBox(height: 16),
    Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text('视频: '),
    const SizedBox(height: 8),
    Row(
    children: [
    ElevatedButton(
    onPressed: _pickVideo,
    child: const Text('选择视频'),
    ),
    const SizedBox(width: 8),
    ElevatedButton(
    onPressed: _recordVideo,
    child: const Text('拍摄视频'),
    ),
    ],
    ),
    const SizedBox(height: 8),
    if (_videoPath != null && _videoPath!.isNotEmpty)
    // Text('这里可以放视频预览'), // TODO: 添加视频预览
    AspectRatio(
    aspectRatio: 16 / 9, // 根据你的视频比例调整
    child:  Image.file(
    File(_videoPath!),
    fit: BoxFit.cover,
    ),
    ),
    ],
    ),
    // 定位
    const SizedBox(height: 16),
    Row(
    children: [
    const Text('地点: '),
    const SizedBox(width: 8),
    ElevatedButton(
    onPressed: _getCurrentLocation,
    child: const Text('获取当前位置'),
    ),
    const SizedBox(width: 8),
    if (_location != null) Text(_location!),                    ],
    ),

      // 标签
      const SizedBox(height: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('标签: '),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _tags
                .map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
            ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addTag,
            child: const Text('添加标签'),
          ),
        ],
      ),

      // 是否私密
      const SizedBox(height: 16),
      Row(
        children: [
          const Text('私密: '),
          Checkbox(
            value: _isPrivate,
            onChanged: (value) {
              setState(() {
                _isPrivate = value ?? false;
              });
            },
          ),
        ],
      ),

      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: _saveMemory,
        child: const Text('保存'),
      ),
    ],
    ),
    ),
    ),
    );
  }

  // 保存回忆
  Future<void> _saveMemory() async {
    if (_formKey.currentState!.validate()) {
      // 1. 上传图片 (如果有)
      try {
        for (String imagePath in _imagePaths) {
          final fileId = await AppwriteService.instance.uploadFile(imagePath);
          _uploadedImageIds.add(fileId);
        }

        // 2. 上传视频 (如果有)

        if (_videoPath != null) {
          _uploadedVideoId = await AppwriteService.instance.uploadFile(_videoPath!);
        }


        // 3. 创建 Memory 对象
        final memory = Memory(
          id: '', // Appwrite 会自动生成
          title: _titleController.text,
          content: _contentController.text,
          date: _selectedDate,
          images: _uploadedImageIds,
          video: _uploadedVideoId,
          location: _location,
          tags: _tags,
          isPrivate: _isPrivate,
          userId: '', // 在 AppwriteService 中获取
        );

        // 4. 调用 AppwriteService 保存

        final createdMemory = await AppwriteService.instance.createMemory(memory);
        // 5. 提示成功，并返回上一页
        Navigator.pop(context, true); // 返回 true 表示添加成功
      } catch (e) {
        // 处理错误
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}