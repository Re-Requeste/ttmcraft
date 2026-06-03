import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://ttmcraft.ru/api';
  String? _token;
  Map<String, dynamic>? _currentPatient;
  bool _isLoading = false;

  String? get token => _token;
  Map<String, dynamic>? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
    notifyListeners();
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    return _token;
  }

  Future<void> logout() async {
    _token = null;
    _currentPatient = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await saveToken(data['token']);
        _currentPatient = data['user'];
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'user': data['user']};
      } else {
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getPatientData() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'error': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patients.php'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _currentPatient = data['patient'];
        notifyListeners();
      }
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMessages() async {
    final token = await getToken();
    if (token == null) return {'success': false, 'error': 'Not authenticated'};

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages.php'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final token = await getToken();
    if (token == null) return {'success': false, 'error': 'Not authenticated'};

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}