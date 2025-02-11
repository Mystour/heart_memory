class Couple {
  String id;
  List<String> user1Id;
  List<String> user2Id;
  DateTime? startDate;
  String? coupleName;

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
      user1Id: List<String>.from(map['user1Id'] ?? []),
      user2Id: List<String>.from(map['user2Id'] ?? []),
      startDate:
      map['startDate'] != null ? DateTime.parse(map['startDate']) : null,
      coupleName: map['coupleName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'startDate': startDate?.toIso8601String(),
      'coupleName': coupleName,
    };
  }
}