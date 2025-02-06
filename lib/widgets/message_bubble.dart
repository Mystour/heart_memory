import 'package:flutter/material.dart';
import 'package:heart_memory/models/message.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe; // 是否是自己发送的消息

  const MessageBubble({Key? key, required this.message, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
                bottomLeft:
                isMe ? const Radius.circular(12.0) : const Radius.circular(0),
                bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(12.0),
              ),
            ),
            child: Text(
              message.content,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            DateFormat('yyyy-MM-dd HH:mm').format(message.timestamp),
            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}