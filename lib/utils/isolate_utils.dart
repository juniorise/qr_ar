import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as image_lib;
import 'package:qr_ar/tflite/classifier.dart';
import 'package:qr_ar/utils/image_utils.dart';
import 'package:qr_ar/utils/isolate_data.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Manages separate Isolate instance for inference
class IsolateUtils {
  static const String debugName = "InferenceIsolate";
  final ReceivePort _receivePort = ReceivePort();

  SendPort? _sendPort;
  SendPort? get sendPort => _sendPort;

  Future<void> start() async {
    await Isolate.spawn<SendPort>(entryPoint, _receivePort.sendPort, debugName: debugName);
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);
    await for (final IsolateData? isolateData in port) {
      if (isolateData != null) {
        Classifier classifier = Classifier(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
          labels: isolateData.labels,
        );

        image_lib.Image? image = ImageUtils.convertCameraImage(isolateData.cameraImage);
        if (Platform.isAndroid && image != null) {
          image = image_lib.copyRotate(image, 90);
        }
        Map<String, dynamic>? results = classifier.predict(image!);
        isolateData.responsePort?.send(results);
      }
    }
  }
}
