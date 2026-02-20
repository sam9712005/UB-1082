import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(AIBrainApp());
}

class AIBrainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AI Brain MRI",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}