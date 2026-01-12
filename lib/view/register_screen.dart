import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/register_controller.dart';
import '../routes/app_routes.dart';
import 'map_picker_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final RegisterController _controller = RegisterController();

  // Text controllers for auto-fill fields
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller.onStateChanged = () {
      if (mounted) setState(() {});
    };
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.7,
            decoration: const BoxDecoration(
              color: Color(0xFF4A2C3F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            Image.asset('assets/images/GlowVita Final Logo.png', height: 70),
                            const SizedBox(height: 8),
                            const Text(
                              'Sign up to your account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildTextField(
                              hintText: 'First Name',
                              icon: Icons.person_outline,
                              onChanged: (v) => _controller.firstName = v,
                              validator: (v) => _controller.validateRequired(v, "First Name"),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              hintText: 'Enter your last name',
                              icon: Icons.person_outline,
                              onChanged: (v) => _controller.lastName = v,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              hintText: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (v) => _controller.email = v,
                              validator: _controller.validateEmail,
                            ),
                            const SizedBox(height: 12),
                             _buildTextField(
                              hintText: 'Enter your contact',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              onChanged: (v) => _controller.mobileNo = v,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              hintText: 'Select state',
                              icon: Icons.map_outlined,
                              controller: _stateController,
                              onChanged: (v) => _controller.state = v,
                            ),
                            const SizedBox(height: 12),
                             _buildTextField(
                              hintText: 'Select city',
                              icon: FontAwesomeIcons.city,
                              controller: _cityController,
                              onChanged: (v) => _controller.city = v,
                            ),
                             const SizedBox(height: 12),
                            _buildTextField(
                              hintText: 'Enter pin code',
                              icon: Icons.pin_drop_outlined,
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                              onChanged: (v) => _controller.pincode = v,
                            ),
                             const SizedBox(height: 12),
                            _buildTextField(
                              hintText: 'Enter Password',
                              icon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              onChanged: (v) => _controller.password = v,
                              validator: _controller.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              ),
                            ),
                             const SizedBox(height: 12),
                            _buildTextField(
                              hintText: 'Enter Confirm Password',
                              icon: Icons.lock_outline,
                              obscureText: !_isConfirmPasswordVisible,
                              onChanged: (v) => _controller.confirmPassword = v,
                              validator: _controller.validateConfirmPassword,
                               suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                              ),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: _pickLocation,
                              icon: const Icon(Icons.location_on, color: Color(0xFF4A2C3F)),
                              label: const Text(
                                'Pick Location from Map',
                                style: TextStyle(color: Color(0xFF4A2C3F), fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_controller.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _controller.errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ElevatedButton(
                              onPressed: _controller.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A2C3F),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _controller.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.black54)),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(color: Color(0xFF4A2C3F), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    IconData? icon,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await _controller.register();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  void _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && mounted) {
      _controller.setLocationWithAddress(
        latitude: result['lat'] as double,
        longitude: result['lng'] as double,
        displayAddress: result['address'] as String,
        cityValue: result['city'] as String?,
        stateValue: result['state'] as String?,
        pincodeValue: result['pincode'] as String?,
      );
      
      if (result['city'] != null && (result['city'] as String).isNotEmpty) {
        _cityController.text = result['city'] as String;
      }
      if (result['pincode'] != null && (result['pincode'] as String).isNotEmpty) {
        _pincodeController.text = result['pincode'] as String;
      }
      if (result['state'] != null && (result['state'] as String).isNotEmpty) {
        _stateController.text = result['state'] as String;
      } 
    }
  }
}
