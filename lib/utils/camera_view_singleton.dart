import 'dart:ui';

/// Singleton to record size related data
class CameraViewSingleton {
  static double ratio = 1.0;
  static Size screenSize = const Size.fromHeight(0);
  static Size inputImageSize = const Size.fromHeight(0);
  static Size get actualPreviewSize => Size(screenSize.width, screenSize.width * ratio);
}
