enum ResponseType { Ok, Info, Warning, Error }

class Response {
  final ResponseType type;
  final String message;
  final dynamic modifiedData;

  Response(this.type, this.message, {this.modifiedData});

  factory Response.ok(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Ok, message, modifiedData: modifiedData);
  }

  factory Response.info(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Info, message, modifiedData: modifiedData);
  }

  factory Response.warning(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Warning, message, modifiedData: modifiedData);
  }

  factory Response.error(String message, {dynamic modifiedData}) {
    return Response(ResponseType.Error, message, modifiedData: modifiedData);
  }

  @override
  String toString() {
    return 'Response{type: $type, message: $message, modifiedData: $modifiedData}';
  }
}


// zkouška
void main() {
  var responseOk = Response.ok('Operace proběhla v pořádku.', modifiedData: 42);
  var responseInfo = Response.info('Malé písmeno na začátku jména.');
  var responseWarning = Response.warning('Varování: Něco se nezdařilo.');
  var responseError = Response.error('Chyba: Nelze dokončit operaci.');

 /* print(responseOk);
  print(responseInfo);
  print(responseWarning);
  print(responseError);
  */
}