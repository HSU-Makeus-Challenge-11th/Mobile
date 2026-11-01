// 0주차 Mission 2 - Dart 연습
// 실행: dart run practice/week0_dart_practice.dart
//
// 콘솔 출력용 연습 스크립트이므로 print 사용을 허용한다.
// ignore_for_file: avoid_print

/// 영화 한 편을 나타내는 Class.
/// 생성자에서 Named Parameter + required를 사용해 필수 값을 강제한다.
class Movie {
  const Movie({required this.id, required this.title, required this.year});

  final int id;
  final String title;
  final int year;
}

/// nullable 닉네임을 화면에 보여줄 수 있는 안전한 문자열로 바꾼다.
/// null, 빈 문자열, 공백만 있는 문자열이면 기본값을 돌려준다.
String displayName(String? nickname) {
  final trimmed = nickname?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return '이름 없음';
  }
  // 위에서 null을 걸렀기 때문에 여기서 trimmed는 String으로 승격되어 ! 가 필요 없다.
  return trimmed;
}

/// Named Parameter 예시: name은 필수, week는 기본값 0.
String greeting({required String name, int week = 0}) {
  return '$name님, Flutter $week주차를 시작합니다.';
}

void main() {
  // 1. 영화 3개를 List<Movie>에 담는다.
  const movies = <Movie>[
    Movie(id: 1, title: '인터스텔라', year: 2014),
    Movie(id: 2, title: '기생충', year: 2019),
    Movie(id: 3, title: '센과 치히로의 행방불명', year: 2001),
  ];

  // 2-1. for로 영화 제목 출력
  print('--- for ---');
  for (final movie in movies) {
    print('${movie.id}. ${movie.title} (${movie.year})');
  }

  // 2-2. map으로 제목만 뽑아서 출력
  print('--- map ---');
  final titles = movies.map((movie) => movie.title).toList();
  print(titles.join(', '));

  // 3. nullable 닉네임을 안전한 기본값으로 변환
  print('--- Null Safety ---');
  final nicknames = <String?>[null, '   ', ' 무비러버 '];
  for (final nickname in nicknames) {
    final input = nickname == null ? 'null' : "'$nickname'";
    print('$input → ${displayName(nickname)}');
  }

  // 4. Named Parameter: 순서가 아니라 이름으로 값을 넘긴다.
  print('--- Named Parameter ---');
  print(greeting(name: displayName(' 무비러버 ')));
  print(greeting(week: 1, name: displayName(null)));
}
