import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/confidence_bar.dart';
import '../widgets/severity_badge.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    double confidence = double.parse(
        resultData["confidence_score"].replaceAll("%", "")
    ) / 100;

    Map<String, dynamic> probabilities =
        resultData["probabilities"] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Brain MRI Result",
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(0xFF1976D2), // Medical blue
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)], // Subtle blue gradient
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧠 Classification Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "AI Classification",
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        resultData["classification"]
                            .toString()
                            .replaceAll("_", " ")
                            .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ConfidenceBar(value: confidence),
                      const SizedBox(height: 20),
                      SeverityBadge(
                          severity: resultData["severity"] ?? "Unknown"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 📊 Probability Breakdown
              Text(
                "Probability Breakdown",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),

              const SizedBox(height: 15),

              ...probabilities.entries.map((entry) {
                double value = double.parse(
                    entry.value.toString().replaceAll("%", "")) /
                    100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.replaceAll("_", " "),
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade300,
                            color: Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            entry.value,
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),

              // 📄 Download Report Button
              if (resultData["report_file"] != null)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(
                      "Download Medical Report",
                      style: GoogleFonts.roboto(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      final url =
                          "http://localhost:3000/reports/${resultData["report_file"]}";

                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // ⚠ Disclaimer
              const Divider(),
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Text(
                  "⚠ This report is AI-generated and intended for screening support only. "
                      "It does not replace professional medical diagnosis.",
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}