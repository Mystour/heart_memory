import 'package:flutter/material.dart';
import 'package:heart_memory/models/anniversary.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/widgets/anniversary_card.dart';
import 'package:intl/intl.dart'; // 你需要创建这个 Widget

class AnniversaryScreen extends StatefulWidget {
  const AnniversaryScreen({Key? key}) : super(key: key);

  @override
  _AnniversaryScreenState createState() => _AnniversaryScreenState();
}

class _AnniversaryScreenState extends State<AnniversaryScreen> {
  List<Anniversary> _anniversaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnniversaries();
  }

  Future<void> _loadAnniversaries() async {
    try {
      final anniversaries = await AppwriteService.instance.getAnniversaries();
      setState(() {
        _anniversaries = anniversaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载纪念日失败: $e')),
      );
    }
  }
  Future<void> _refreshAnniversaries() async {
    await _loadAnniversaries();
  }
  // 添加纪念日 (示例, 你需要创建一个 AddAnniversaryScreen)
  void _navigateToAddAnniversaryScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
          const AddAnniversaryScreen()), // 替换为你的 AddAnniversaryScreen
    );

    if (result == true) {
      _loadAnniversaries(); // 刷新列表
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念日'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToAddAnniversaryScreen(context); // 添加按钮
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _anniversaries.isEmpty
          ? const Center(child: Text('还没有纪念日，快去添加吧！'))
          : RefreshIndicator(
        onRefresh: _refreshAnniversaries,
        child: ListView.builder(
          itemCount: _anniversaries.length,
          itemBuilder: (context, index) {
            return AnniversaryCard(
                anniversary: _anniversaries[index]); // 使用 AnniversaryCard
          },
        ),
      ),
    );
  }
}
// add_anniversary_screen.dart
class AddAnniversaryScreen extends StatefulWidget {
  const AddAnniversaryScreen({super.key});

  @override
  State<AddAnniversaryScreen> createState() => _AddAnniversaryScreenState();
}

class _AddAnniversaryScreenState extends State<AddAnniversaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
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
  // 保存纪念日
  Future<void> _saveAnniversary() async {
    if (_formKey.currentState!.validate()) {
      // 1. 创建 Anniversary 对象
      final anniversary = Anniversary(
        id: '', // Appwrite 自动生成
        name: _nameController.text,
        date: _selectedDate,
        userId: '', // 在 AppwriteService 中获取
      );

      try {
        // 2. 调用 AppwriteService 保存
        final createdAnniversary =
        await AppwriteService.instance.createAnniversary(anniversary);

        // 3. 提示成功，并返回上一页
        Navigator.pop(context, true); // 返回 true 表示添加成功
      } catch (e) {
        // 处理错误
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('添加纪念日'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '纪念日名称'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入纪念日名称';
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAnniversary,
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}