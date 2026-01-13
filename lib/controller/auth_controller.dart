import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'token';
  static const String _firstNameKey = 'firstName';
  static const String _lastNameKey = 'lastName';

  static final StreamController<bool> _authStream =
      StreamController<bool>.broadcast();
  static Stream<bool> get onAuthStateChange => _authStream.stream;

  /// Save login data
  static Future<void> saveLogin(
    String token,
    String firstName,
    String lastName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(
      'cookie',
      token,
    ); // Saving as cookie-like entry as requested
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
    _authStream.add(true);
  }

  /// Update user details only
  static Future<void> updateUser(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get User Full Name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_firstNameKey) ?? '';
    final lastName = prefs.getString(_lastNameKey) ?? '';
    return '$firstName $lastName'.trim();
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
    _authStream.add(false);
  }
}
