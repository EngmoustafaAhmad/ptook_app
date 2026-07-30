import 'package:flutter/material.dart';

extension SpacingExtensions on num {
  // Empty space shortcuts
  Widget get vs => SizedBox(height: toDouble());
  Widget get hs => SizedBox(width: toDouble());

  // Padding shortcuts
  EdgeInsets get padAll => EdgeInsets.all(toDouble());
  EdgeInsets get padV => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get padH => EdgeInsets.symmetric(horizontal: toDouble());
}