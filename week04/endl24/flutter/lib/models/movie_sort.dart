enum MovieSort {
  latest('최신순'),
  rating('평점순');

  const MovieSort(this.label);

  final String label;
}