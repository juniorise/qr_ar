import 'package:flutter/material.dart';
import 'package:qr_ar/screens/camera/local_widgets/box_widgets.dart';
import 'package:qr_ar/screens/camera/local_widgets/camera_view.dart';
import 'package:qr_ar/tflite/recognition.dart';
import 'package:qr_ar/tflite/stats.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late ValueNotifier<List<Recognition>> resultNotifier;
  late ValueNotifier<Stats?> statsNotifier;

  @override
  void initState() {
    resultNotifier = ValueNotifier([]);
    statsNotifier = ValueNotifier(null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Camera"),
      ),
      body: buildBody(),
      bottomNavigationBar: buildBottomNavigation(),
    );
  }

  Widget buildBody() {
    return ValueListenableBuilder<List<Recognition>>(
      valueListenable: resultNotifier,
      child: CameraView(
        resultsCallback: (result) {
          resultNotifier.value = result;
        },
        statsCallback: (stats) {
          statsNotifier.value = stats;
        },
      ),
      builder: (context, value, camera) {
        return Stack(
          children: [
            camera ?? const SizedBox(),
            ...resultNotifier.value.map((e) {
              return BoxWidget(result: e);
            }).toList()
          ],
        );
      },
    );
  }

  Widget buildBottomNavigation() {
    return ValueListenableBuilder<Stats?>(
      valueListenable: statsNotifier,
      builder: (context, value, child) {
        return SizedBox(
          width: double.infinity,
          height: kToolbarHeight,
          child: Row(
            children: [
              Text(value?.inferenceTime.toString() ?? ""),
              Text(value?.preProcessingTime.toString() ?? ""),
              Text(value?.totalElapsedTime.toString() ?? ""),
              Text(value?.totalPredictTime.toString() ?? ""),
            ],
          ),
        );
      },
    );
  }
}
