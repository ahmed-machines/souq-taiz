import 'package:flutter_test/flutter_test.dart';
import 'package:souq_taiz/core/errors/failure.dart';
import 'package:souq_taiz/core/result/result.dart';

void main() {
  test('Success folds to success branch', () {
    const Result<int> r = Success(2);
    expect(r.when(success: (v) => v * 2, failure: (_) => -1), 4);
  });

  test('Err folds to failure branch', () {
    const Result<int> r = Err(Failure(FailureType.network));
    expect(
      r.when(success: (_) => null, failure: (f) => f.type),
      FailureType.network,
    );
  });
}
