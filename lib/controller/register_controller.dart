import 'package:glow_vita_salon/controller/login_controller.dart';
import '../model/register_request.dart';
import '../services/api_service.dart';

class RegisterController {
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobileNo = '';
  String state = '';
  String city = '';
  String pincode = '';
  String password = '';
  String confirmPassword = '';

  // Location data
  double? lat;
  double? lng;
  String locationDisplay = ''; // For displaying address on UI

  bool isLoading = false;
  String? errorMessage;

  Function()? onStateChanged;
  final ApiService _apiService = ApiService();

  // Check if location is selected
  bool get hasLocation => lat != null && lng != null;

  // Set location from map picker with auto-fill for city, state, pincode
  void setLocationWithAddress({
    required double latitude,
    required double longitude,
    required String displayAddress,
    String? cityValue,
    String? stateValue,
    String? pincodeValue,
  }) {
    lat = latitude;
    lng = longitude;
    locationDisplay = displayAddress;

    // Auto-fill city, state, pincode if provided
    if (cityValue != null && cityValue.isNotEmpty) {
      city = cityValue;
    }
    if (stateValue != null && stateValue.isNotEmpty) {
      state = stateValue;
    }
    if (pincodeValue != null && pincodeValue.isNotEmpty) {
      pincode = pincodeValue;
    }

    onStateChanged?.call();
  }

  // -------- VALIDATIONS --------

  String? validateRequired(String? value, String field) {
    if (value == null || value.isEmpty) {
      return 'Enter $field';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter email';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Invalid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be 6+ chars';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != password) return 'Passwords do not match';
    return null;
  }

  // -------- API CALL --------

  Future<bool> register() async {
    // Validate location is selected
    if (!hasLocation) {
      errorMessage = 'Please select your location on the map';
      onStateChanged?.call();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    onStateChanged?.call();

    final request = RegisterRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobileNo: mobileNo,
      state: state,
      city: city,
      pincode: pincode,
      password: password,
      lat: lat!,
      lng: lng!,
    );

    try {
      final result = await _apiService.register(request);
      isLoading = false;
      onStateChanged?.call();
      return result;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
      onStateChanged?.call();
      return false;
    }
  }

  // Register and then immediately login
  Future<bool> registerAndLogin() async {
    final registerSuccess = await register();
    if (!registerSuccess) return false;

    // Start Login Process
    isLoading = true;
    onStateChanged?.call();

    try {
      final loginController = LoginController();
      loginController.setEmail(email);
      loginController.setPassword(password);

      final loginSuccess = await loginController.login();

      isLoading = false;
      if (!loginSuccess) {
        errorMessage =
            loginController.errorMessage ??
            "Registration successful but login failed.";
      }
      onStateChanged?.call();
      return loginSuccess;
    } catch (e) {
      errorMessage = "Registration successful but login failed: $e";
      isLoading = false;
      onStateChanged?.call();
      return false;
    }
  }
}
