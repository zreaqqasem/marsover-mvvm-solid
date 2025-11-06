import 'package:marsrover/data/models/command_model.dart';

abstract class CommandRepository {
  Stream<CommandModel> getCommandStream();
  void cancelStream();
}
