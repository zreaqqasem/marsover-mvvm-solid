import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onStart;
  final bool isEnabled;
  final String buttonText;

  const ControlPanel({
    super.key,
    required this.onStart,
    this.isEnabled = true,
    this.buttonText = 'Start Mission',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: isEnabled ? onStart : null,
            icon: const Icon(Icons.play_arrow),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
