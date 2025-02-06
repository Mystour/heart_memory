import 'package:flutter/material.dart';
import 'package:heart_memory/models/message.dart';
import 'package:heart_memory/models/user.dart';
import 'package:heart_memory/services/appwrite_service.dart';
import 'package:heart_memory/widgets/message_bubble.dart'; // 你需要创建这个 Widget
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Message> _messages = [];
  bool _isLoading = true;
  final _messageController = TextEditingController();
  User? _currentUser;
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await AppwriteService.instance.getMessages();
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载消息失败: $e')),
      );
    }
  }
  Future<void> _loadCurrentUser() async {
    _currentUser = await AppwriteService.instance.getCurrentUser();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        final message = Message(
          id: '', // Appwrite 生成
          senderId: _currentUser!.id, // 使用当前用户的 ID
          receiverId: 'partner_id', // 这里需要替换为你的伴侣的 ID。
          // 比较好的做法是：
          // 1. 你们两个用户都有一个唯一的ID。
          // 2. 你们可以创建一个 "couple" 集合，里面存储你们两个的ID。
          // 3. 在发送消息时，根据 "couple" 集合找到对方的 ID。
          content: _messageController.text,
          type: 'text',
          timestamp: DateTime.now(),
          userId: _currentUser!.id,
        );

        await AppwriteService.instance.sendMessage(message);
        _messageController.clear();
        _loadMessages(); // 重新加载消息
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送消息失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('悄悄话'), // 可以根据对方的昵称动态设置标题
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('还没有消息'))
                : ListView.builder(
              reverse: true, // 新消息在底部
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // 判断消息是自己发的还是对方发的
                final isMe = _messages[index].senderId == _currentUser?.id;
                return MessageBubble(
                  message: _messages[index],
                  isMe: isMe, // 传入 isMe
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}