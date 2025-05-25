import 'package:flutter/material.dart';
import 'package:frontend/core/utils/translation_helper.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;

  const SubmitButton({
    Key? key,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
        ),
        child: Text(tr(context, 'tripPlanner.generateButton')),
      ),
    );
  }
}
