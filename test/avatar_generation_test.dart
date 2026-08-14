import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('avatar batches contain no duplicate SVGs', () {
    final avatars = generateUniqueAvatarSvgs(20, batchSeed: 'batch-one');

    expect(avatars, hasLength(20));
    expect(avatars.toSet(), hasLength(20));
  });

  test('refreshed avatar batch excludes previously shown SVGs', () {
    final first = generateUniqueAvatarSvgs(20, batchSeed: 'batch-one');
    final second = generateUniqueAvatarSvgs(
      20,
      batchSeed: 'batch-two',
      excluded: first.toSet(),
    );

    expect(first.toSet().intersection(second.toSet()), isEmpty);
  });
}
