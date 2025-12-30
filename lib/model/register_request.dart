class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String mobileNo;
  final String state;
  final String city;
  final String pincode;
  final String password;
  final double lat;
  final double lng;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.state,
    required this.city,
    required this.pincode,
    required this.password,
    required this.lat,
    required this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobileNo": mobileNo,
      "state": state,
      "city": city,
      "pincode": pincode,
      "password": password,
      "location": {
        "lat": lat,
        "lng": lng,
      },
    };
  }
}
