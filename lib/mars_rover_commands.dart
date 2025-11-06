import 'dart:async';
import 'dart:math';

class MarsRoverCommands {
  late StreamController<Map<String, dynamic>> _controller;
  bool _cancelled = false;

  //Initialises and return the stream controller for messages
  Stream<Map<String, dynamic>> get marsRoverCommandStream {
    _controller = StreamController(onListen: _onListen, onCancel: _onCancel);
    return _controller.stream;
  }

  void _onListen() {
    late int currentX;
    late int currentY;
    int maxX = Random.secure().nextInt(5) + 5; //Max 10, Min 5
    int maxY = Random.secure().nextInt(5) + 5; // Max 10, Min 5
    int delay = 0;
    const int totalCommands = 10;

    for (int i = 0; i < totalCommands; i++) {
      if(_cancelled) {
        break;
      }
      final bool isLastCommand = (i == totalCommands - 1);

      if (i == 0) {
        Future.delayed(Duration(seconds: 1), () => _addCommand({"cmd": "NewMap", "xsize": maxX, "ysize": maxY}, isLastCommand));
      } else if (i == 1) {
        Future.delayed(Duration(seconds: ++delay), () {
          currentX = Random.secure().nextInt(maxX);
          currentY = Random.secure().nextInt(maxY);
          _addCommand({"cmd": "Move", "x": currentX, "y": currentY}, isLastCommand);
        });
      } else {
        Future.delayed(Duration(seconds: ++delay), () {
          bool xPositive = Random.secure().nextBool();
          bool yPositive = Random.secure().nextBool();
          currentX = xPositive ? currentX + 1 : currentX - 1;
          currentY = yPositive ? currentY + 1 : currentY - 1;
          _addCommand({"cmd": "Move", "x": currentX, "y": currentY}, isLastCommand);
        });
      }
    }
  }
  void _addCommand(Map<String, dynamic> command, [bool isLast = false]) {
    if(!_cancelled) {
      _controller.add(command);

      // Close the stream after the last command
      if (isLast) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (!_cancelled) {
            _controller.close();
          }
        });
      }
    }
  }

  FutureOr<void> _onCancel()  => _cancelled = true;
}
