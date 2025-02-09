class User {
  String id;
  String name;
  String email;
  String? nickname;
  String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.nickname,
    this.avatarUrl,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'],
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }

  // 添加 copyWith 方法
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? nickname,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}