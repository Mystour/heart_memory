class Anniversary {
  String id;
  String name;
  DateTime date;
  String? icon; // 可选，纪念日图标
  String userId;

  Anniversary({
    required this.id,
    required this.name,
    required this.date,
    this.icon,
    required this.userId,
  });

  factory Anniversary.fromMap(Map<String, dynamic> map) {
    return Anniversary(
      id: map['\$id'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date']),
      icon: map['icon'],
      userId: map['userId'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'icon': icon,
      'userId': userId,
    };
  }
}