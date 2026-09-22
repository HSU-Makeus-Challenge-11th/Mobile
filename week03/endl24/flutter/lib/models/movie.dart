// ignore_for_file: avoid_print

class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}

void main() {
  final List<Movie> movies = [];
  movies.add(Movie(id: 1, title: '라스트 마일'));
  movies.add(Movie(id: 2, title: '남극의 쉐프'));
  movies.add(Movie(id: 3, title: '프로젝트 헤일메리'));

  for (final movie in movies) {
    print(movie.title);
  }
  print(movies.map((movie) => movie.title).join('\n'));

  String displayName(String? nickname) {
    return nickname ?? '이름 없음';
  }

  print(displayName(null));
  print(displayName('듀이'));
}
