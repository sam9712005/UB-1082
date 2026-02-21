import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiService {
  // Use localhost for local development; replace with your machine IP for other devices
  static const baseUrl = "https://ub-1082-production.up.railway.app";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    // Debug output to help diagnose failures on device builds
    print('register response: ${response.statusCode} ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Registration failed');
      } catch (_) {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    // Debug output to help diagnose failures on device builds
    print('login response: ${response.statusCode} ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Login failed');
      } catch (_) {
        throw Exception('Login failed: ${response.statusCode}');
      }
    }

    final data = jsonDecode(response.body);
    final token = data["token"];
    if (token == null) throw Exception('Login did not return a token');

    await saveToken(token);
    return data;
  }

  static Future<Map<String, dynamic>> uploadMRI(XFile image) async {
    String? token = await getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/predict"),
    );

    request.headers["Authorization"] = "Bearer $token";

    // On web XFile.path may be empty; send bytes in that case.
    if (!kIsWeb && image.path != null && image.path.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath("mri", image.path),
      );
    } else {
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes("mri", bytes, filename: 'upload.jpg'),
      );
    }
    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    return jsonDecode(responseData);
  }

  static Future<List> getHistory() async {
    String? token = await getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/history"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }

  static Future<void> downloadReport(String reportFile) async {
    final url = Uri.parse("$baseUrl/reports/$reportFile");
    await launchUrl(url);
  }
}