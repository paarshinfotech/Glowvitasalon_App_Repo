import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:glow_vita_salon/model/category.dart';
import '../model/offers.dart';
import '../model/product.dart';
import '../model/salon.dart';
import '../model/vendor.dart';
import 'package:glow_vita_salon/controller/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends ChangeNotifier {
  String location = "Fetching location..."; // Default or loading state
  bool isLoading = true;

  void updateLocation(String newLocation) {
    location = newLocation;
    notifyListeners();
  }

  final List<Offer> offers = ([
    {
      'title': '50% OFF',
      'description': 'Floral Nail Art Designs',
      'imageUrl': 'https://i.imgur.com/example_nail_art.png',
    },
    {
      'title': '40% OFF',
      'description': 'Hair Color Combo: Global + Cut',
      'imageUrl': 'https://i.imgur.com/example_hair_color.png',
    },
    {
      'title': '10% OFF',
      'description': 'Detan + Cleanup',
      'imageUrl': 'https://i.imgur.com/example_facial.png',
    },
  ]).map((data) => Offer.fromMap(data)).toList();

  List<Category> categories = [];

  List<Salon> allSalons = []; // Store all salons for filtering
  List<Salon> popularSalons = [];
  List<Salon> recommendedSalons = [];
  List<Product> products = [];

  HomeController() {
    _fetchData();
    _getUserLocation();
  }

  String userName = "Guest";

  Future<void> _fetchData() async {
    try {
      isLoading = true;
      // notifyListeners();

      print('Fetching data from API...');

      // --- 1. Load User Name (Fastest) ---
      final storedName = await AuthController.getUserName();
      if (storedName.isNotEmpty) {
        userName = storedName;
        notifyListeners();
      }

      // --- 2. Load Cached Data (Instant Content) ---
      await _loadCachedData();

      // If we found cached data, we can stop loading indicator so user sees content
      if (allSalons.isNotEmpty ||
          products.isNotEmpty ||
          categories.isNotEmpty) {
        isLoading = false;
        notifyListeners();
      }

      // --- 3. Background Profile Update ---
      final token = await AuthController.getToken();
      if (token != null) {
        try {
          final profile = await ApiService().getProfile(token);
          final user = profile['user'] ?? profile['data']?['user'] ?? {};
          final fName = user['firstName'] ?? user['name'] ?? '';
          final lName = user['lastName'] ?? '';
          final fullName = '$fName $lName'.trim();

          if (fullName.isNotEmpty && fullName != userName) {
            userName = fullName;
            notifyListeners();
          }
        } catch (e) {
          print("Error fetching profile name for home: $e");
        }
      }

      // --- 4. Fetch Fresh Data (Network) ---
      final results = await Future.wait([
        ApiService.getVendors(),
        ApiService.getProducts(),
        ApiService.getCategories(),
      ]);

      final vendors = results[0] as List<dynamic>;
      final productsData = results[1] as List<Product>;
      final categoriesData = results[2] as List<Category>;

      // --- 5. Cache the Fresh Data ---
      await _cacheData(vendors, productsData, categoriesData);

      // --- 6. Process & Update UI ---
      _processAndSetData(vendors, productsData, categoriesData);

      print('Data fetched & cached successfully');
    } catch (e) {
      print('Error fetching data: $e');
      if (allSalons.isEmpty) {
        // Only clear if we have nothing (no cache)
        popularSalons = [];
        recommendedSalons = [];
        products = [];
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper to process raw data into lists and filter logic
  void _processAndSetData(
    List<dynamic> vendors,
    List<Product> productsData,
    List<Category> categoriesData,
  ) {
    final salons = vendors.map((vendor) {
      if (vendor is Vendor) {
        return Salon.fromVendor(vendor);
      }
      return Salon.fromVendor(vendor as Vendor); // Dynamic cast if needed
    }).toList();

    categories = categoriesData;
    allSalons = salons;
    products = productsData.take(4).toList();

    if (salons.length >= 8) {
      popularSalons = salons.take(4).toList();
      recommendedSalons = salons.skip(4).take(4).toList();
    } else if (salons.length > 4) {
      popularSalons = salons.take(4).toList();
      recommendedSalons = salons.skip(4).toList();
    } else {
      popularSalons = salons;
      recommendedSalons = List.from(salons.reversed);
    }
  }

  // New Method: Load Cache
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vendorsJson = prefs.getString('cached_vendors');
      final productsJson = prefs.getString('cached_products');
      final categoriesJson = prefs.getString('cached_categories');

      if (vendorsJson != null &&
          productsJson != null &&
          categoriesJson != null) {
        final List<dynamic> vendorsList = jsonDecode(
          vendorsJson,
        ).map((e) => Vendor.fromJson(e)).toList();
        final List<Product> productsList = (jsonDecode(productsJson) as List)
            .map((e) => Product.fromJson(e))
            .toList();
        final List<Category> categoriesList =
            (jsonDecode(categoriesJson) as List)
                .map((e) => Category.fromJson(e))
                .toList();

        _processAndSetData(vendorsList, productsList, categoriesList);
        print("Loaded data from local cache.");
      }
    } catch (e) {
      print("Error loading cache: $e");
      // If cache fails, just ignore and wait for network
    }
  }

  // New Method: Save Cache
  Future<void> _cacheData(
    List<dynamic> vendors,
    List<Product> products,
    List<Category> categories,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert objects back to encodable maps (Assuming models have toJson)
      // Vendor model might need explicit toJson mapping if not standard

      final vendorsEncoded = jsonEncode(
        vendors.map((v) => (v as Vendor).toJson()).toList(),
      );
      final productsEncoded = jsonEncode(
        products.map((p) => p.toJson()).toList(),
      );
      final categoriesEncoded = jsonEncode(
        categories.map((c) => c.toJson()).toList(),
      );

      await prefs.setString('cached_vendors', vendorsEncoded);
      await prefs.setString('cached_products', productsEncoded);
      await prefs.setString('cached_categories', categoriesEncoded);
    } catch (e) {
      print("Error saving cache: $e");
    }
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        location = "Location disabled";
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          location = "Location denied";
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        location = "Location permanently denied";
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String newLocation = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        if (newLocation.isEmpty) {
          newLocation = "Unknown Location";
        }
        updateLocation(newLocation);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      location = "Failed to get location";
      notifyListeners();
    }
  }
}
