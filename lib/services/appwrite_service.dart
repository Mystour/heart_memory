import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/models/anniversary.dart';
import 'package:heart_memory/models/message.dart';
import 'package:heart_memory/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppwriteService {
  static final AppwriteService instance = AppwriteService._();

  AppwriteService._();

  late Client _client;
  late Account _account;
  late Databases _databases;
  late Storage _storage;

  String? _currentUserId;
  User? _currentUser;

  Future<void> initialize({required String endpoint, required String projectId}) async {
    _client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectId);
    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);

    await _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final appwriteUser = await _account.get();
      _currentUserId = appwriteUser.$id;
      _currentUser = User.fromMap({
        '\$id': appwriteUser.$id,
        'name': appwriteUser.name,
        'email': appwriteUser.email,
      });
    } catch (e) {
      _currentUserId = null;
      _currentUser = null;
    }
  }

  Future<String> _getUserId() async {
    if (_currentUserId != null) {
      return _currentUserId!;
    }
    try {
      final appwriteUser = await _account.get();
      _currentUserId = appwriteUser.$id;
      _currentUser = User.fromMap({
        '\$id': appwriteUser.$id,
        'name': appwriteUser.name,
        'email': appwriteUser.email,
      });
      return _currentUserId!;
    } catch (e) {
      throw Exception("User not logged in.");
    }
  }

  // 获取当前用户信息 (可能返回 null)
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    try {
      final appwriteUser = await _account.get();
      _currentUser = User.fromMap({
        '\$id': appwriteUser.$id,
        'name': appwriteUser.name,
        'email': appwriteUser.email,
        // 'avatarUrl': appwriteUser.prefs.data['avatarUrl'], // 如果你有
      });
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // 其余方法 (createMemory, getMemories, login, register 等) 保持不变，
  // 只需要确保在涉及到 User 对象的地方使用 User.fromMap() 和 toMap()。
  // 创建新记录
  Future<Memory> createMemory(Memory memory) async {
    final userId = await _getUserId();
    try {
      final document = await _databases.createDocument(
        databaseId: 'your_database_id',
        collectionId: 'memories',
        documentId: ID.unique(),
        data: memory.toMap()..addAll({'userId': userId}),
      );
      return Memory.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  // 获取所有记录 (根据用户ID过滤)
  Future<List<Memory>> getMemories() async {
    final userId = await _getUserId();
    try {
      final documents = await _databases.listDocuments(
        databaseId: 'your_database_id',
        collectionId: 'memories',
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return documents.documents.map((doc) => Memory.fromMap(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }
  // 更新、删除方法与之前类似, 确保传入正确的 documentId
  Future<Memory> updateMemory(Memory memory) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: 'your_database_id',
        collectionId: 'memories',
        documentId: memory.id,
        data: memory.toMap(),
      );
      return Memory.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> deleteMemory(String memoryId) async {
    try {
      await _databases.deleteDocument(
        databaseId: 'your_database_id',
        collectionId: 'memories',
        documentId: memoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Anniversary 相关 (create, get, update, delete) ... 与之前类似，但要确保使用 toMap()
  // 创建纪念日
  Future<Anniversary> createAnniversary(Anniversary anniversary) async {
    final userId = await _getUserId();
    try {
      final document = await _databases.createDocument(
        databaseId: 'your_database_id',
        collectionId: 'anniversaries',
        documentId: ID.unique(),
        data: anniversary.toMap()..addAll({'userId': userId}),
      );
      return Anniversary.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  // 获取所有纪念日
  Future<List<Anniversary>> getAnniversaries() async {
    final userId = await _getUserId();
    try {
      final documents = await _databases.listDocuments(
        databaseId: 'your_database_id',
        collectionId: 'anniversaries',
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('date'),
        ],
      );
      return documents.documents.map((doc) => Anniversary.fromMap(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }
  // 更新纪念日
  Future<Anniversary> updateAnniversary(Anniversary anniversary) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: 'your_database_id',
        collectionId: 'anniversaries',
        documentId: anniversary.id,
        data: anniversary.toMap(),
      );
      return Anniversary.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  // 删除纪念日
  Future<void> deleteAnniversary(String anniversaryId) async {
    try {
      await _databases.deleteDocument(
        databaseId: 'your_database_id',
        collectionId: 'anniversaries',
        documentId: anniversaryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Message 相关 (create, get, update, delete) ... 与之前类似，但要确保使用 toMap()
  // 发送消息 (简化版，仅文本消息)
  Future<Message> sendMessage(Message message) async {
    final userId = await _getUserId();
    try {
      final document = await _databases.createDocument(
        databaseId: 'your_database_id',
        collectionId: 'messages',
        documentId: ID.unique(),
        data: message.toMap()..addAll({'userId': userId}),
      );
      return Message.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  // 获取消息列表 (简化版, 获取当前用户发送和接收的所有消息)
  Future<List<Message>> getMessages() async {
    final userId = await _getUserId();
    try {
      final documents = await _databases.listDocuments(
        databaseId: 'your_database_id',
        collectionId: 'messages',
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('timestamp'),
        ],
      );
      return documents.documents.map((doc) => Message.fromMap(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }
  // 更新消息（例如，标记为已读）
  Future<Message> updateMessage(Message message) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: 'your_database_id',
        collectionId: 'messages',
        documentId: message.id,
        data: message.toMap(), // 使用 toMap
      );
      return Message.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  // 删除消息
  Future<void> deleteMessage(String messageId) async {
    try {
      await _databases.deleteDocument(
        databaseId: 'your_database_id',
        collectionId: 'messages',
        documentId: messageId,
      );
    } catch (e) {
      rethrow;
    }
  }
  // 上传文件 (图片或视频)
  Future<String> uploadFile(String filePath) async {
    try {
      final file = await _storage.createFile(
        bucketId: 'your_bucket_id',
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath),
      );
      return file.$id;
    } catch (e) {
      rethrow;
    }
  }

  // 获取文件预览 URL
  String getFilePreviewUrl(String fileId) {
    return _client.endPoint
        .replaceAll('/v1', '') +
        '/storage/buckets/' +
        'your_bucket_id' +
        '/files/' +
        fileId +
        '/preview?project=' +
        _client.config['project']!;
  }
  // 获取文件下载 URL (如果需要)
  String getFileDownloadUrl(String fileId) {
    return _client.endPoint
        .replaceAll('/v1', '')+ '/storage/buckets/' + 'your_bucket_id' + '/files/' +
        fileId +  '/download?project=' + _client.config['project']!;
  }

  // 登录 (修正方法名)
  Future<User> login(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(email: email, password: password);
      final appwriteUser = await _account.get();
      _currentUserId = appwriteUser.$id;
      _currentUser = User.fromMap({
        '\$id': appwriteUser.$id,
        'name': appwriteUser.name,
        'email': appwriteUser.email,
      });
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }
  //注册
  Future<User> register(String name,String email, String password) async {
    try {
      final appwriteUser = await _account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: name
      );
      //注意这里注册成功后立即登录了
      final session = await _account.createEmailPasswordSession(email: email, password: password);
      _currentUserId = appwriteUser.$id;
      _currentUser = User.fromMap({
        '\$id': appwriteUser.$id,
        'name': appwriteUser.name,
        'email': appwriteUser.email,
      }); // 转换为自定义的User对象
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _currentUserId = null;
      _currentUser = null;
    } catch (e) {
      rethrow;
    }
  }
}