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
      final result = await _apiService.login(
        email: email,
        password: password,
      );

      // --- DEBUGGING: Print the API response ---
      if (kDebugMode) {
        print('API Login Response: $result');
      }
      // -----------------------------------------

      if (result['success'] == true) {
        final token = result['token'] as String? ?? '';
        final firstName = result['firstName'] as String? ?? '';
        final lastName = result['lastName'] as String? ?? '';
        await AuthController.saveLogin(token, firstName, lastName);

        isLoading = false;
        onStateChanged?.call();
        return true;
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
