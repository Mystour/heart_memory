class Couple {
  String id;
  String user1Id;
  String user2Id;
  DateTime? startDate; // 可选：恋爱开始日期
  String? coupleName; // 可选：情侣组合名称

  Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.startDate,
    this.coupleName,
  });

  factory Couple.fromMap(Map<String, dynamic> map) {
    return Couple(
      id: map['\$id'] ?? '',
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      startDate:
      map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      coupleName: map['coupleName'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'startDate': startDate?.toIso8601String(), // 将 DateTime 转换为字符串
      'coupleName': coupleName,
    };
  }
}