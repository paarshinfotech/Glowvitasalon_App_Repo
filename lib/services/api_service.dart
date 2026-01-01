import 'dart:convert';
import 'package:glow_vita_salon/model/product_detail.dart';

import '../model/product.dart';
import '../model/register_request.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://v2winonline.com"; // your base URL

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW RESPONSE: ${response.body}");

    return jsonDecode(response.body);
  }
  Future<bool> register(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/api/auth/signup');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    print("REGISTER STATUS CODE: ${response.statusCode}");
    print("REGISTER RAW RESPONSE: ${response.body}");

    return response.statusCode == 200 || response.statusCode == 201;
  }
  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('https://v2winonline.com/api/products'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List list = jsonData['products']; // ✅ IMPORTANT

      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('API Error');
    }
  }

  Future<ProductDetail> getProductDetails(String productId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/products/$productId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return ProductDetail.fromJson(data);
      }
    }
    throw Exception('Failed to load product details');
  }
  
    Future<List<Product>> getProductsByVendor(String vendorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products?vendorId=$vendorId'),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List list = jsonData['products'];
      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load related products');
    }
  }
}