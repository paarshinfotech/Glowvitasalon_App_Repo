import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'token';
  static const String _firstNameKey = 'firstName';
  static const String _lastNameKey = 'lastName';

  /// Save login data
  static Future<void> saveLogin(String token, String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_firstNameKey, firstName);
    await prefs.setString(_lastNameKey, lastName);
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
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
  }
}
