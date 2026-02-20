import 'package:flutter/material.dart';

class ConfidenceBar extends StatelessWidget {
  final double value;

  ConfidenceBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: value,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          color: Colors.green,
        ),
        SizedBox(height: 8),
        Text("Confidence: ${(value * 100).toStringAsFixed(2)}%"),
      ],
    );
  }
}