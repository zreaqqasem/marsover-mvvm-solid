import 'package:equatable/equatable.dart';
import 'package:marsrover/domain/entities/position.dart';

/// Domain entity representing the Mars grid
/// Immutable and follows Entity pattern
class Grid extends Equatable {
  final int width;
  final int height;

  const Grid({
    required this.width,
    required this.height,
  });

  /// Validates if a position is within this grid's boundaries
  bool isValidPosition(Position position) {
    return position.isWithinBounds(width, height);
  }

  /// Returns the total number of cells in the grid
  int get totalCells => width * height;

  /// Creates a copy of this grid with optional parameter overrides
  Grid copyWith({
    int? width,
    int? height,
  }) {
    return Grid(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [width, height];

  @override
  String toString() => 'Grid(width: $width, height: $height)';
}
