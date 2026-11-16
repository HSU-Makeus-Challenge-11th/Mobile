import 'package:dio/dio.dart';

String apiErrorMessage(
  DioException error, {
  String fallback = '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.',
}) {
  final data = error.response?.data;
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) return message;
  }
  return fallback;
}

bool shouldRefreshAfterRatingError(DioException error) {
  final data = error.response?.data;
  final code = data is Map ? data['code'] : null;
  return code == 'COMMON403' || code == 'COMMON404';
}
