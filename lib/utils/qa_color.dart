import 'package:flutter/material.dart';

class QaColor {
  QaColor._();
  static ColorScheme of(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
}
