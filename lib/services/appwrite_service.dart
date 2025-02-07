import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/models/anniversary.dart';
import 'package:heart_memory/models/message.dart';
import 'package:heart_memory/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

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
        databaseId: AppConstants.databaseId, // 使用常量
        collectionId: 'memories', // 使用字符串字面量，因为集合 ID 不会变
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
    final userId = await _getUserId(); // 获取用户ID
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'memories',
        queries: [
          Query.equal('userId', userId), // 只获取当前用户的记录
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
        databaseId: AppConstants.databaseId,
        collectionId: 'memories',
        documentId: memory.id,
        data: memory.toMap(), // 使用 toMap 方法
      );
      return Memory.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> deleteMemory(String memoryId) async {
    try {
      await _databases.deleteDocument(
        databaseId:  AppConstants.databaseId,
        collectionId: 'memories',
        documentId: memoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Anniversary 相关
  Future<Anniversary> createAnniversary(Anniversary anniversary) async {
    final userId = await _getUserId();
    try {
      final document = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'anniversaries', // 使用字符串字面量
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
        databaseId: AppConstants.databaseId,
        collectionId: 'anniversaries',
        queries: [
          Query.equal('userId', userId), // 过滤用户
          Query.orderDesc('date'), // 可以按日期排序
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
        databaseId: AppConstants.databaseId,
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
        databaseId: AppConstants.databaseId,
        collectionId: 'anniversaries',
        documentId: anniversaryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Message 相关
  Future<Message> sendMessage(Message message) async {
    final userId = await _getUserId();
    try {
      final document = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
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
        databaseId: AppConstants.databaseId,
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
        databaseId: AppConstants.databaseId,
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
        databaseId: AppConstants.databaseId,
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
        bucketId: AppConstants.bucketId, // 使用常量
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
    return '${_client.endPoint}/storage/buckets/${AppConstants.bucketId}/files/$fileId/preview?project=${_client.config['project']!}';
  }
  // 获取文件下载 URL (如果需要)
  String getFileDownloadUrl(String fileId) {
    return '${_client.endPoint}/storage/buckets/${AppConstants.bucketId}/files/$fileId/download?project=${_client.config['project']!}';
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