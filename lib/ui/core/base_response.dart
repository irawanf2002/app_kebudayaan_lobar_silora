class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;

  BaseResponse({required this.success, required this.message, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJson,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: fromJson != null && json['data'] != null
          ? fromJson(json['data'])
          : null,
    );
  }
}
