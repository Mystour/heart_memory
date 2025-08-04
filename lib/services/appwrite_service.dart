import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:heart_memory/models/memory.dart';
import 'package:heart_memory/models/anniversary.dart';
import 'package:heart_memory/models/message.dart';
import 'package:heart_memory/models/user.dart';
import 'package:heart_memory/utils/app_constants.dart';
import 'package:heart_memory/models/couple.dart';

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
      //  从users集合中获取用户信息
      final userDoc = await _databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: "users",
          queries: [
            Query.equal('userId', appwriteUser.$id),
          ]
      );
      if(userDoc.documents.isNotEmpty){
        _currentUser = User.fromMap(userDoc.documents.first.data);
      }
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
      //  从users集合中获取用户信息
      final userDoc = await _databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: "users",
          queries: [
            Query.equal('userId', appwriteUser.$id),
          ]
      );
      if(userDoc.documents.isNotEmpty){
        _currentUser = User.fromMap(userDoc.documents.first.data);
      }
      if (_currentUserId == null) {
        throw Exception("User not logged in.");
      }
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
      _currentUserId = appwriteUser.$id;
      final userDoc = await _databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: "users",
          queries: [
            Query.equal('userId', appwriteUser.$id),
          ]
      );
      if(userDoc.documents.isNotEmpty){
        _currentUser = User.fromMap(userDoc.documents.first.data);
      }
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // 更新用户昵称
  Future<void> updateUserName(String userId, String newNickname) async {
    try {
      final userDocs = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'users',
        queries: [Query.equal('userId', userId)],
      );

      if (userDocs.documents.isEmpty) {
        throw Exception("User document not found for update.");
      }
      final documentId = userDocs.documents.first.$id;

      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'users',
        documentId: documentId,
        data: {
          'nickname': newNickname,
        },
      );
      //  更新本地的用户缓存
      if (_currentUserId == userId && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(nickname: newNickname);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ---------- Memory 相关 ----------
  Future<Memory> createMemory(Memory memory) async {
    final userId = await _getUserId();
    try {
      List<String> permissions = [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ];
      final document = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'memories',
        documentId: ID.unique(),
        data: memory.toMap()..addAll({'userId': userId}),
        permissions: permissions,
      );
      return Memory.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Memory>> getMemories() async {
    final userId = await _getUserId();
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
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

  Future<Memory> updateMemory(Memory memory) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
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
        databaseId: AppConstants.databaseId,
        collectionId: 'memories',
        documentId: memoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ---------- Anniversary 相关 ----------

  Future<Anniversary> createAnniversary(Anniversary anniversary) async {
    final userId = await _getUserId();
    try {
      List<String> permissions = [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ];
      final document = await _databases.createDocument(
          databaseId: AppConstants.databaseId,
          collectionId: 'anniversaries',
          documentId: ID.unique(),
          data: anniversary.toMap()..addAll({'userId': userId}),
          permissions: permissions
      );
      return Anniversary.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Anniversary>> getAnniversaries() async {
    final userId = await _getUserId();
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'anniversaries',
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('date'),
        ],
      );
      return documents.documents.map((doc) => Anniversary.fromMap(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

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

  // ---------- Message 相关 ----------

  Future<Message> sendMessage(Message message) async {
    final userId = await _getUserId();
    try {
      List<String> permissions = [
        Permission.read(Role.user(message.senderId)),
        Permission.read(Role.user(message.receiverId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ];
      final document = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'messages',
        documentId: ID.unique(),
        data: message.toMap()..addAll({'userId': userId}),
        permissions: permissions,
      );
      return Message.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

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
      return documents.documents.map((doc) => Message.fromMap(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Message> updateMessage(Message message) async {
    try {
      final document = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'messages',
        documentId: message.id,
        data: message.toMap(),
      );
      return Message.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

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

  // ---------- 文件上传/下载 ----------
  Future<String> uploadFile(String filePath) async {
    try {
      final file = await _storage.createFile(
        bucketId: AppConstants.bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath),
      );
      return file.$id;
    } catch (e) {
      rethrow;
    }
  }

  Future<Uint8List> getFilePreview({required String fileId}) async {
    try {
      final bytes = await _storage.getFilePreview(
        bucketId: AppConstants.bucketId,
        fileId: fileId,
      );
      return bytes;
    } catch (e) {
      rethrow;
    }
  }

  // ---------- 用户认证相关 ----------
  Future<User> login(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(email: email, password: password);
      final appwriteUser = await _account.get();
      _currentUserId = appwriteUser.$id;
      final userDoc = await _databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: "users",
          queries: [
            Query.equal('userId', appwriteUser.$id),
          ]
      );
      if(userDoc.documents.isNotEmpty){
        _currentUser = User.fromMap(userDoc.documents.first.data);
      }
      if(_currentUser == null) throw Exception("User information not found in 'users' collection.");
      return _currentUser!;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> register(String name,String email, String password) async {
    try {
      final appwriteUser = await _account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: name
      );

      _currentUserId = appwriteUser.$id;
      await Future.delayed(const Duration(seconds: 2)); // 等待云函数执行
      _currentUser = await getCurrentUser();

      if(_currentUser == null) throw Exception("User information not found in 'users' collection after registration.");
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

  // ---------- 情侣绑定相关 ----------

  Future<Couple> createCouple(String user1Id, String user2Id) async {
    try {
      final document = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'couples',
        documentId: ID.unique(),
        data: {
          'user1Id': [user1Id],
          'user2Id': [user2Id],
        },
      );
      return Couple.fromMap(document.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Couple?> getCoupleByUser(String userId) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'couples',
        queries: [
          Query.or([
            Query.equal('user1Id', [userId]),
            Query.equal('user2Id', [userId]),
          ])
        ],
      );

      if (documents.documents.isNotEmpty) {
        return Couple.fromMap(documents.documents.first.data);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> findUserIdByEmail(String email) async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: 'users',
        queries: [
          Query.equal('email', email),
        ],
      );
      if (documents.documents.isNotEmpty) {
        return documents.documents.first.data['userId'];
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getUserById(String userId) async{
    try{
      final documents = await _databases.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: 'users',
          queries: [
            Query.equal('userId', userId),
          ]
      );
      if (documents.documents.isNotEmpty) {
        return User.fromMap(documents.documents.first.data);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCouple(String coupleId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppConstants.databaseId,
        collectionId: 'couples',
        documentId: coupleId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
