import 'package:flutter/material.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;

  SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {

    Color color;

    switch (severity) {
      case "High":
        color = Colors.red;
        break;
      case "Moderate":
        color = Colors.orange;
        break;
      case "Low":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        severity,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}