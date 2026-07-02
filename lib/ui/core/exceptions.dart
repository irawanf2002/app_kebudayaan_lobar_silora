class ApiException implements Exception {
  final String message;
  final int? code;

  ApiException(this.message, {this.code});

  @override
  String toString() => "ApiException(code: $code, message: $message)";
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ParsingException extends ApiException {
  ParsingException(super.message);
}
