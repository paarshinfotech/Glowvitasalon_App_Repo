class LoginRequest {
  final String name;
  final String email;
  final String password;
  final String phone;

  LoginRequest({required this.name, required this.email, required this.password, required this.phone});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
  };
}
