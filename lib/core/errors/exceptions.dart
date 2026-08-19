class ServerException implements Exception {
  final String message;

  const ServerException(String s, {this.message = 'A server error occurred.'});

  @override
  String toString() => 'ServerException(message: $message)';
}