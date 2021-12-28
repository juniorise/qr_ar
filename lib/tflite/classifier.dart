/// Reference: https://medium.com/@am15hg/real-time-object-detection-using-new-tensorflow-lite-flutter-support-ea41263e801d
///
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:qr_ar/gen/assets.gen.dart';
import 'package:qr_ar/tflite/recognition.dart';
import 'package:qr_ar/tflite/stats.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  Interpreter? _interpreter;

  /// Labels file loaded as list
  List<String>? _labels;

  static String modelPath = Assets.models.detect.replaceFirst("assets/", "");
  static String labelPath = Assets.models.labelmap;

  /// Input size of image (height = width = 300)
  static const int inputSize = 300;

  /// Result score threshold
  static const double threshold = 0.5;

  /// [ImageProcessor] used to pre-process the image
  ImageProcessor? imageProcessor;

  /// Padding the image to transform into square
  int? padSize;

  /// Shapes of output tensors
  List<List<int>>? _outputShapes;

  /// Types of output tensors
  List<TfLiteType>? _outputTypes;

  /// Number of results to show
  static const int numResults = 10;

  Classifier({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelPath,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter!.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      for (Tensor tensor in outputTensors) {
        _outputShapes?.add(tensor.shape);
        _outputTypes?.add(tensor.type);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while creating interpreter: $e");
      }
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels = labels ?? await FileUtil.loadLabels(labelPath);
    } catch (e) {
      if (kDebugMode) {
        print("Error while loading labels: $e");
      }
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    imageProcessor ??= ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize!, padSize!))
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .build();

    inputImage = imageProcessor!.process(inputImage);
    return inputImage;
  }

  /// Runs object detection on the input image
  Map<String, dynamic>? predict(image_lib.Image image) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      if (kDebugMode) {
        print("Interpreter not initialized");
      }
      return null;
    }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime = DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // TensorBuffers for output tensors
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes![0]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes![1]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes![2]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes![3]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    _interpreter?.runForMultipleInputs(inputs, outputs);

    var inferenceTimeElapsed = DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(numResults, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: inputSize,
      width: inputSize,
    );

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      double score = outputScores.getDoubleValue(i);

      // Label string
      int labelIndex = outputClasses.getIntValue(i) + labelOffset;
      String? label = _labels?.elementAt(labelIndex);

      if (score > threshold) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor!.inverseTransformRect(locations[i], image.height, image.width);

        recognitions.add(
          Recognition(i, label, score, transformedRect),
        );
      }
    }

    int predictElapsedTime = DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      "recognitions": recognitions,
      "stats": Stats(
        totalPredictTime: predictElapsedTime,
        inferenceTime: inferenceTimeElapsed,
        preProcessingTime: preProcessElapsedTime,
      )
    };
  }

  /// Gets the interpreter instance
  Interpreter? get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String>? get labels => _labels;
}
