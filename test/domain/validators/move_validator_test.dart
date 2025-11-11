import 'package:flutter_test/flutter_test.dart';
import 'package:marsrover/core/errors/failures.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/position.dart';
import 'package:marsrover/domain/validators/move_validator.dart';

void main() {
  late MoveValidator validator;

  setUp(() {
    validator = MoveValidator();
  });

  group('MoveValidator', () {
    group('validatePositionInBounds', () {
      const grid = Grid(width: 5, height: 5);

      test('should not throw for valid position', () {
        // Arrange
        const position = Position(x: 2, y: 3);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          returnsNormally,
        );
      });

      test('should not throw for position at (0,0)', () {
        // Arrange
        const position = Position(x: 0, y: 0);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          returnsNormally,
        );
      });

      test('should not throw for position at maximum valid coordinates', () {
        // Arrange
        const position = Position(x: 4, y: 4);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          returnsNormally,
        );
      });

      test('should throw OutOfBoundsFailure for negative x', () {
        // Arrange
        const position = Position(x: -1, y: 2);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });

      test('should throw OutOfBoundsFailure for negative y', () {
        // Arrange
        const position = Position(x: 2, y: -1);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });

      test('should throw OutOfBoundsFailure when x equals grid width', () {
        // Arrange
        const position = Position(x: 5, y: 2);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });

      test('should throw OutOfBoundsFailure when y equals grid height', () {
        // Arrange
        const position = Position(x: 2, y: 5);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });

      test('should throw OutOfBoundsFailure when position far out of bounds', () {
        // Arrange
        const position = Position(x: 10, y: 10);

        // Act & Assert
        expect(
          () => validator.validatePositionInBounds(position, grid),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });
    });

    group('validateAdjacentMove', () {
      test('should not throw for horizontally adjacent positions', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 3, y: 2);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          returnsNormally,
        );
      });

      test('should not throw for vertically adjacent positions', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 2, y: 3);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          returnsNormally,
        );
      });

      test('should not throw for diagonally adjacent positions', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 3, y: 3);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          returnsNormally,
        );
      });

      test('should not throw for all 8 adjacent positions', () {
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
            () => validator.validateAdjacentMove(center, adjacent),
            returnsNormally,
            reason: 'Move to $adjacent should be valid',
          );
        }
      });

      test('should throw InvalidMoveFailure for same position', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 2, y: 2);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          throwsA(isA<InvalidMoveFailure>()),
        );
      });

      test('should throw InvalidMoveFailure for 2 steps horizontally', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 4, y: 2);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          throwsA(isA<InvalidMoveFailure>()),
        );
      });

      test('should throw InvalidMoveFailure for 2 steps vertically', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 2, y: 4);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          throwsA(isA<InvalidMoveFailure>()),
        );
      });

      test('should throw InvalidMoveFailure for far positions', () {
        // Arrange
        const from = Position(x: 0, y: 0);
        const to = Position(x: 5, y: 5);

        // Act & Assert
        expect(
          () => validator.validateAdjacentMove(from, to),
          throwsA(isA<InvalidMoveFailure>()),
        );
      });
    });

    group('validateMove', () {
      const grid = Grid(width: 5, height: 5);

      test('should not throw for valid first move', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 4, y: 4); // Not adjacent, but first move

        // Act & Assert
        expect(
          () => validator.validateMove(
            from: from,
            to: to,
            grid: grid,
            isFirstMove: true, // First move allows any position
          ),
          returnsNormally,
        );
      });

      test('should not throw for valid adjacent move (not first move)', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 3, y: 2);

        // Act & Assert
        expect(
          () => validator.validateMove(
            from: from,
            to: to,
            grid: grid,
            isFirstMove: false,
          ),
          returnsNormally,
        );
      });

      test('should throw InvalidMoveFailure for non-adjacent move when not first', () {
        // Arrange
        const from = Position(x: 0, y: 0);
        const to = Position(x: 3, y: 3);

        // Act & Assert
        expect(
          () => validator.validateMove(
            from: from,
            to: to,
            grid: grid,
            isFirstMove: false, // Not first move, must be adjacent
          ),
          throwsA(isA<InvalidMoveFailure>()),
        );
      });

      test('should throw OutOfBoundsFailure even for first move if out of bounds', () {
        // Arrange
        const from = Position(x: 2, y: 2);
        const to = Position(x: 10, y: 10); // Out of bounds

        // Act & Assert
        expect(
          () => validator.validateMove(
            from: from,
            to: to,
            grid: grid,
            isFirstMove: true, // First move, but still must be in bounds
          ),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });

      test('should throw OutOfBoundsFailure for adjacent move that goes out of bounds', () {
        // Arrange
        const from = Position(x: 4, y: 4); // At edge
        const to = Position(x: 5, y: 4); // One step outside

        // Act & Assert
        expect(
          () => validator.validateMove(
            from: from,
            to: to,
            grid: grid,
            isFirstMove: false,
          ),
          throwsA(isA<OutOfBoundsFailure>()),
        );
      });

      test('should allow move from edge to edge (adjacent)', () {
        // Arrange
        const from = Position(x: 0, y: 0);
        const to = Position(x: 1, y: 0);

        // Act & Assert
        expect(
          () => validator.validateMove(
            from: from,
            to: to,
            grid: grid,
            isFirstMove: false,
          ),
          returnsNormally,
        );
      });

      test('should validate all 8 directions from center', () {
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
            () => validator.validateMove(
              from: center,
              to: adjacent,
              grid: grid,
              isFirstMove: false,
            ),
            returnsNormally,
            reason: 'Move to $adjacent should be valid',
          );
        }
      });
    });
  });
}
