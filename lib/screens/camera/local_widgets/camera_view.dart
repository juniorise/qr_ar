import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qr_ar/main.dart';
import 'package:qr_ar/tflite/classifier.dart';
import 'package:qr_ar/tflite/recognition.dart';
import 'package:qr_ar/tflite/stats.dart';
import 'package:qr_ar/utils/camera_view_singleton.dart';
import 'package:qr_ar/utils/isolate_data.dart';
import 'package:qr_ar/utils/isolate_utils.dart';
import 'dart:isolate';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
    required this.resultsCallback,
    required this.statsCallback,
  }) : super(key: key);

  final void Function(List<Recognition> recognitions) resultsCallback;
  final void Function(Stats stats) statsCallback;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late CameraController controller;
  late Classifier classifier;
  late IsolateUtils isolateUtils;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    initAsync();
    initCamera();
    super.initState();
  }

  Future<void> initAsync() async {
    controller = CameraController(
      cameras[1],
      ResolutionPreset.low,
    );

    classifier = Classifier();
    isolateUtils = IsolateUtils();

    await isolateUtils.start();
  }

  void initCamera() {
    controller.initialize().then((_) {
      if (!mounted) return;
      controller.startImageStream(onImageStream);

      Size previewSize = controller.value.previewSize!;
      CameraViewSingleton.inputImageSize = previewSize;
      Size screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;

      setState(() {});
    });
  }

  void onImageStream(CameraImage image) async {
    IsolateData isolateData = IsolateData(
      cameraImage: image,
      interpreterAddress: classifier.interpreter!.address,
      labels: classifier.labels ?? [],
    );
    Map<String, dynamic> inferenceResults = await inference(isolateData);

    widget.resultsCallback(inferenceResults["recognitions"]);
    widget.statsCallback((inferenceResults["stats"]));
  }

  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils.sendPort?.send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        controller.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!controller.value.isStreamingImages) {
          await controller.startImageStream(onImageStream);
        }
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) => buildCamera();

  Widget buildCamera() {
    if (!controller.value.isInitialized) return const SizedBox();
    return CameraPreview(controller);
  }
}
