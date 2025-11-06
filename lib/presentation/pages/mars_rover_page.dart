import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marsrover/presentation/cubit/rover_cubit.dart';
import 'package:marsrover/presentation/cubit/rover_state.dart';
import 'package:marsrover/presentation/widgets/control_panel.dart';
import 'package:marsrover/presentation/widgets/grid_widget.dart';

class MarsRoverPage extends StatelessWidget {
  const MarsRoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mars Rover Mission'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<RoverCubit, RoverState>(
          listener: (context, state) {
            // Show snackbar for errors
            if (state is RoverError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }

            // Show snackbar for success
            if (state is RoverSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Status indicator
                _buildStatusIndicator(state),

                // Grid visualization
                Expanded(
                  child: _buildContent(state),
                ),
                _buildControlPanel(context, state),
                // Control panel
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(RoverState state) {
    String status;
    Color color;

    if (state is RoverInitial) {
      status = 'Ready to start';
      color = Colors.blue;
    } else if (state is RoverLoading) {
      status = 'Loading...';
      color = Colors.orange;
    } else if (state is RoverMoving) {
      status = 'Rover moving - Position: (${state.rover.position.x}, ${state.rover.position.y})';
      color = Colors.green;
    } else if (state is RoverSuccess) {
      status = 'Mission completed successfully';
      color = Colors.green;
    } else if (state is RoverError) {
      status = 'Error occurred';
      color = Colors.red;
    } else {
      status = 'Unknown state';
      color = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: color.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(state),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(RoverState state) {
    if (state is RoverInitial) {
      return Icons.rocket_launch_outlined;
    } else if (state is RoverLoading) {
      return Icons.hourglass_empty;
    } else if (state is RoverMoving) {
      return Icons.navigation;
    } else if (state is RoverSuccess) {
      return Icons.check_circle;
    } else if (state is RoverError) {
      return Icons.error;
    }
    return Icons.help;
  }

  Widget _buildContent(RoverState state) {
    if (state is RoverInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Press Start Mission to begin',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state is RoverLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Initializing mission...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state is RoverMoving) {
      return GridWidget(
        grid: state.grid,
        rover: state.rover,
        history: state.history,
      );
    }

    if (state is RoverSuccess) {
      return GridWidget(
        grid: state.grid,
        rover: state.rover,
        history: state.history,
      );
    }

    if (state is RoverError) {
      // Show grid if available, otherwise show error message
      if (state.grid != null) {
        return GridWidget(
          grid: state.grid!,
          rover: state.rover,
          history: state.history,
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                state.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildControlPanel(BuildContext context, RoverState state) {
    final cubit = context.read<RoverCubit>();

    String buttonText;
    bool isEnabled;
    VoidCallback onPressed;

    if (state is RoverInitial) {
      buttonText = 'Start Mission';
      isEnabled = true;
      onPressed = cubit.startMission;
    } else if (state is RoverLoading) {
      buttonText = 'Loading...';
      isEnabled = false;
      onPressed = () {};
    } else if (state is RoverMoving) {
      buttonText = 'Mission in progress...';
      isEnabled = false;
      onPressed = () {};
    } else if (state is RoverSuccess || state is RoverError) {
      buttonText = 'Restart Mission';
      isEnabled = true;
      onPressed = () {
        cubit.reset();
        cubit.startMission();
      };
    } else {
      buttonText = 'Start Mission';
      isEnabled = true;
      onPressed = cubit.startMission;
    }

    return ControlPanel(
      onStart: onPressed,
      isEnabled: isEnabled,
      buttonText: buttonText,
    );
  }
}
