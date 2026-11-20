import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 상태 화면 확인용(디버그 빌드 전용). 고른 요청을 한 번만 네트워크 오류로 바꾼다.
/// 서버에 보내기 전에 막으므로 실제 데이터는 바뀌지 않는다
class DebugFaults {
  DebugFaults._();
  static final instance = DebugFaults._();

  /// 다음 page(page 2 이상) 조회 한 번
  bool nextPage = false;

  /// 검색 첫 page 조회 한 번
  bool search = false;

  /// 내 즐겨찾기 목록 조회 한 번
  bool favoriteList = false;

  /// TMDB 영화 상세 조회 한 번(내 즐겨찾기의 영화 정보 부분 실패)
  bool movieDetail = false;

  /// 즐겨찾기 등록·해제 한 번
  bool favoriteWrite = false;

  void clear() {
    nextPage = search = favoriteList = movieDetail = favoriteWrite = false;
  }

  /// 이 요청을 실패시킬지 정하고, 쓴 스위치는 끈다
  bool consume(RequestOptions options) {
    if (!kDebugMode) return false;
    final path = options.uri.path;
    final method = options.method.toUpperCase();
    final page = options.queryParameters['page'];
    final isPaged =
        path.endsWith('/discover/movie') || path.endsWith('/search/movie');
    if (nextPage && isPaged && page is int && page > 1) {
      nextPage = false;
      return true;
    }
    if (search && path.endsWith('/search/movie') && page == 1) {
      search = false;
      return true;
    }
    if (favoriteList && path == '/v8/favorites' && method == 'GET') {
      favoriteList = false;
      return true;
    }
    if (movieDetail && RegExp(r'/movie/\d+$').hasMatch(path)) {
      movieDetail = false;
      return true;
    }
    if (favoriteWrite &&
        path.startsWith('/v8/favorites') &&
        (method == 'POST' || method == 'DELETE')) {
      favoriteWrite = false;
      return true;
    }
    return false;
  }
}

class DebugFaultInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (DebugFaults.instance.consume(options)) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: '디버그 모드에서 강제로 실패시킨 요청',
        ),
      );
      return;
    }
    handler.next(options);
  }
}

/// 디버그 빌드에서 화면 제목을 길게 누르면 다음 요청 하나를 실패시킬 항목을 고른다
Future<void> showDebugFaultSheet(BuildContext context) async {
  if (!kDebugMode) return;
  final faults = DebugFaults.instance;
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        Widget item(String label, bool value, ValueChanged<bool> change) =>
            CheckboxListTile(
              title: Text(label),
              value: value,
              onChanged: (next) => setState(() => change(next ?? false)),
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              item(
                '다음 page 한 번 실패',
                faults.nextPage,
                (v) => faults.nextPage = v,
              ),
              item('검색 한 번 실패', faults.search, (v) => faults.search = v),
              item(
                '내 즐겨찾기 목록 한 번 실패',
                faults.favoriteList,
                (v) => faults.favoriteList = v,
              ),
              item(
                '영화 정보 한 건 실패',
                faults.movieDetail,
                (v) => faults.movieDetail = v,
              ),
              item(
                '즐겨찾기 저장 한 번 실패',
                faults.favoriteWrite,
                (v) => faults.favoriteWrite = v,
              ),
            ],
          ),
        );
      },
    ),
  );
}
