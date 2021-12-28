import 'dart:isolate';

import 'package:camera/camera.dart';

class IsolateData {
  CameraImage cameraImage;
  int interpreterAddress;
  List<String> labels;
  SendPort? responsePort;

  IsolateData({
    required this.cameraImage,
    required this.interpreterAddress,
    required this.labels,
  });
}
