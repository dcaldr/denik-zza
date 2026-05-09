class FileOperationException implements Exception {
  final String message;
  final Object? cause;
  FileOperationException(this.message, [this.cause]);

  @override
  String toString() => 'FileOperationException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class TempFileException extends FileOperationException {
  TempFileException(super.message, [super.cause]);
}

class PermissionDeniedException extends FileOperationException {
  PermissionDeniedException(super.message, [super.cause]);
}
