class User {
  String id;
  String name;
  String email; // 添加 email 字段
  String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email, // 添加 email
    this.avatarUrl,
  });

  // 从 Map 创建 User 对象 (用于从 Appwrite Document 中创建)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '', // 从 map 中获取 email
      avatarUrl: map['avatarUrl'],
    );
  }

  // 将 User 对象转换为 Map (用于创建/更新 Appwrite Document)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      // 注意：这里不需要包含 $id，Appwrite 会自动处理
    };
  }
}