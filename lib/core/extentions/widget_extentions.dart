import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  Widget get expanded => Expanded(child: this);
  Widget get flexible => Flexible(child: this);

  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddingHorizontal(double value) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value),
    child: this,
  );

  Widget paddingVertical(double value) => Padding(
    padding: EdgeInsets.symmetric(vertical: value),
    child: this,
  );

  Widget onTap(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: this,
  );
}
