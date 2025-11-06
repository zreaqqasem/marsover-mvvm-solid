import 'package:marsrover/core/errors/failures.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/position.dart';

class MoveValidator {
  void validatePositionInBounds(Position position, Grid grid) {
    if (!grid.isValidPosition(position)) {
      throw OutOfBoundsFailure(
        x: position.x,
        y: position.y,
        maxX: grid.width,
        maxY: grid.height,
      );
    }
  }

  void validateAdjacentMove(Position from, Position to) {
    if (!from.isAdjacentTo(to)) {
      throw InvalidMoveFailure(
        fromX: from.x,
        fromY: from.y,
        toX: to.x,
        toY: to.y,
      );
    }
  }

  void validateMove({
    required Position from,
    required Position to,
    required Grid grid,
    required bool isFirstMove,
  }) {
    // Always check boundaries
    validatePositionInBounds(to, grid);

    // Check adjacency only if not the first move
    if (!isFirstMove) {
      validateAdjacentMove(from, to);
    }
  }
}
