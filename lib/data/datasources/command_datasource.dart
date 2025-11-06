import 'package:marsrover/mars_rover_commands.dart';

class CommandDataSource {
  final MarsRoverCommands _marsRoverCommands;

  CommandDataSource(this._marsRoverCommands);

  Stream<Map<String, dynamic>> getCommandStream() {
    return _marsRoverCommands.marsRoverCommandStream;
  }
}
