class Message {
  String id;
  String senderId;
  String receiverId;
  String content;
  String type; // "text", "image", "voice"
  DateTime timestamp;
  String userId;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.userId,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['\$id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'timestamp': timestamp.toIso8601String(), // 将 DateTime 转换为 ISO 8601 字符串
      'userId': userId,
    };
  }
}