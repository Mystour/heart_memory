import 'dart:convert';
import 'package:dart_appwrite/dart_appwrite.dart';

/*
  'context' is the execution context passed to the function.
  It contains:
    'req' - request object with headers, payload, and variables
    'res' - response object to send data back to the client
    'log(message)' - function to log messages
    'error(message)' - function to error messages
*/
Future<dynamic> main(final context) async {
  final client = Client();

  // You can remove services you don't use
  final databases = Databases(client);

  final databaseId = context.req.variables['APPWRITE_DATABASE_ID'];
  final usersCollectionId = 'users';

  if (databaseId == null ||
      context.req.variables['APPWRITE_ENDPOINT'] == null ||
      context.req.variables['APPWRITE_PROJECT_ID'] == null ||
      context.req.variables['APPWRITE_API_KEY'] == null) {
    context.error('One or more environment variables are missing.');
    return context.res.json({'success': false, 'error': 'Missing environment variables.'}, statusCode: 500);
  }

  client
      .setEndpoint(context.req.variables['APPWRITE_ENDPOINT'])
      .setProject(context.req.variables['APPWRITE_PROJECT_ID'])
      .setKey(context.req.variables['APPWRITE_API_KEY']);

  try {
    // Use context.req.body instead of context.req.payload for newer runtimes
    final payload = jsonDecode(context.req.payload);
    context.log('Function triggered with payload:');
    context.log(payload);

    final userId = payload['\$id'];
    final userName = payload['name'];
    final userEmail = payload['email'];

    if (userId == null || userName == null || userEmail == null) {
      context.error('Payload is missing required user data (\$id, name, email).');
      return context.res.json({'success': false, 'error': 'Invalid payload data.'}, statusCode: 400);
    }

    await databases.createDocument(
      databaseId: databaseId,
      collectionId: usersCollectionId,
      documentId: userId, // Use Auth user's $id as the document ID
      data: {
        'userId': userId, // Store the user ID in a dedicated 'userId' attribute
        'name': userName,
        'email': userEmail,
        'nickname': userName, // Set nickname initially to the user's name
        'avatarUrl': null, // Explicitly set avatarUrl to null
      },
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );

    context.log('Successfully created user document for user ID: $userId');
    return context.res.json({'success': true});
  } catch (e) {
    context.error('Error creating user document: $e');
    return context.res.json({'success': false, 'error': e.toString()}, statusCode: 500);
  }
}
