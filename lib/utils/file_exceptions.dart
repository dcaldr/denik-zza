class FileOperationException implements Exception {
  final String message;
  final Object? cause;
  FileOperationException(this.message, [this.cause]);

  @override
  String toString() => 'FileOperationException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class TempFileException extends FileOperationException {
  TempFileException(String message, [Object? cause]) : super(message, cause);
}

class PermissionDeniedException extends FileOperationException {
  PermissionDeniedException(String message, [Object? cause]) : super(message, cause);
}
