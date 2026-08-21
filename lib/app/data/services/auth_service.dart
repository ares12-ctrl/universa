import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_udid/flutter_udid.dart';
import 'package:uuid/uuid.dart';
import '../models/profile_model.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://universa-academy.site';

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
  }

  Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'username');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isFirstTime() async {
    String? seen = await _storage.read(key: 'has_seen_onboarding');
    return seen == null;
  }

  Future<void> completeOnboarding() async {
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
  }

  Future<String> getDeviceId() async {
    try {
      // Try to read existing valid UUID
      String? deviceId = await _storage.read(key: 'device_id');
      
      // Check if it's a valid UUID
      bool isValid = false;
      if (deviceId != null) {
        try {
          Uuid.parse(deviceId);
          isValid = true;
        } catch (_) {
          isValid = false;
        }
      }

      if (!isValid) {
        // Get raw hardware ID
        String rawId = await FlutterUdid.consistentUdid;
        
        // Generate a consistent UUID v5 based on the raw hardware ID
        // Using a fixed namespace ensures the same device always gets the same UUID
        deviceId = const Uuid().v5(Uuid.NAMESPACE_URL, rawId);
        
        // Save the valid UUID
        await _storage.write(key: 'device_id', value: deviceId);
      }
      
      return deviceId!;
    } catch (e) {
      // Fallback: Generate a random UUID v4 if everything else fails
      final randomUuid = const Uuid().v4();
      await _storage.write(key: 'device_id', value: randomUuid);
      return randomUuid; 
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/mobile/auth/login/');
    final deviceId = await getDeviceId();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "device_id": deviceId,
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        return {'success': false, 'errors': {'general': ['حدث خطأ غير متوقع في الخادم']}};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        if (kDebugMode) {
          debugPrint('--- DEBUG ACCESS TOKEN (LOGIN) ---');
          debugPrint(data['access']);
          debugPrint('----------------------------------');
        }
        return {'success': true, 'data': data};
      } else {
        // Error
        return {'success': false, 'errors': data};
      }
    } catch (e) {
      return {'success': false, 'errors': {'general': ['لا يوجد اتصال بالإنترنت أو الخادم غير متاح']}};
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse('$_baseUrl/api/mobile/auth/register/');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "password": password,
          "password2": password2,
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        return {'success': false, 'errors': {'general': ['حدث خطأ غير متوقع في الخادم']}};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        if (kDebugMode) {
          debugPrint('--- DEBUG ACCESS TOKEN (REGISTER) ---');
          debugPrint(data['access']);
          debugPrint('-------------------------------------');
        }
        return {'success': true, 'data': data};
      } else {
        // Error
        return {'success': false, 'errors': data};
      }
    } catch (e) {
      return {'success': false, 'errors': {'general': ['لا يوجد اتصال بالإنترنت أو الخادم غير متاح']}};
    }
  }

  Future<Profile?> getProfile() async {
    final url = Uri.parse('$_baseUrl/api/mobile/me/');
    final token = await getAccessToken();
    
    if (token == null) return null;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Profile.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
    return null;
  }
}

