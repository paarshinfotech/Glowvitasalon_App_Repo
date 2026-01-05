import 'dart:convert';
import 'package:glow_vita_salon/model/product_detail.dart';

import '../model/product.dart';
import '../model/register_request.dart';
import '../model/vendor.dart';
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

  static Future<List<Vendor>> getVendors() async {
    final response = await http.get(
      Uri.parse('https://v2winonline.com/api/vendors'),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Parsed JSON: $jsonData');
      
      // Handle different possible response formats
      List<dynamic> list;
      if (jsonData is List) {
        // If the response is directly an array (most likely case based on your sample)
        list = jsonData;
      } else if (jsonData is Map && jsonData.containsKey('vendors')) {
        // If the response has a 'vendors' key
        list = jsonData['vendors'];
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        // If the response has a 'data' key
        list = jsonData['data'];
      } else if (jsonData is Map && jsonData.containsKey('results')) {
        // If the response has a 'results' key
        list = jsonData['results'];
      } else {
        // Fallback: try to use the whole response as array
        // This will cause an error if it's not actually a list, which is good for debugging
        if (jsonData is List) {
          list = jsonData;
        } else {
          print('Unexpected response format: $jsonData');
          throw Exception('Unexpected response format from API');
        }
      }

      print('Vendor list length: ${list.length}');
      return list.map((e) => Vendor.fromJson(e)).toList();
    } else {
      print('API Error: ${response.statusCode}');
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}