import 'dart:convert';

// This is the simplest possible function.
// It does not use any dependencies or environment variables.
Future<dynamic> main(final context) async {
  context.log('Hello World! Function executed successfully.');
  return context.res.json({
    'success': true,
    'message': 'Function executed without errors.'
  });
}