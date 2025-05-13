// auth_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'api_service.dart';

class AuthService {
  static Future<void> signup(String username, String email, String password) async {
    try {
      final response = await ApiService.post('/auth/signup', {
        'username': username,
        'email': email,
        'password': password,
        'terms_accepted': true,
      });
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Signup failed: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Signup error: $e');
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  static Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception('Login failed: ${errorBody['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<void> verifyEmail(String email, String otp) async {
    final response = await ApiService.post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
    if (response.statusCode != 200) {
      throw Exception('Verification failed: ${response.body}');
    }
  }

  static Future<void> sendOTP(String email) async {
    final response = await ApiService.post('/auth/send-otp', {
      'email': email,
    });
    if (response.statusCode != 200) {
      print('Failed to send OTP: ${response.body}');
      throw Exception('Failed to send OTP: ${response.body}');
    }
    print('OTP sent successfully');
  }

  static Future<void> forgotPassword(String email) async {
    final response = await ApiService.post('/auth/forgot-password', {
      'email': email,
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to send reset link: ${response.body}');
    }
  }
}