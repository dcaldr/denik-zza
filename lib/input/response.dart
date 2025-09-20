/// Enum representing different response types: Ok, Info, Warning, and Error.
enum ResponseType { Ok, Info, Warning, Error }

/// A class representing a response with a type, message, and optional modified data.
class Response {
  final ResponseType type;
  final String message;
  final dynamic modifiedData;

  Response(this.type, this.message, {this.modifiedData});

  /// Factory method to create an Ok response with an optional modified data.
  factory Response.ok(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Ok, message, modifiedData: modifiedData);
  }

  /// Factory method to create an Info response with an optional modified data.
  factory Response.info(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Info, message, modifiedData: modifiedData);
  }

  /// Factory method to create a Warning response with an optional modified data.
  factory Response.warning(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Warning, message, modifiedData: modifiedData);
  }

  /// Factory method to create an Error response with an optional modified data.
  factory Response.error(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Error, message, modifiedData: modifiedData);
  }

  /// Override of the toString() method for a human-readable representation of the response.
  @override
  String toString() {
    return 'Response{type: $type, message: $message, modifiedData: $modifiedData}';
  }
}