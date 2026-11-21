import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movielog/data/models/favorite_check_dto.dart';
import 'package:movielog/data/models/favorite_response_dto.dart';
import 'package:movielog/data/services/favorite_api_service.dart';

DioException favoriteError(String path, int status, String code) =>
    DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: status,
        data: {
          'isSuccess': false,
          'code': code,
          'message': '실패',
          'result': null,
        },
      ),
      type: DioExceptionType.badResponse,
    );

/// 서버 대신 메모리에 즐겨찾기를 두고, 오류와 지연을 넣을 수 있다
class FakeFavoriteApi implements FavoriteApiService {
  final Set<int> movieIds = {};
  Object? checkError;
  Object? writeError;
  Object? listError;
  Completer<void>? gate;
  int addCalls = 0;
  int listCalls = 0;
  var _nextId = 1;
  final Map<int, DateTime> _created = {};

  Future<void> _wait() async {
    final pending = gate;
    if (pending != null) await pending.future;
  }

  @override
  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    addCalls++;
    await _wait();
    final error = writeError;
    if (error != null) throw error;
    movieIds.add(movieId);
    _created[movieId] = DateTime(2026, 11, 20, 0, 0, _nextId);
    return FavoriteResponseDto(
      favoriteId: _nextId++,
      movieId: movieId,
      createdAt: _created[movieId]!,
    );
  }

  @override
  Future<void> deleteFavorite({required int movieId}) async {
    await _wait();
    final error = writeError;
    if (error != null) throw error;
    movieIds.remove(movieId);
  }

  @override
  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async {
    await _wait();
    final error = checkError;
    if (error != null) throw error;
    return FavoriteCheckDto(
      movieId: movieId,
      isFavorite: movieIds.contains(movieId),
    );
  }

  @override
  Future<List<FavoriteResponseDto>> fetchMyFavorites() async {
    listCalls++;
    await _wait();
    final error = listError;
    if (error != null) throw error;
    var id = 100;
    return [
      for (final movieId in movieIds.toList().reversed)
        FavoriteResponseDto(
          favoriteId: id++,
          movieId: movieId,
          createdAt: _created[movieId] ?? DateTime(2026, 11, 20),
        ),
    ];
  }
}
