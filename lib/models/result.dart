enum ViewState { idle, loading, success, error }

class Result<T> {
  final T? data;
  final String? error;
  final ViewState state;

  const Result._({this.data, this.error, required this.state});

  factory Result.loading() => const Result._(state: ViewState.loading);
  factory Result.success(T data) =>
      Result._(data: data, state: ViewState.success);
  factory Result.error(String error) =>
      Result._(error: error, state: ViewState.error);
  factory Result.idle() => const Result._(state: ViewState.idle);

  bool get isLoading => state == ViewState.loading;
  bool get isSuccess => state == ViewState.success;
  bool get isError => state == ViewState.error;
  bool get isIdle => state == ViewState.idle;

  T? get valueOrNull => data;

  T get value {
    if (data == null) {
      throw StateError('Cannot access value when state is $state');
    }
    return data!;
  }
}
