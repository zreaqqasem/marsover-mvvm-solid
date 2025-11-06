import 'dart:async';

import 'package:marsrover/data/datasources/command_datasource.dart';
import 'package:marsrover/data/models/command_model.dart';
import 'package:marsrover/domain/repositories/command_repository.dart';

class CommandRepositoryImpl implements CommandRepository {
  final CommandDataSource _dataSource;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  CommandRepositoryImpl(this._dataSource);

  @override
  Stream<CommandModel> getCommandStream() {
    // Transform raw Map data into typed CommandModel objects
    return _dataSource.getCommandStream().map((json) {
      return CommandModel.fromJson(json);
    });
  }

  @override
  void cancelStream() {
    _subscription?.cancel();
    _subscription = null;
  }
}
