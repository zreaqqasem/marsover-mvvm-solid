import 'package:flutter_test/flutter_test.dart';
import 'package:marsrover/core/errors/failures.dart';
import 'package:marsrover/data/models/command_model.dart';

void main() {
  group('CommandModel.fromJson', () {
    group('NewMapCommand', () {
      test('should parse valid NewMap command', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': 5,
          'ysize': 7,
        };

        // Act
        final result = CommandModel.fromJson(json);

        // Assert
        expect(result, isA<NewMapCommand>());
        final command = result as NewMapCommand;
        expect(command.xSize, 5);
        expect(command.ySize, 7);
      });

      test('should throw CommandParsingFailure when xsize is missing', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'ysize': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('missing xsize or ysize'),
            ),
          ),
        );
      });

      test('should throw CommandParsingFailure when ysize is missing', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': 5,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('missing xsize or ysize'),
            ),
          ),
        );
      });

      test('should throw CommandParsingFailure when xsize is zero', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': 0,
          'ysize': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('must be positive'),
            ),
          ),
        );
      });

      test('should throw CommandParsingFailure when ysize is zero', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': 5,
          'ysize': 0,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('must be positive'),
            ),
          ),
        );
      });

      test('should throw CommandParsingFailure when xsize is negative', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': -1,
          'ysize': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(isA<CommandParsingFailure>()),
        );
      });

      test('should throw CommandParsingFailure when ysize is negative', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': 5,
          'ysize': -1,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(isA<CommandParsingFailure>()),
        );
      });

      test('should handle large grid sizes', () {
        // Arrange
        final json = {
          'cmd': 'NewMap',
          'xsize': 100,
          'ysize': 100,
        };

        // Act
        final result = CommandModel.fromJson(json);

        // Assert
        expect(result, isA<NewMapCommand>());
        final command = result as NewMapCommand;
        expect(command.xSize, 100);
        expect(command.ySize, 100);
      });
    });

    group('MoveCommand', () {
      test('should parse valid Move command', () {
        // Arrange
        final json = {
          'cmd': 'Move',
          'x': 3,
          'y': 5,
        };

        // Act
        final result = CommandModel.fromJson(json);

        // Assert
        expect(result, isA<MoveCommand>());
        final command = result as MoveCommand;
        expect(command.x, 3);
        expect(command.y, 5);
      });

      test('should parse Move command with zero coordinates', () {
        // Arrange
        final json = {
          'cmd': 'Move',
          'x': 0,
          'y': 0,
        };

        // Act
        final result = CommandModel.fromJson(json);

        // Assert
        expect(result, isA<MoveCommand>());
        final command = result as MoveCommand;
        expect(command.x, 0);
        expect(command.y, 0);
      });

      test('should parse Move command with negative coordinates', () {
        // Arrange
        final json = {
          'cmd': 'Move',
          'x': -1,
          'y': -2,
        };

        // Act
        final result = CommandModel.fromJson(json);

        // Assert
        expect(result, isA<MoveCommand>());
        final command = result as MoveCommand;
        expect(command.x, -1);
        expect(command.y, -2);
        // Note: Negative coordinates are parsed but will be validated later
      });

      test('should throw CommandParsingFailure when x is missing', () {
        // Arrange
        final json = {
          'cmd': 'Move',
          'y': 5,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('missing x or y'),
            ),
          ),
        );
      });

      test('should throw CommandParsingFailure when y is missing', () {
        // Arrange
        final json = {
          'cmd': 'Move',
          'x': 3,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('missing x or y'),
            ),
          ),
        );
      });

      test('should handle large coordinate values', () {
        // Arrange
        final json = {
          'cmd': 'Move',
          'x': 999,
          'y': 999,
        };

        // Act
        final result = CommandModel.fromJson(json);

        // Assert
        expect(result, isA<MoveCommand>());
        final command = result as MoveCommand;
        expect(command.x, 999);
        expect(command.y, 999);
      });
    });

    group('Invalid Commands', () {
      test('should throw CommandParsingFailure when cmd field is missing', () {
        // Arrange
        final json = {
          'xsize': 5,
          'ysize': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<CommandParsingFailure>().having(
              (e) => e.message,
              'message',
              contains('Missing cmd field'),
            ),
          ),
        );
      });

      test('should throw InvalidCommandFailure for unknown command type', () {
        // Arrange
        final json = {
          'cmd': 'Jump',
          'x': 5,
          'y': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(
            isA<InvalidCommandFailure>().having(
              (e) => e.message,
              'message',
              contains('Invalid command received: Jump'),
            ),
          ),
        );
      });

      test('should throw InvalidCommandFailure for empty command string', () {
        // Arrange
        final json = {
          'cmd': '',
          'x': 5,
          'y': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(isA<InvalidCommandFailure>()),
        );
      });

      test('should be case-sensitive for command names', () {
        // Arrange - lowercase "move" instead of "Move"
        final json = {
          'cmd': 'move',
          'x': 5,
          'y': 7,
        };

        // Act & Assert
        expect(
          () => CommandModel.fromJson(json),
          throwsA(isA<InvalidCommandFailure>()),
        );
      });
    });

    group('Equality', () {
      test('NewMapCommand should be equal with same values', () {
        // Arrange
        const command1 = NewMapCommand(xSize: 5, ySize: 7);
        const command2 = NewMapCommand(xSize: 5, ySize: 7);

        // Act & Assert
        expect(command1, command2);
        expect(command1.hashCode, command2.hashCode);
      });

      test('NewMapCommand should not be equal with different values', () {
        // Arrange
        const command1 = NewMapCommand(xSize: 5, ySize: 7);
        const command2 = NewMapCommand(xSize: 6, ySize: 7);

        // Act & Assert
        expect(command1, isNot(command2));
      });

      test('MoveCommand should be equal with same values', () {
        // Arrange
        const command1 = MoveCommand(x: 3, y: 5);
        const command2 = MoveCommand(x: 3, y: 5);

        // Act & Assert
        expect(command1, command2);
        expect(command1.hashCode, command2.hashCode);
      });

      test('MoveCommand should not be equal with different values', () {
        // Arrange
        const command1 = MoveCommand(x: 3, y: 5);
        const command2 = MoveCommand(x: 4, y: 5);

        // Act & Assert
        expect(command1, isNot(command2));
      });
    });

    group('toString', () {
      test('NewMapCommand should return formatted string', () {
        // Arrange
        const command = NewMapCommand(xSize: 5, ySize: 7);

        // Act
        final result = command.toString();

        // Assert
        expect(result, 'NewMapCommand(xSize: 5, ySize: 7)');
      });

      test('MoveCommand should return formatted string', () {
        // Arrange
        const command = MoveCommand(x: 3, y: 5);

        // Act
        final result = command.toString();

        // Assert
        expect(result, 'MoveCommand(x: 3, y: 5)');
      });
    });
  });
}
