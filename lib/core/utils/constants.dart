/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // Command types
  static const String newMapCommand = 'NewMap';
  static const String moveCommand = 'Move';

  // Command keys
  static const String cmdKey = 'cmd';
  static const String xSizeKey = 'xsize';
  static const String ySizeKey = 'ysize';
  static const String xKey = 'x';
  static const String yKey = 'y';

  // UI Constants
  static const double gridCellSize = 40.0;
  static const double gridSpacing = 4.0;
  static const double roverSize = 30.0;
}
