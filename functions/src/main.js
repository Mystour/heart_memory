const sdk = require('node-appwrite');

module.exports = async function (req, res) {
  const client = new sdk.Client();
  const databases = new sdk.Databases(client);

  // 从环境变量中获取配置信息
  const databaseId = req.variables['APPWRITE_DATABASE_ID'];
  const usersCollectionId = 'users'; // 你的 users 集合的 ID

  // 设置 Appwrite SDK 的客户端
  client
    .setEndpoint(req.variables['APPWRITE_ENDPOINT'])
    .setProject(req.variables['APPWRITE_PROJECT_ID'])
    .setKey(req.variables['APPWRITE_API_KEY']);

  // 获取触发事件的 payload
  const payload = JSON.parse(req.payload);
  console.log(payload);

  // 获取新创建的 Auth 用户的信息
  const userId = payload['$id'];
  const userName = payload['name'];
  const userEmail = payload['email'];

  try {
    // 在 users 集合中创建文档
    await databases.createDocument(
      databaseId,
      usersCollectionId,
      userId, // 使用 Auth 用户的 $id 作为文档 ID
      {
        userId: userId,
        name: userName,
        email: userEmail,
        // nickname 和 avatarUrl 初始为空
      },
      [
        // 设置权限：只有用户自己可以读、写
        sdk.Permission.read(sdk.Role.user(userId)),
        sdk.Permission.update(sdk.Role.user(userId)),
        sdk.Permission.delete(sdk.Role.user(userId)),
      ]
    );

    console.log(`Created user document for user ID: ${userId}`);
    res.json({ success: true }); // 返回成功
  } catch (error) {
    console.error('Error creating user document:', error);
    res.json({ success: false, error: error.message }, 500); // 返回错误
  }
};