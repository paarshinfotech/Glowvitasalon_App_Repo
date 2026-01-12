import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:glow_vita_salon/controller/auth_controller.dart';
import '../services/api_service.dart';

class LoginController {
  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  final ApiService _apiService = ApiService();

  Function()? onStateChanged;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    return null;
  }

  void setEmail(String value) {
    email = value;
    _clearError();
    onStateChanged?.call();
  }

  void setPassword(String value) {
    password = value;
    _clearError();
    onStateChanged?.call();
  }

  void _clearError() {
    errorMessage = null;
  }

  Future<bool> login() async {
    isLoading = true;
    errorMessage = null;
    onStateChanged?.call();

    try {
      final result = await _apiService.login(email: email, password: password);

      // --- DEBUGGING: Print the API response ---
      if (kDebugMode) {
        print('API Login Response: $result');
      }
      // -----------------------------------------

      // Some APIs might not return success: true but just the token
      if (result['success'] == true ||
          (result['token'] != null) ||
          (result['data'] != null && result['data']['token'] != null)) {
        String token = result['token'] as String? ?? '';
        // Check for various token keys
        if (token.isEmpty) token = result['access_token'] as String? ?? '';
        if (token.isEmpty) token = result['accessToken'] as String? ?? '';

        // Handle nested token in 'data'
        if (token.isEmpty && result['data'] != null && result['data'] is Map) {
          final data = result['data'];
          token = data['token'] as String? ?? '';
          if (token.isEmpty) token = data['access_token'] as String? ?? '';
          if (token.isEmpty) token = data['accessToken'] as String? ?? '';
        }
        // Handle nested token in 'authorization' (common in some frameworks)
        if (token.isEmpty &&
            result['authorization'] != null &&
            result['authorization'] is Map) {
          final auth = result['authorization'];
          token = auth['token'] as String? ?? '';
        }

        print("DEBUG: Extracted Token: $token"); // Debug print

        // Robust User Extraction
        Map<String, dynamic> user = {};
        if (result['user'] != null && result['user'] is Map) {
          user = result['user'];
        } else if (result['data'] != null) {
          if (result['data'] is Map && result['data']['user'] != null) {
            user = result['data']['user'];
          } else if (result['data'] is Map &&
              result['data']['profile'] != null) {
            user = result['data']['profile'];
          } else if (result['data'] is Map) {
            // Sometimes user data is directly in 'data'
            user = result['data'] as Map<String, dynamic>;
          }
        }

        final firstName =
            user['firstName'] as String? ??
            user['name'] as String? ??
            user['username'] as String? ??
            user['fullname'] as String? ??
            'User';
        final lastName = user['lastName'] as String? ?? '';

        // Debug
        if (kDebugMode) {
          print("DEBUG LOGGING IN: Name=$firstName $lastName");
        }

        if (token.isNotEmpty) {
          await AuthController.saveLogin(token, firstName, lastName);
          isLoading = false;
          onStateChanged?.call();
          return true;
        } else {
          print(
            "DEBUG: Login successful response but NO TOKEN found in known keys.",
          );
          errorMessage = 'Login failed: No authentication token found.';
          isLoading = false;
          onStateChanged?.call();
          return false;
        }
      } else {
        errorMessage = result['message'] ?? 'Invalid email or password';
        isLoading = false;
        onStateChanged?.call();
        return false;
      }
    } catch (e) {
      errorMessage = 'Network error. Please try again.';
      isLoading = false;
      onStateChanged?.call();
      return false;
    }
  }
}
