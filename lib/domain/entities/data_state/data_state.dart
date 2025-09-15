enum DataState {
  fetched,
  loading,
  failed;

  bool get isFetched => this == DataState.fetched;
  bool get isLoading => this == DataState.loading;
  bool get isFailed => this == DataState.failed;
}

sealed class Ds<T> {
  Ds({
    required this.state,
    this.valueOrNull,
    this.error,
  });

  T? valueOrNull;
  Object? error;
  DataState state;

  T get value => valueOrNull!;

  R onState<R>({
    required R Function(T data) fetched,
    required R Function(Object error) failed,
    required R Function() loading,
  }) {
    if (state.isFailed) {
      return failed(error!);
    } else if (state.isLoading) {
      return loading();
    } else {
      return fetched(valueOrNull as T);
    }
  }
}

// 성공적으로 데이터를 가져왔을 때의 데이터 상태 클래스
class Fetched<T> extends Ds<T> {
  final T data;

  Fetched(this.data) : super(state: DataState.fetched, valueOrNull: data);
}

// 로딩 중일 때의 데이터 상태 클래스
class Loading<T> extends Ds<T> {
  Loading() : super(state: DataState.loading);
}

// 데이터 가져오기 실패했을 때의 데이터 상태 클래스
class Failed<T> extends Ds<T> {
  final Object error;
  Failed(this.error) : super(state: DataState.failed, error: error);
}
