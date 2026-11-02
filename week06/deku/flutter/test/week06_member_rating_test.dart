import 'package:deku/data/models/rating.dart';
import 'package:deku/data/models/tmdb_genre_dto.dart';
import 'package:deku/data/models/tmdb_movie_dto.dart';
import 'package:deku/data/models/tmdb_movie_page_dto.dart';
import 'package:deku/data/services/member_check_service.dart';
import 'package:deku/data/services/rating_api_service.dart';
import 'package:deku/data/services/tmdb_movie_service.dart';
import 'package:deku/view_models/my_ratings_view_model.dart';
import 'package:deku/view_models/sign_up_view_model.dart';
import 'package:deku/widgets/movie_log_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rating.fromJson은 null 코멘트와 숫자 타입을 안전하게 변환한다', () {
    final rating = Rating.fromJson({
      'ratingId': 1.0,
      'movieId': '550',
      'score': 5,
      'comment': null,
      'createdAt': '2026-08-27T10:00:00',
      'updatedAt': null,
    });

    expect(rating.ratingId, 1);
    expect(rating.movieId, 550);
    expect(rating.displayComment, '후기 없음');
    expect(rating.displayCreatedAt, '2026.08.27');
  });

  test('중복 문자열을 다시 입력하면 API 재호출 없이 에러 상태를 복원한다', () async {
    final service = _FakeMemberCheckService(nicknameAvailable: false);
    final viewModel = SignUpViewModel(service);

    viewModel.onNicknameChanged('영화광');
    await viewModel.checkNickname();

    expect(viewModel.nicknameCheckStatus, MemberCheckStatus.duplicate);
    expect(viewModel.canCheckNickname, isFalse);
    expect(service.nicknameRequestCount, 1);

    viewModel.onNicknameChanged('다른닉네임');
    expect(viewModel.nicknameCheckStatus, MemberCheckStatus.idle);
    expect(viewModel.canCheckNickname, isTrue);

    viewModel.onNicknameChanged('영화광');
    expect(viewModel.nicknameCheckStatus, MemberCheckStatus.duplicate);
    expect(viewModel.nicknameErrorText, '이미 사용 중인 닉네임입니다.');
    expect(service.nicknameRequestCount, 1);
  });

  test('통신 실패와 정상 중복 응답은 서로 다른 상태와 문구를 사용한다', () async {
    final service = _FakeMemberCheckService(shouldFail: true);
    final viewModel = SignUpViewModel(service);

    viewModel.onEmailChanged('movie@umc.com');
    await viewModel.checkEmail();

    expect(viewModel.emailCheckStatus, MemberCheckStatus.failure);
    expect(viewModel.emailErrorText, contains('실패'));
    expect(viewModel.canCheckEmail, isTrue);
  });

  test('내 평점 ViewModel은 Empty와 Success를 구분하고 영화 정보를 결합한다', () async {
    final movieService = _FakeMovieService();
    final emptyViewModel = MyRatingsViewModel(
      _FakeRatingApiService(const []),
      movieService,
    );

    await emptyViewModel.load();
    expect(emptyViewModel.status, MyRatingsStatus.empty);

    final successViewModel = MyRatingsViewModel(
      _FakeRatingApiService([
        Rating.fromJson({
          'ratingId': 1,
          'movieId': 550,
          'score': 5,
          'comment': '최고의 영화!',
          'createdAt': '2026-08-27T10:00:00',
        }),
      ]),
      movieService,
    );

    await successViewModel.load();

    expect(successViewModel.status, MyRatingsStatus.success);
    expect(successViewModel.items.single.movie.title, '파이트 클럽');
    expect(successViewModel.items.single.rating.score, 5);
  });

  testWidgets('MovieLogButton은 로딩 상태와 세 가지 너비를 표현한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MovieLogButton(label: '기본', onPressed: () {}),
                MovieLogButton(
                  key: const Key('infinity-button'),
                  label: '전체',
                  width: double.infinity,
                  onPressed: () {},
                ),
                MovieLogButton(
                  key: const Key('fixed-button'),
                  label: '고정',
                  width: 102,
                  onPressed: () {},
                ),
                const MovieLogButton(
                  key: Key('loading-button'),
                  label: '확인',
                  isLoading: true,
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('infinity-button'))).width, 320);
    expect(tester.getSize(find.byKey(const Key('fixed-button'))).width, 102);
    expect(
      find.descendant(
        of: find.byKey(const Key('loading-button')),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

class _FakeMemberCheckService extends MemberCheckService {
  _FakeMemberCheckService({
    this.nicknameAvailable = true,
    this.shouldFail = false,
  }) : super(Dio());

  final bool nicknameAvailable;
  final bool shouldFail;
  int nicknameRequestCount = 0;

  @override
  Future<bool> checkNickname(String nickname) async {
    nicknameRequestCount += 1;
    if (shouldFail) throw Exception('network');
    return nicknameAvailable;
  }

  @override
  Future<bool> checkEmail(String email) async {
    if (shouldFail) throw Exception('network');
    return true;
  }
}

class _FakeRatingApiService extends RatingApiService {
  _FakeRatingApiService(this.ratings) : super(Dio());

  final List<Rating> ratings;

  @override
  Future<List<Rating>> fetchMyRatings(int memberId) async => ratings;
}

class _FakeMovieService implements MovieService {
  @override
  Future<TmdbMovieDto> fetchMovieById(int movieId) async {
    return TmdbMovieDto(id: movieId, title: '파이트 클럽');
  }

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    return TmdbMoviePageDto(page: page, totalPages: 1, results: const []);
  }

  @override
  Future<TmdbMoviePageDto> discoverMovies({int page = 1, int? genreId}) async {
    return TmdbMoviePageDto(page: page, totalPages: 1, results: const []);
  }

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async => const [];
}
