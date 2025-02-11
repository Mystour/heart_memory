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
    .setKey(req.variables['standard_d6665bd9ba3c4896324f153b42492a4f712af91e6e2958a666c2d6b668f4839b068f2057dd7f9e82f077094bb937e0fb9ade5ced2cf03124005cfa04b2f5efbdf319c1fbd6d09796b1aa650581fed6adf723376d619c97ff46680dfdff9b79850948c9b535c02e255d3d88466a55a8b01c52af834273c453c35a92678283d7f2]); // 使用 API Key

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