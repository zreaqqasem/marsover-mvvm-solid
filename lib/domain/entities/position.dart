import 'package:equatable/equatable.dart';

/// Value object representing a 2D coordinate position
/// Immutable and follows Value Object pattern
class Position extends Equatable {
  final int x;
  final int y;

  const Position({
    required this.x,
    required this.y,
  });

  /// Checks if this position is within the given bounds
  bool isWithinBounds(int maxX, int maxY) {
    return x >= 0 && x < maxX && y >= 0 && y < maxY;
  }

  /// Checks if this position is adjacent to another position
  /// Adjacent means one step in any direction (including diagonals)
  bool isAdjacentTo(Position other) {
    final xDiff = (x - other.x).abs();
    final yDiff = (y - other.y).abs();

    // Adjacent if within one step in both dimensions
    return xDiff <= 1 && yDiff <= 1 && !(xDiff == 0 && yDiff == 0);
  }

  /// Creates a copy of this position with optional parameter overrides
  Position copyWith({
    int? x,
    int? y,
  }) {
    return Position(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'Position(x: $x, y: $y)';
}
