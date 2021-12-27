import 'package:flutter/material.dart';

class QaTextTheme {
  QaTextTheme._();
  static TextTheme of(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}
