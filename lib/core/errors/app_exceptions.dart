class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

class LaunchException implements Exception {
  final String message;
  const LaunchException(this.message);
  @override
  String toString() => 'LaunchException: $message';
}
