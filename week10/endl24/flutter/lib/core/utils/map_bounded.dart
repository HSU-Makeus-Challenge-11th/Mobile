/// values의 각 값을 convert로 바꾸되, 동시에 진행하는 요청을 최대 concurrency개로 제한합니다.
/// 결과 순서는 입력 순서와 같습니다.
///
/// Future.wait(values.map(convert))는 요청을 한꺼번에 모두 보내지만,
/// 이 함수는 worker concurrency개가 다음 값을 하나씩 가져가며 처리합니다.
/// 예: 즐겨찾기 20개의 TMDB 정보를 5개씩만 동시에 요청합니다.
Future<List<R>> mapBounded<T, R>(
  Iterable<T> values,
  int concurrency,
  Future<R> Function(T value) convert,
) async {
  final input = values.toList(growable: false);
  if (input.isEmpty) return <R>[];
  if (concurrency <= 0) {
    throw ArgumentError.value(concurrency, 'concurrency', 'must be positive');
  }

  final output = List<R?>.filled(input.length, null);
  var next = 0; // 다음에 처리할 index. Dart는 단일 스레드라 경쟁 없이 증가합니다.

  Future<void> worker() async {
    while (true) {
      final index = next++;
      if (index >= input.length) return;
      output[index] = await convert(input[index]);
    }
  }

  final workers = List.generate(
    concurrency.clamp(1, input.length),
    (_) => worker(),
  );
  await Future.wait(workers);
  return output.cast<R>();
}
