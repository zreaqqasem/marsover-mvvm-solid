import 'package:equatable/equatable.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/rover.dart';

abstract class RoverState extends Equatable {
  const RoverState();

  @override
  List<Object?> get props => [];
}

/// Initial state - before any action is taken
class RoverInitial extends RoverState {
  const RoverInitial();
}

/// Loading state - processing commands
class RoverLoading extends RoverState {
  final Grid? grid;

  const RoverLoading({this.grid});

  @override
  List<Object?> get props => [grid];
}

/// State when rover is actively moving on the grid
class RoverMoving extends RoverState {
  final Grid grid;
  final Rover rover;
  final List<Rover> history; // Track movement history for visualization

  const RoverMoving({
    required this.grid,
    required this.rover,
    this.history = const [],
  });

  /// Creates a copy with updated values
  RoverMoving copyWith({
    Grid? grid,
    Rover? rover,
    List<Rover>? history,
  }) {
    return RoverMoving(
      grid: grid ?? this.grid,
      rover: rover ?? this.rover,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [grid, rover, history];
}

/// Success state - all commands processed successfully
class RoverSuccess extends RoverState {
  final Grid grid;
  final Rover rover;
  final List<Rover> history;
  final String message;

  const RoverSuccess({
    required this.grid,
    required this.rover,
    required this.history,
    this.message = 'Mission completed successfully',
  });

  @override
  List<Object?> get props => [grid, rover, history, message];
}

/// Error state - something went wrong
class RoverError extends RoverState {
  final String message;
  final Grid? grid;
  final Rover? rover;
  final List<Rover>? history;

  const RoverError({
    required this.message,
    this.grid,
    this.rover,
    this.history,
  });

  @override
  List<Object?> get props => [message, grid, rover, history];
}
