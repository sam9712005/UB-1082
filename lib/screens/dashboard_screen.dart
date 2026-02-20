import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  bool isAnalyzing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImage = picked;
        selectedImageBytes = bytes;
      });
      _animationController.forward(from: 0.0);
    }
  }

  Future pickImageFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImage = picked;
        selectedImageBytes = bytes;
      });
      _animationController.forward(from: 0.0);
    }
  }

  void analyze() async {
    if (selectedImage == null) return;

    setState(() {
      isAnalyzing = true;
    });

    var result = await ApiService.uploadMRI(selectedImage!);

    setState(() {
      isAnalyzing = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(resultData: result),
      ),
    );
  }

  void logout() async {
    await ApiService.saveToken('');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AI Med Scan",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF1976D2), // Medical blue
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.medical_services, color: Colors.white),
            onPressed: () {}, // Could add a help or info dialog
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)], // Subtle blue gradient
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Brain Tumor Detection",
                          style: GoogleFonts.roboto(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Upload or capture an MRI scan for instant AI analysis",
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[100],
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Image.memory(
                                    selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_search,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No MRI Selected",
                                    style: GoogleFonts.roboto(
                                      fontSize: 18,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: pickImage,
                                icon: Icon(Icons.photo_library),
                                label: Text("Gallery"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: pickImageFromCamera,
                                icon: Icon(Icons.camera_alt),
                                label: Text("Camera"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isAnalyzing ? null : analyze,
                            icon: isAnalyzing
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Icon(Icons.analytics),
                            label: Text(isAnalyzing ? "Analyzing..." : "Analyze MRI"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50), // Medical green
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => HistoryScreen()),
                            );
                          },
                          icon: Icon(Icons.history, color: Color(0xFF1976D2)),
                          label: Text("View History"),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0xFF1976D2)),
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}