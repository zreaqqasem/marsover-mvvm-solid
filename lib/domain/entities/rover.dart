import 'package:equatable/equatable.dart';
import 'package:marsrover/domain/entities/position.dart';

/// Domain entity representing the Mars Rover
/// Immutable and follows Entity pattern
class Rover extends Equatable {
  final Position position;

  const Rover({
    required this.position,
  });

  /// Creates a new rover at a specific position
  factory Rover.at(int x, int y) {
    return Rover(position: Position(x: x, y: y));
  }

  /// Moves the rover to a new position
  /// Returns a new Rover instance (immutability)
  Rover moveTo(Position newPosition) {
    return Rover(position: newPosition);
  }

  /// Creates a copy of this rover with optional parameter overrides
  Rover copyWith({
    Position? position,
  }) {
    return Rover(
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [position];

  @override
  String toString() => 'Rover(position: $position)';
}
