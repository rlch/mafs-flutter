import 'package:flutter_test/flutter_test.dart';
import 'package:mafs_flutter/mafs_flutter.dart';

void main() {
  test('mafs_flutter exports are available', () {
    // Verify core types are exported
    expect(Mafs, isNotNull);
    expect(ViewBox, isNotNull);
    expect(ZoomConfig, isNotNull);
    expect(MafsThemeData.light, isA<MafsThemeData>());
    expect(MatrixOps.identity, isNotNull);
  });
}
