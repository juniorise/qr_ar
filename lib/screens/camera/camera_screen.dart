import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qr_ar/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;

  @override
  void initState() {
    controller = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );

    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});

      controller.startImageStream((image) {
        // print(image.planes.map((e) => e.));
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildCamera(),
    );
  }

  Widget buildCamera() {
    if (!controller.value.isInitialized) return const SizedBox();
    return Center(
      child: CameraPreview(controller),
    );
  }
}
