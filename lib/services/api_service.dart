import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://bankmininadhif.my.id/api/nasabah';

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', data['user']['id'].toString());
        await prefs.setString('token', data['token']);
        await prefs.setString('nasabah_data', jsonEncode(data['nasabah']));
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server backend: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final res = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {'Accept': 'application/json', 'X-User-Id': userId},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMutasi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final res = await http.get(
        Uri.parse('$baseUrl/mutasi'),
        headers: {'Accept': 'application/json', 'X-User-Id': userId},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Koneksi error: $e'};
    }
  }

  static Future<Map<String, dynamic>> lupaPin(String nis, String password, String pinBaru) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/lupa-pin'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'nis': nis, 'password': password, 'pin_baru': pinBaru}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal memproses lupa PIN: $e'};
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/lupa-password/send-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal mengirim OTP: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp, String passwordBaru) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/lupa-password/verify-otp'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp, 'password_baru': passwordBaru}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal verifikasi OTP: $e'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

