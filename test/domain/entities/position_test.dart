import 'package:flutter_test/flutter_test.dart';
import 'package:marsrover/domain/entities/position.dart';

void main() {
  group('Position', () {
    group('constructor', () {
      test('should create position with given coordinates', () {
        // Arrange & Act
        const position = Position(x: 3, y: 5);

        // Assert
        expect(position.x, 3);
        expect(position.y, 5);
      });
    });

    group('isWithinBounds', () {
      test('should return true when position is within bounds', () {
        // Arrange
        const position = Position(x: 3, y: 4);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, true);
      });

      test('should return false when x is negative', () {
        // Arrange
        const position = Position(x: -1, y: 3);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, false);
      });

      test('should return false when y is negative', () {
        // Arrange
        const position = Position(x: 3, y: -1);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, false);
      });

      test('should return false when x equals maxX', () {
        // Arrange
        const position = Position(x: 5, y: 3);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, false, reason: 'x should be < maxX, not <= maxX');
      });

      test('should return false when y equals maxY', () {
        // Arrange
        const position = Position(x: 3, y: 5);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, false, reason: 'y should be < maxY, not <= maxY');
      });

      test('should return true for position at (0,0)', () {
        // Arrange
        const position = Position(x: 0, y: 0);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, true);
      });

      test('should return true for position at maximum valid coordinates', () {
        // Arrange
        const position = Position(x: 4, y: 4);

        // Act
        final result = position.isWithinBounds(5, 5);

        // Assert
        expect(result, true);
      });
    });

    group('isAdjacentTo', () {
      test('should return true for horizontally adjacent positions', () {
        // Arrange
        const position1 = Position(x: 2, y: 2);
        const position2 = Position(x: 3, y: 2);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, true);
      });

      test('should return true for vertically adjacent positions', () {
        // Arrange
        const position1 = Position(x: 2, y: 2);
        const position2 = Position(x: 2, y: 3);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, true);
      });

      test('should return true for diagonally adjacent positions', () {
        // Arrange
        const position1 = Position(x: 2, y: 2);
        const position2 = Position(x: 3, y: 3);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, true);
      });

      test('should return true for all 8 adjacent positions', () {
        // Arrange
        const center = Position(x: 2, y: 2);
        final adjacentPositions = [
          const Position(x: 1, y: 1), // top-left
          const Position(x: 2, y: 1), // top
          const Position(x: 3, y: 1), // top-right
          const Position(x: 1, y: 2), // left
          const Position(x: 3, y: 2), // right
          const Position(x: 1, y: 3), // bottom-left
          const Position(x: 2, y: 3), // bottom
          const Position(x: 3, y: 3), // bottom-right
        ];

        // Act & Assert
        for (final adjacent in adjacentPositions) {
          expect(
            center.isAdjacentTo(adjacent),
            true,
            reason: '$adjacent should be adjacent to $center',
          );
        }
      });

      test('should return false for same position', () {
        // Arrange
        const position1 = Position(x: 2, y: 2);
        const position2 = Position(x: 2, y: 2);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, false, reason: 'Position cannot be adjacent to itself');
      });

      test('should return false for positions 2 steps away horizontally', () {
        // Arrange
        const position1 = Position(x: 2, y: 2);
        const position2 = Position(x: 4, y: 2);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, false);
      });

      test('should return false for positions 2 steps away vertically', () {
        // Arrange
        const position1 = Position(x: 2, y: 2);
        const position2 = Position(x: 2, y: 4);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, false);
      });

      test('should return false for positions far away', () {
        // Arrange
        const position1 = Position(x: 0, y: 0);
        const position2 = Position(x: 5, y: 5);

        // Act
        final result = position1.isAdjacentTo(position2);

        // Assert
        expect(result, false);
      });
    });

    group('copyWith', () {
      test('should create new position with updated x', () {
        // Arrange
        const original = Position(x: 2, y: 3);

        // Act
        final result = original.copyWith(x: 5);

        // Assert
        expect(result.x, 5);
        expect(result.y, 3);
        expect(original.x, 2); // Original unchanged
      });

      test('should create new position with updated y', () {
        // Arrange
        const original = Position(x: 2, y: 3);

        // Act
        final result = original.copyWith(y: 7);

        // Assert
        expect(result.x, 2);
        expect(result.y, 7);
        expect(original.y, 3); // Original unchanged
      });

      test('should create new position with both updated', () {
        // Arrange
        const original = Position(x: 2, y: 3);

        // Act
        final result = original.copyWith(x: 5, y: 7);

        // Assert
        expect(result.x, 5);
        expect(result.y, 7);
      });
    });

    group('equality', () {
      test('should be equal when x and y are same', () {
        // Arrange
        const position1 = Position(x: 2, y: 3);
        const position2 = Position(x: 2, y: 3);

        // Act & Assert
        expect(position1, position2);
        expect(position1.hashCode, position2.hashCode);
      });

      test('should not be equal when x is different', () {
        // Arrange
        const position1 = Position(x: 2, y: 3);
        const position2 = Position(x: 3, y: 3);

        // Act & Assert
        expect(position1, isNot(position2));
      });

      test('should not be equal when y is different', () {
        // Arrange
        const position1 = Position(x: 2, y: 3);
        const position2 = Position(x: 2, y: 4);

        // Act & Assert
        expect(position1, isNot(position2));
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        // Arrange
        const position = Position(x: 3, y: 5);

        // Act
        final result = position.toString();

        // Assert
        expect(result, 'Position(x: 3, y: 5)');
      });
    });
  });
}
