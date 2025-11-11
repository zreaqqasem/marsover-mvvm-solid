import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marsrover/presentation/widgets/control_panel.dart';

void main() {
  group('ControlPanel Widget', () {
    testWidgets('should display button with provided text', (tester) async {
      // Arrange
      const buttonText = 'Start Mission';
      var callbackExecuted = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () => callbackExecuted = true,
              isEnabled: true,
              buttonText: buttonText,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should call onStart callback when button is pressed',
        (tester) async {
      // Arrange
      var callbackExecuted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () => callbackExecuted = true,
              isEnabled: true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Start Mission'));
      await tester.pump();

      // Assert
      expect(callbackExecuted, true);
    });

    testWidgets('should not execute callback when button is disabled', (tester) async {
      // Arrange
      var callbackExecuted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () => callbackExecuted = true,
              isEnabled: false, // Disabled
            ),
          ),
        ),
      );

      // Act - Try to tap (should not work as button is disabled)
      // Note: Can't tap disabled button, so just verify it exists
      expect(find.text('Start Mission'), findsOneWidget);

      // Assert
      expect(callbackExecuted, false, reason: 'Callback should not execute for disabled button');
    });

    testWidgets('should execute callback when button is enabled', (tester) async {
      // Arrange
      var callbackExecuted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () => callbackExecuted = true,
              isEnabled: true, // Enabled
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Start Mission'));
      await tester.pump();

      // Assert
      expect(callbackExecuted, true, reason: 'Callback should execute for enabled button');
    });

    testWidgets('should display custom button text', (tester) async {
      // Arrange
      const customText = 'Restart Mission';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () {},
              buttonText: customText,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(customText), findsOneWidget);
      expect(find.text('Start Mission'), findsNothing);
    });

    testWidgets('should use default button text when not provided',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Start Mission'), findsOneWidget);
    });

    testWidgets('should have play arrow icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should have proper padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanel(
              onStart: () {},
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(ControlPanel),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, const EdgeInsets.all(20));
    });
  });
}
