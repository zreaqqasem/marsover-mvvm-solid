import 'package:flutter_test/flutter_test.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/position.dart';

void main() {
  group('Grid', () {
    group('constructor', () {
      test('should create grid with given dimensions', () {
        // Arrange & Act
        const grid = Grid(width: 5, height: 7);

        // Assert
        expect(grid.width, 5);
        expect(grid.height, 7);
      });
    });

    group('isValidPosition', () {
      const grid = Grid(width: 5, height: 7);

      test('should return true for valid position', () {
        // Arrange
        const position = Position(x: 2, y: 3);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, true);
      });

      test('should return true for position at (0,0)', () {
        // Arrange
        const position = Position(x: 0, y: 0);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, true);
      });

      test('should return true for position at maximum valid coordinates', () {
        // Arrange
        const position = Position(x: 4, y: 6); // width-1, height-1

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, true);
      });

      test('should return false for negative x', () {
        // Arrange
        const position = Position(x: -1, y: 3);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, false);
      });

      test('should return false for negative y', () {
        // Arrange
        const position = Position(x: 2, y: -1);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, false);
      });

      test('should return false when x equals width', () {
        // Arrange
        const position = Position(x: 5, y: 3);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, false);
      });

      test('should return false when y equals height', () {
        // Arrange
        const position = Position(x: 2, y: 7);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, false);
      });

      test('should return false when x exceeds width', () {
        // Arrange
        const position = Position(x: 10, y: 3);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, false);
      });

      test('should return false when y exceeds height', () {
        // Arrange
        const position = Position(x: 2, y: 10);

        // Act
        final result = grid.isValidPosition(position);

        // Assert
        expect(result, false);
      });
    });

    group('totalCells', () {
      test('should calculate total cells correctly', () {
        // Arrange
        const grid = Grid(width: 5, height: 7);

        // Act
        final result = grid.totalCells;

        // Assert
        expect(result, 35);
      });

      test('should return 1 for 1x1 grid', () {
        // Arrange
        const grid = Grid(width: 1, height: 1);

        // Act
        final result = grid.totalCells;

        // Assert
        expect(result, 1);
      });

      test('should calculate correctly for rectangular grid', () {
        // Arrange
        const grid = Grid(width: 10, height: 3);

        // Act
        final result = grid.totalCells;

        // Assert
        expect(result, 30);
      });
    });

    group('copyWith', () {
      test('should create new grid with updated width', () {
        // Arrange
        const original = Grid(width: 5, height: 7);

        // Act
        final result = original.copyWith(width: 10);

        // Assert
        expect(result.width, 10);
        expect(result.height, 7);
        expect(original.width, 5); // Original unchanged
      });

      test('should create new grid with updated height', () {
        // Arrange
        const original = Grid(width: 5, height: 7);

        // Act
        final result = original.copyWith(height: 12);

        // Assert
        expect(result.width, 5);
        expect(result.height, 12);
        expect(original.height, 7); // Original unchanged
      });

      test('should create new grid with both dimensions updated', () {
        // Arrange
        const original = Grid(width: 5, height: 7);

        // Act
        final result = original.copyWith(width: 10, height: 12);

        // Assert
        expect(result.width, 10);
        expect(result.height, 12);
      });
    });

    group('equality', () {
      test('should be equal when dimensions are same', () {
        // Arrange
        const grid1 = Grid(width: 5, height: 7);
        const grid2 = Grid(width: 5, height: 7);

        // Act & Assert
        expect(grid1, grid2);
        expect(grid1.hashCode, grid2.hashCode);
      });

      test('should not be equal when width is different', () {
        // Arrange
        const grid1 = Grid(width: 5, height: 7);
        const grid2 = Grid(width: 6, height: 7);

        // Act & Assert
        expect(grid1, isNot(grid2));
      });

      test('should not be equal when height is different', () {
        // Arrange
        const grid1 = Grid(width: 5, height: 7);
        const grid2 = Grid(width: 5, height: 8);

        // Act & Assert
        expect(grid1, isNot(grid2));
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        // Arrange
        const grid = Grid(width: 5, height: 7);

        // Act
        final result = grid.toString();

        // Assert
        expect(result, 'Grid(width: 5, height: 7)');
      });
    });
  });
}
