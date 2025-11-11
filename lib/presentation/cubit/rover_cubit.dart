import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsrover/core/errors/failures.dart';
import 'package:marsrover/data/models/command_model.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/position.dart';
import 'package:marsrover/domain/entities/rover.dart';
import 'package:marsrover/domain/repositories/command_repository.dart';
import 'package:marsrover/domain/validators/move_validator.dart';
import 'package:marsrover/presentation/cubit/rover_state.dart';

class RoverCubit extends Cubit<RoverState> {
  final CommandRepository Function() _repositoryFactory;
  final MoveValidator _validator;

  CommandRepository? _currentRepository;
  StreamSubscription<CommandModel>? _commandSubscription;
  Grid? _currentGrid;
  Rover? _currentRover;
  final List<Rover> _history = [];
  bool _isFirstMove = true;

  RoverCubit({
    required CommandRepository Function() repositoryFactory,
    required MoveValidator validator,
  })  : _repositoryFactory = repositoryFactory,
        _validator = validator,
        super(const RoverInitial());

  /// Starts processing commands from the stream
  Future<void> startMission() async {
    try {
      // Reset state
      _reset();
      emit(const RoverLoading());

      // Create a fresh repository for this mission
      _currentRepository = _repositoryFactory();

      // Subscribe to command stream
      _commandSubscription = _currentRepository!.getCommandStream().listen(
            _handleCommand,
            onError: _handleError,
            onDone: _handleCompletion,
            cancelOnError: true,
          );
    } catch (e) {
      emit(RoverError(message: 'Failed to start mission: $e'));
    }
  }

  /// Handles incoming commands
  void _handleCommand(CommandModel command) {
    try {
      if (command is NewMapCommand) {
        _handleNewMapCommand(command);
      } else if (command is MoveCommand) {
        _handleMoveCommand(command);
      }
    } on Failure catch (f) {
      _handleError(f);
    } catch (e) {
      _handleError(Exception('Unexpected error: $e'));
    }
  }

  /// Handles NewMap command - initializes the grid
  void _handleNewMapCommand(NewMapCommand command) {
    _currentGrid = Grid(
      width: command.xSize,
      height: command.ySize,
    );

    // Emit loading state with grid initialized
    emit(RoverLoading(grid: _currentGrid));
  }

  /// Handles Move command - moves the rover
  void _handleMoveCommand(MoveCommand command) {
    if (_currentGrid == null) {
      throw const GridNotInitializedFailure();
    }

    final newPosition = Position(x: command.x, y: command.y);

    // Validate the move
    if (_currentRover != null) {
      _validator.validateMove(
        from: _currentRover!.position,
        to: newPosition,
        grid: _currentGrid!,
        isFirstMove: _isFirstMove,
      );
    } else {
      // First move - just validate boundaries
      _validator.validatePositionInBounds(newPosition, _currentGrid!);
    }

    // Create or update rover
    final newRover = Rover(position: newPosition);

    // Add to history
    if (_currentRover != null) {
      _history.add(_currentRover!);
    }

    _currentRover = newRover;
    _isFirstMove = false;

    // Emit new state
    emit(RoverMoving(
      grid: _currentGrid!,
      rover: _currentRover!,
      history: List.from(_history),
    ));
  }

  /// Handles errors during command processing
  void _handleError(Object error) {
    String errorMessage;

    if (error is Failure) {
      errorMessage = error.message;
    } else {
      errorMessage = 'An unexpected error occurred: $error';
    }

    // Cancel the stream on error
    _commandSubscription?.cancel();

    emit(RoverError(
      message: errorMessage,
      grid: _currentGrid,
      rover: _currentRover,
      history: _history,
    ));
  }

  /// Handles successful completion of all commands
  void _handleCompletion() {
    if (_currentGrid != null && _currentRover != null) {
      emit(RoverSuccess(
        grid: _currentGrid!,
        rover: _currentRover!,
        history: List.from(_history),
      ));
    } else {
      emit(const RoverError(
        message: 'Mission completed but grid or rover not initialized',
      ));
    }
  }

  /// Resets the mission state
  void reset() {
    _reset();
    emit(const RoverInitial());
  }

  /// Internal reset logic
  void _reset() {
    _commandSubscription?.cancel();
    _commandSubscription = null;
    _currentRepository?.cancelStream();
    _currentRepository = null;
    _currentGrid = null;
    _currentRover = null;
    _history.clear();
    _isFirstMove = true;
  }

  @override
  Future<void> close() {
    _commandSubscription?.cancel();
    _currentRepository?.cancelStream();
    return super.close();
  }
}
