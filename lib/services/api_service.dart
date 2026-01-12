import 'dart:convert';
import 'package:glow_vita_salon/model/product_detail.dart';

import '../model/product.dart';
import '../model/register_request.dart';
import '../model/vendor.dart';
import '../model/offer.dart';
import '../model/category.dart';
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
      body: jsonEncode({"email": email, "password": password}),
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RAW RESPONSE: ${response.body}");

    return jsonDecode(response.body);
  }

  Future<bool> register(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/api/auth/signup');

    try {
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if there is a success flag in the body as well, sometimes APIs return 200 with success: false
        if (data is Map &&
            data.containsKey('success') &&
            data['success'] == false) {
          throw Exception(data['message'] ?? 'Registration failed');
        }
        return true;
      } else {
        // extract error message
        String msg = 'Registration failed';
        if (data is Map) {
          msg = data['message'] ?? data['error'] ?? msg;
        }
        throw Exception(msg);
      }
    } catch (e) {
      print('Register Error: $e');
      rethrow; // Pass it to the controller
    }
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
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId'),
    );

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

  static Future<Vendor> getVendorDetails(String vendorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/vendors/$vendorId'),
    );

    print('Vendor API Response Status: ${response.statusCode}');
    print('Vendor API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Based on user sample: { "vendor": { ... } }
      if (jsonData is Map && jsonData.containsKey('vendor')) {
        return Vendor.fromJson(jsonData['vendor'] as Map<String, dynamic>);
      } else if (jsonData is Map && jsonData.containsKey('data')) {
        // Some APIs wrap in data
        final data = jsonData['data'];
        if (data is Map && data.containsKey('vendor')) {
          return Vendor.fromJson(data['vendor'] as Map<String, dynamic>);
        }
        if (data is Map) {
          return Vendor.fromJson(data as Map<String, dynamic>);
        }
      }

      // Fallback
      if (jsonData is Map) {
        return Vendor.fromJson(jsonData as Map<String, dynamic>);
      }

      throw Exception('Unexpected response format');
    } else {
      throw Exception('Failed to load vendor details');
    }
  }

  static Future<List<Offer>> getVendorOffers(String vendorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/offers?businessId=$vendorId'),
    );

    print('Offers API Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final List list = jsonData['data'];
        return list.map((e) => Offer.fromJson(e)).toList();
      }
      return [];
    } else {
      print('Failed to load offers: ${response.statusCode}');
      return []; // Return empty on error to avoid breaking UI
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/categories'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        List<dynamic> list;
        if (jsonData is List) {
          list = jsonData;
        } else if (jsonData is Map && jsonData.containsKey('categories')) {
          list = jsonData['categories'];
        } else if (jsonData is Map && jsonData.containsKey('data')) {
          list = jsonData['data'];
        } else {
          // Fallback or empty if not found
          if (jsonData is List) {
            list = jsonData;
          } else {
            return []; // Return empty or throw
          }
        }

        return list
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/profile');

    // Use a raw token for cookies (no "Bearer " prefix)
    String rawToken = token;
    if (token.startsWith('Bearer ')) {
      rawToken = token.substring(7);
    }

    // Ensure auth header has "Bearer " prefix
    final authHeader = token.startsWith('Bearer ') ? token : 'Bearer $token';

    print("DEBUG: Fetching Profile from $url");
    // print("DEBUG: Auth Header: $authHeader");
    // print("DEBUG: Cookie Header: token=$rawToken");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": authHeader,
        "Cookie": "token=$rawToken",
      },
    );

    print("PROFILE RESPONSE: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Failed to load profile. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }
}
