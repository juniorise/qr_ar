import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qr_ar/app.dart';

List<CameraDescription> cameras = [];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(
    const App(),
  );
}
