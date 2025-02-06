class Memory {
  String id;
  String title;
  String content;
  DateTime date;
  List<String> images;
  String? video;
  String? location;
  List<String> tags;
  bool isPrivate;
  String userId;

  Memory({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.images,
    this.video,
    this.location,
    required this.tags,
    required this.isPrivate,
    required this.userId,
  });

  factory Memory.fromMap(Map<String, dynamic> map) {
    return Memory(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      date: DateTime.parse(map['date']),
      images: List<String>.from(map['images'] ?? []),
      video: map['video'],
      location: map['location'],
      tags: List<String>.from(map['tags'] ?? []),
      isPrivate: map['isPrivate'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  // 添加 toMap() 方法
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'images': images,
      'video': video,
      'location': location,
      'tags': tags,
      'isPrivate': isPrivate,
      // userId 会在 AppwriteService 中添加
    };
  }
}