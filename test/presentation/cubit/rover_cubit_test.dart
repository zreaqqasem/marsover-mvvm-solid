import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:marsrover/core/errors/failures.dart';
import 'package:marsrover/data/models/command_model.dart';
import 'package:marsrover/domain/entities/grid.dart';
import 'package:marsrover/domain/entities/position.dart';
import 'package:marsrover/domain/entities/rover.dart';
import 'package:marsrover/domain/repositories/command_repository.dart';
import 'package:marsrover/domain/validators/move_validator.dart';
import 'package:marsrover/presentation/cubit/rover_cubit.dart';
import 'package:marsrover/presentation/cubit/rover_state.dart';

// ============================================
// MOCKS - Create mock versions of dependencies
// ============================================

/// Mock CommandRepository using Mocktail
class MockCommandRepository extends Mock implements CommandRepository {}

/// Mock StreamController to control stream manually in tests
class MockStreamController {
  final StreamController<CommandModel> _controller =
      StreamController<CommandModel>();

  Stream<CommandModel> get stream => _controller.stream;

  void add(CommandModel command) {
    _controller.add(command);
  }

  void addError(Object error) {
    _controller.addError(error);
  }

  Future<void> close() async {
    await _controller.close();
  }
}

void main() {
  late RoverCubit cubit;
  late MockCommandRepository mockRepository;
  late MockStreamController mockStreamController;
  late MoveValidator validator;

  setUp(() {
    // Create fresh mocks for each test
    mockRepository = MockCommandRepository();
    mockStreamController = MockStreamController();
    validator = MoveValidator();

    // Setup default mock behavior
    when(() => mockRepository.getCommandStream())
        .thenAnswer((_) => mockStreamController.stream);
    when(() => mockRepository.cancelStream()).thenReturn(null);

    // Create cubit with mock repository factory
    cubit = RoverCubit(
      repositoryFactory: () => mockRepository,
      validator: validator,
    );
  });

  tearDown(() {
    cubit.close();
    mockStreamController.close();
  });

  group('RoverCubit', () {
    group('initial state', () {
      test('should start with RoverInitial state', () {
        // Assert
        expect(cubit.state, const RoverInitial());
      });
    });

    group('startMission', () {
      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading] when starting mission',
        build: () => cubit,
        act: (cubit) => cubit.startMission(),
        expect: () => [const RoverLoading()],
      );

      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverLoading, RoverMoving] when receiving NewMap then Move',
        build: () {
          // Setup: Stream will emit NewMap, then Move command
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 2, y: 2);
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(), // Initial loading
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)), // After NewMap (grid initialized, waiting for move)
          isA<RoverMoving>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5))
              .having((s) => s.rover.position, 'rover.position',
                  const Position(x: 2, y: 2))
              .having((s) => s.history, 'history', isEmpty),
          isA<RoverSuccess>(),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverLoading, RoverMoving, RoverMoving] for two moves',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 2, y: 2); // First move
            yield const MoveCommand(x: 3, y: 2); // Second move (adjacent)
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)),
          isA<RoverMoving>()
              .having((s) => s.rover.position, 'rover.position',
                  const Position(x: 2, y: 2))
              .having((s) => s.history, 'history', isEmpty),
          isA<RoverMoving>()
              .having((s) => s.rover.position, 'rover.position',
                  const Position(x: 3, y: 2))
              .having((s) => s.history.length, 'history.length', 1)
              .having((s) => s.history.first.position, 'history[0].position',
                  const Position(x: 2, y: 2)),
          isA<RoverSuccess>(),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverLoading, RoverMoving, RoverSuccess] when stream completes successfully',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 2, y: 2);
            // Stream closes here (onDone triggered)
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)),
          isA<RoverMoving>(),
          isA<RoverSuccess>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5))
              .having((s) => s.rover.position, 'rover.position',
                  const Position(x: 2, y: 2))
              .having((s) => s.message, 'message',
                  'Mission completed successfully'),
        ],
      );
    });

    group('error handling', () {
      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverError] when move is out of bounds',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 10, y: 10); // Out of bounds!
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)),
          isA<RoverError>()
              .having((s) => s.message, 'message', contains('out of bounds'))
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5))
              .having((s) => s.rover, 'rover', isNull),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverLoading, RoverMoving, RoverError] when second move is not adjacent',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 10, ySize: 10);
            yield const MoveCommand(x: 2, y: 2); // First move (any position)
            yield const MoveCommand(x: 5, y: 5); // Not adjacent!
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 10, height: 10)),
          isA<RoverMoving>(),
          isA<RoverError>()
              .having((s) => s.message, 'message', contains('Invalid move'))
              .having((s) => s.message, 'message', contains('adjacent')),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverError] when Move received before NewMap',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const MoveCommand(x: 2, y: 2); // No NewMap first!
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        expect: () => [
          const RoverLoading(),
          isA<RoverError>().having((s) => s.message, 'message',
              contains('Grid must be initialized')),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should emit [RoverLoading, RoverError] when stream emits error',
        build: () {
          when(() => mockRepository.getCommandStream()).thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            throw Exception('Stream error!');
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)),
          isA<RoverError>().having(
              (s) => s.message, 'message', contains('unexpected error')),
        ],
      );
    });

    group('reset', () {
      blocTest<RoverCubit, RoverState>(
        'should return to RoverInitial state when reset',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 2, y: 2);
          });

          return cubit;
        },
        act: (cubit) async {
          await cubit.startMission();
          await Future.delayed(const Duration(milliseconds: 50));
          cubit.reset();
        },
        skip: 4, // Skip the mission states (RoverLoading, RoverLoading, RoverMoving, RoverSuccess), only check reset
        expect: () => [const RoverInitial()],
      );

      test('should cancel stream subscription when reset', () async {
        // Arrange
        when(() => mockRepository.getCommandStream())
            .thenAnswer((_) => mockStreamController.stream);

        // Act
        await cubit.startMission();
        cubit.reset();

        // Assert
        verify(() => mockRepository.cancelStream()).called(1);
      });
    });

    group('history tracking', () {
      blocTest<RoverCubit, RoverState>(
        'should track rover history correctly across multiple moves',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 10, ySize: 10);
            yield const MoveCommand(x: 5, y: 5); // Move 1
            yield const MoveCommand(x: 6, y: 5); // Move 2
            yield const MoveCommand(x: 7, y: 5); // Move 3
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 10, height: 10)),
          // After move 1
          isA<RoverMoving>()
              .having((s) => s.history.length, 'history.length', 0),
          // After move 2
          isA<RoverMoving>()
              .having((s) => s.history.length, 'history.length', 1)
              .having((s) => s.history[0].position, 'history[0]',
                  const Position(x: 5, y: 5)),
          // After move 3
          isA<RoverMoving>()
              .having((s) => s.history.length, 'history.length', 2)
              .having((s) => s.history[0].position, 'history[0]',
                  const Position(x: 5, y: 5))
              .having((s) => s.history[1].position, 'history[1]',
                  const Position(x: 6, y: 5)),
          isA<RoverSuccess>(),
        ],
      );
    });

    group('complex scenarios', () {
      blocTest<RoverCubit, RoverState>(
        'should handle diagonal moves correctly',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 10, ySize: 10);
            yield const MoveCommand(x: 5, y: 5);
            yield const MoveCommand(x: 6, y: 6); // Diagonal move
            yield const MoveCommand(x: 7, y: 7); // Diagonal move
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 10, height: 10)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 5, y: 5)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 6, y: 6)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 7, y: 7)),
          isA<RoverSuccess>(),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should handle rover at edge of grid',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 0, y: 0); // Corner
            yield const MoveCommand(x: 1, y: 0); // Edge move
            yield const MoveCommand(x: 1, y: 1); // Valid move
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 0, y: 0)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 1, y: 0)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 1, y: 1)),
          isA<RoverSuccess>(),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should fail when trying to move outside from edge',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 5, ySize: 5);
            yield const MoveCommand(x: 4, y: 4); // Max corner
            yield const MoveCommand(x: 5, y: 4); // Try to go outside!
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 5, height: 5)),
          isA<RoverMoving>(),
          isA<RoverError>()
              .having((s) => s.message, 'message', contains('out of bounds')),
        ],
      );
    });

    group('first move validation', () {
      blocTest<RoverCubit, RoverState>(
        'should allow first move to any position on grid',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 10, ySize: 10);
            yield const MoveCommand(x: 7, y: 8); // Can be anywhere
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 10, height: 10)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 7, y: 8)),
          isA<RoverSuccess>(),
        ],
      );

      blocTest<RoverCubit, RoverState>(
        'should enforce adjacency on second move',
        build: () {
          when(() => mockRepository.getCommandStream())
              .thenAnswer((_) async* {
            yield const NewMapCommand(xSize: 10, ySize: 10);
            yield const MoveCommand(x: 2, y: 2); // First move
            yield const MoveCommand(x: 3, y: 2); // Must be adjacent
          });

          return cubit;
        },
        act: (cubit) => cubit.startMission(),
        wait: const Duration(milliseconds: 100), // Wait for stream to close
        expect: () => [
          const RoverLoading(),
          isA<RoverLoading>()
              .having((s) => s.grid, 'grid', const Grid(width: 10, height: 10)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 2, y: 2)),
          isA<RoverMoving>()
              .having(
                  (s) => s.rover.position, 'position', const Position(x: 3, y: 2)),
          isA<RoverSuccess>(),
        ],
      );
    });
  });
}
