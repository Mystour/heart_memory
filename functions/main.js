import { Client, Databases, Permission, Role } from 'node-appwrite';

// The new Appwrite function signature uses an object parameter.
export default async ({ req, res, log, error }) => {
  // Ensure required variables are present.
  if (
    !req.variables['APPWRITE_DATABASE_ID'] ||
    !req.variables['APPWRITE_ENDPOINT'] ||
    !req.variables['APPWRITE_PROJECT_ID'] ||
    !req.variables['APPWRITE_API_KEY']
  ) {
    error('One or more environment variables are missing.');
    return res.json({ success: false, error: 'Missing environment variables.' }, 500);
  }

  const client = new Client()
    .setEndpoint(req.variables['APPWRITE_ENDPOINT'])
    .setProject(req.variables['APPWRITE_PROJECT_ID'])
    .setKey(req.variables['APPWRITE_API_KEY']);

  const databases = new Databases(client);

  // Appwrite automatically parses the payload, no need for JSON.parse
  const payload = req.payload;
  log('Function triggered with payload:');
  log(payload);

  const userId = payload['$id'];
  const userName = payload['name'];
  const userEmail = payload['email'];

  if (!userId || !userName || !userEmail) {
    error('Payload is missing required user data ($id, name, email).');
    return res.json({ success: false, error: 'Invalid payload data.' }, 400);
  }

  const databaseId = req.variables['APPWRITE_DATABASE_ID'];
  const usersCollectionId = 'users';

  try {
    await databases.createDocument(
      databaseId,
      usersCollectionId,
      userId, // Use Auth user's $id as the document ID
      {
        userId: userId, // Store the user ID in a dedicated 'userId' attribute
        name: userName,
        email: userEmail,
        nickname: userName, // Set nickname initially to the user's name
        avatarUrl: null,  // Explicitly set avatarUrl to null
      },
      [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ]
    );

    log(`Successfully created user document for user ID: ${userId}`);
    return res.json({ success: true });
  } catch (e) {
    error('Error creating user document:', e);
    return res.json({ success: false, error: e.message }, 500);
  }
};
