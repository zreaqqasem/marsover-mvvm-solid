import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Thrown when a rover attempts to move out of grid boundaries
class OutOfBoundsFailure extends Failure {
  const OutOfBoundsFailure({
    required int x,
    required int y,
    required int maxX,
    required int maxY,
  }) : super(
          'Rover attempted to move out of bounds: ($x, $y) exceeds grid size ($maxX, $maxY)',
        );
}

/// Thrown when a rover attempts to make an invalid move (not adjacent)
class InvalidMoveFailure extends Failure {
  const InvalidMoveFailure({
    required int fromX,
    required int fromY,
    required int toX,
    required int toY,
  }) : super(
          'Invalid move: Cannot move from ($fromX, $fromY) to ($toX, $toY). Only adjacent cells are allowed.',
        );
}

/// Thrown when command parsing fails
class CommandParsingFailure extends Failure {
  const CommandParsingFailure(String message)
      : super('Failed to parse command: $message');
}

/// Thrown when an invalid command is received
class InvalidCommandFailure extends Failure {
  const InvalidCommandFailure(String command)
      : super('Invalid command received: $command');
}

/// Thrown when the grid has not been initialized
class GridNotInitializedFailure extends Failure {
  const GridNotInitializedFailure()
      : super('Grid must be initialized before moving rover');
}
