import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glow_vita_salon/controller/auth_controller.dart';
import 'package:glow_vita_salon/routes/app_routes.dart';
import 'package:glow_vita_salon/services/api_service.dart';
import 'package:glow_vita_salon/view/widgets/location_picker_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;

  String firstName = "";
  String lastName = "";
  String email = "";
  String city = "";
  String state = "";
  String pincode = "";
  String mobile = "";
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetchProfile();
  }

  Future<void> _checkAuthAndFetchProfile() async {
    final isLoggedIn = await AuthController.isLoggedIn();
    if (!isLoggedIn) {
      if (!mounted) return;
      // Navigate to Login if not logged in
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    // Check Token from standard storage
    String? token = await AuthController.getToken();

    // Check "Cookie" storage (as requested by user logic)
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('cookie');
    }

    if (token == null) {
      if (!mounted) return;
      print(
        "DEBUG: No token found in SharedPreferences or 'cookie' key. Redirecting to login.",
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    // Mask check for debugging
    print("DEBUG: Fetching profile with token: ${token.substring(0, 10)}...");

    try {
      final apiService = ApiService();
      final response = await apiService.getProfile(token);

      // Safe extraction of user object without forced casting
      dynamic userData = response;
      // response is guaranteed to be Map<String, dynamic> by ApiService
      if (response['user'] != null && response['user'] is Map) {
        userData = response['user'];
      } else if (response['data'] != null) {
        final data = response['data'];
        if (data is Map) {
          if (data['user'] != null && data['user'] is Map) {
            userData = data['user'];
          } else {
            userData = data;
          }
        }
      }

      // Ensure userData is a Map before accessing
      if (userData is! Map) {
        userData = {};
      }

      print("DEBUG: User Data Extraction: $userData");

      if (mounted) {
        setState(() {
          // Robustly handle fields that might be null or not strings
          String fullName =
              userData['name']?.toString() ??
              userData['firstName']?.toString() ??
              "User";

          if (userData['firstName'] != null) {
            firstName = userData['firstName'].toString();
            // Handle potentially null lastName
            lastName = userData['lastName']?.toString() ?? "";
          } else {
            if (fullName.contains(' ')) {
              var parts = fullName.split(' ');
              firstName = parts[0];
              lastName = parts.sublist(1).join(' ');
            } else {
              firstName = fullName;
              lastName = "";
            }
          }

          // Use .toString() to be safe if API returns numbers or weird types
          email = userData['email']?.toString() ?? "abc@gmail.com";

          if (email == "abc@gmail.com") {
            // Fallback triggered, let's look for other keys
            print(
              "DEBUG ALERT: Email not found in standard keys. Available keys: ${userData.keys}",
            );

            // Try to find ANY key that looks like email
            for (var k in userData.keys) {
              if (k.toString().toLowerCase().contains('email')) {
                email = userData[k].toString();
                print("DEBUG: Found alternative email key: $k -> $email");
                break;
              }
            }

            // If still fallback, SHOW DIALOG for USER to see
            if (email == "abc@gmail.com" && mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Debug: Email Missing"),
                    content: SingleChildScrollView(
                      child: Text("Raw Data:\n$userData"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              });
            }
          }

          mobile = userData['mobileNo']?.toString() ?? "";
          city = userData['city']?.toString() ?? "";
          state = userData['state']?.toString() ?? "";
          pincode = userData['pincode']?.toString() ?? "";
          // profileImageUrl = userData['avatar'];

          print("DEBUG: Set State -> Email: '$email', Mobile: '$mobile'");
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
      // ... error handling
      if (mounted) {
        setState(() {
          isLoading = false;
        }); // Ensure loading stops
      }
    }
  }

  Future<void> _logout() async {
    await AuthController.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2C3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // User Header with Edit Option
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: profileImageUrl != null
                            ? Colors.transparent
                            : const Color(0xFF4A2C3F),
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : null,
                        child: profileImageUrl == null
                            ? Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showEditOptions(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A2C3F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContactIcon(Icons.call),
                    const SizedBox(width: 16),
                    _buildContactIcon(Icons.email_outlined),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Account"),
                  _buildMenuItem(Icons.lock_outline, "Change Password"),
                  _buildMenuItem(Icons.local_shipping_outlined, "Your Orders"),
                  const Divider(height: 30, thickness: 1),
                  _buildSectionTitle("Offers & Rewards"),
                  _buildMenuItem(
                    Icons.local_offer_outlined,
                    "Offers & Details",
                  ),
                  _buildMenuItem(Icons.card_giftcard, "Refer & Earn"),
                  const Divider(height: 30, thickness: 1),
                  _buildSectionTitle("About & Support"),
                  _buildMenuItem(Icons.info_outline, "About App"),
                  _buildMenuItem(Icons.security, "Privacy Policy"),
                  _buildMenuItem(
                    Icons.description_outlined,
                    "Terms & Conditions",
                  ),
                  _buildMenuItem(Icons.currency_exchange, "Refund Policy"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4A2C3F)),
                title: const Text('Upload Image'),
                onTap: () {
                  Navigator.pop(context);
                  _showImageSourceOptions(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Color(0xFF4A2C3F)),
                title: const Text('Edit Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDetailsForm(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Color(0xFF4A2C3F),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Handle Camera
                          debugPrint("Camera selected");
                        },
                      ),
                      const Text('Camera'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.photo_library,
                          size: 40,
                          color: Color(0xFF4A2C3F),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          // Handle Gallery
                          debugPrint("Gallery selected");
                        },
                      ),
                      const Text('Gallery'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditDetailsForm(BuildContext context) {
    print("DEBUG: Opening Edit Form with Email: '$email'");
    final TextEditingController fNameController = TextEditingController(
      text: firstName,
    );
    final TextEditingController lNameController = TextEditingController(
      text: lastName,
    );
    final TextEditingController emailController = TextEditingController(
      text: email,
    );
    final TextEditingController mobileController = TextEditingController(
      text: mobile,
    );
    final TextEditingController cityController = TextEditingController(
      text: city,
    );
    final TextEditingController stateController = TextEditingController(
      text: state,
    );
    final TextEditingController pincodeController = TextEditingController(
      text: pincode,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField("First Name", fNameController),
                const SizedBox(height: 12),
                _buildTextField("Last Name", lNameController),
                const SizedBox(height: 12),
                _buildTextField(
                  "Email",
                  emailController
                    ..text = email.isEmpty ? "abc@gmail.com" : email,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                _buildTextField("Mobile", mobileController, readOnly: true),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Address Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationPickerScreen(),
                          ),
                        );

                        if (result != null && result is Map) {
                          cityController.text = result['city'] ?? "";
                          stateController.text = result['state'] ?? "";
                          pincodeController.text = result['pincode'] ?? "";
                        }
                      },
                      icon: const Icon(Icons.map, color: Color(0xFF4A2C3F)),
                      label: const Text(
                        "Pick from Map",
                        style: TextStyle(color: Color(0xFF4A2C3F)),
                      ),
                    ),
                  ],
                ),

                _buildTextField("City", cityController),
                const SizedBox(height: 12),
                _buildTextField("State", stateController),
                const SizedBox(height: 12),
                _buildTextField("Pincode", pincodeController, isNumber: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Update Local State for immediate feedback
                      // But we should really wait for API

                      // Call API
                      String? token = await AuthController.getToken();
                      if (token == null) {
                        final prefs = await SharedPreferences.getInstance();
                        token = prefs.getString('cookie');
                      }

                      if (token != null) {
                        final apiService = ApiService();
                        final Map<String, dynamic> updateData = {
                          "firstName": fNameController.text,
                          "lastName": lNameController.text,
                          "city": cityController.text,
                          "state": stateController.text,
                          "pincode": pincodeController.text,
                          // Mobile and Email are read-only
                        };

                        await apiService.updateProfile(token, updateData);
                        await AuthController.updateUser(
                          fNameController.text,
                          lNameController.text,
                        );

                        if (context.mounted) {
                          setState(() {
                            firstName = fNameController.text;
                            lastName = lNameController.text;
                            city = cityController.text;
                            state = stateController.text;
                            pincode = pincodeController.text;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile updated successfully!"),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error updating profile: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2C3F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(
        color: Colors.black,
      ), // Ensure text is black/visible
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildContactIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF4A2C3F),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
