/// Runs at most [concurrency] requests at once, preserving input order.
Future<List<R>> mapBounded<T, R>(
  List<T> values,
  Future<R> Function(T value) convert, {
  int concurrency = 5,
}) async {
  if (concurrency < 1) throw ArgumentError.value(concurrency, 'concurrency');
  final results = <R>[];
  for (var offset = 0; offset < values.length; offset += concurrency) {
    final end = (offset + concurrency).clamp(0, values.length);
    results.addAll(await Future.wait(values.sublist(offset, end).map(convert)));
  }
  return results;
}
