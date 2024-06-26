import 'package:langchain_core/utils.dart';
import 'package:test/test.dart';

void main() {
  group('Chunk tests', () {
    test('Test with empty list', () {
      expect(chunkList(<int>[], chunkSize: 3), <int>[]);
    });

    test('Test with list of integers and chunk size 2', () {
      final arr = [1, 2, 3, 4, 5, 6, 7];
      expect(
        chunkList(arr, chunkSize: 2),
        [
          [1, 2],
          [3, 4],
          [5, 6],
          [7],
        ],
      );
    });

    test('Test with list of strings and chunk size 3', () {
      final arr = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
      expect(
        chunkList(arr, chunkSize: 3),
        [
          ['a', 'b', 'c'],
          ['d', 'e', 'f'],
          ['g'],
        ],
      );
    });

    test('Test with chunk size larger than list size', () {
      final arr = [1, 2, 3];
      expect(
        chunkList(arr, chunkSize: 4),
        [
          [1, 2, 3],
        ],
      );
    });
  });
}
