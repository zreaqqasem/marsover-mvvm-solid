import 'package:equatable/equatable.dart';
import 'package:marsrover/core/errors/failures.dart';
import 'package:marsrover/core/utils/constants.dart';

abstract class CommandModel extends Equatable {
  const CommandModel();

  factory CommandModel.fromJson(Map<String, dynamic> json) {
    final cmd = json[AppConstants.cmdKey] as String?;

    if (cmd == null) {
      throw const CommandParsingFailure('Missing cmd field');
    }

    switch (cmd) {
      case AppConstants.newMapCommand:
        return NewMapCommand.fromJson(json);
      case AppConstants.moveCommand:
        return MoveCommand.fromJson(json);
      default:
        throw InvalidCommandFailure(cmd);
    }
  }
}

/// Command to create a new map/grid
class NewMapCommand extends CommandModel {
  final int xSize;
  final int ySize;

  const NewMapCommand({
    required this.xSize,
    required this.ySize,
  });

  factory NewMapCommand.fromJson(Map<String, dynamic> json) {
    try {
      final xSize = json[AppConstants.xSizeKey] as int?;
      final ySize = json[AppConstants.ySizeKey] as int?;

      if (xSize == null || ySize == null) {
        throw const CommandParsingFailure(
          'NewMap command missing xsize or ysize',
        );
      }

      if (xSize <= 0 || ySize <= 0) {
        throw const CommandParsingFailure(
          'Grid dimensions must be positive',
        );
      }

      return NewMapCommand(xSize: xSize, ySize: ySize);
    } catch (e) {
      if (e is Failure) rethrow;
      throw CommandParsingFailure('Failed to parse NewMap command: $e');
    }
  }

  @override
  List<Object?> get props => [xSize, ySize];

  @override
  String toString() => 'NewMapCommand(xSize: $xSize, ySize: $ySize)';
}

/// Command to move the rover to a specific position
class MoveCommand extends CommandModel {
  final int x;
  final int y;

  const MoveCommand({
    required this.x,
    required this.y,
  });

  factory MoveCommand.fromJson(Map<String, dynamic> json) {
    try {
      final x = json[AppConstants.xKey] as int?;
      final y = json[AppConstants.yKey] as int?;

      if (x == null || y == null) {
        throw const CommandParsingFailure(
          'Move command missing x or y coordinate',
        );
      }

      return MoveCommand(x: x, y: y);
    } catch (e) {
      if (e is Failure) rethrow;
      throw CommandParsingFailure('Failed to parse Move command: $e');
    }
  }

  @override
  List<Object?> get props => [x, y];

  @override
  String toString() => 'MoveCommand(x: $x, y: $y)';
}
