import 'package:get_it/get_it.dart';
import 'package:marsrover/data/datasources/command_datasource.dart';
import 'package:marsrover/data/repositories/command_repository_impl.dart';
import 'package:marsrover/domain/repositories/command_repository.dart';
import 'package:marsrover/domain/validators/move_validator.dart';
import 'package:marsrover/mars_rover_commands.dart';
import 'package:marsrover/presentation/cubit/rover_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubit
  sl.registerFactory(
    () => RoverCubit(
      repositoryFactory: () => sl<CommandRepository>(),
      validator: sl(),
    ),
  );

  // Validator
  sl.registerLazySingleton(() => MoveValidator());

  // Repository
  sl.registerFactory<CommandRepository>(
    () => CommandRepositoryImpl(sl()),
  );

  // Data source
  sl.registerFactory(
    () => CommandDataSource(sl()),
  );

  // Command generator
  sl.registerFactory(() => MarsRoverCommands());
}
