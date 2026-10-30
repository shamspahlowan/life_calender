/// The outcome of an operation that can fail in an expected way.
///
/// Failures are values, not exceptions, so callers must handle them and the UI never shows a raw
/// exception message.
sealed class Result<T, F> {
  const Result();

  R fold<R>(R Function(T value) onOk, R Function(F failure) onErr) =>
      switch (this) {
        Ok<T, F>(:final value) => onOk(value),
        Err<T, F>(:final failure) => onErr(failure),
      };
}

final class Ok<T, F> extends Result<T, F> {
  const Ok(this.value);
  final T value;
}

final class Err<T, F> extends Result<T, F> {
  const Err(this.failure);
  final F failure;
}
