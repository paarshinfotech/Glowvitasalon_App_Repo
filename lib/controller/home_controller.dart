import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/category.dart';
import '../model/offers.dart';
import '../model/product.dart';
import '../model/salon.dart';
import 'package:http/http.dart' as http;

class HomeController {
  VoidCallback? onStateChanged;

  String location = "Mumbai Naka, Nashik 422003";
  bool isLoading = true;

  final List<Offer> offers = ([
    {'title': '50% OFF', 'description': 'Floral Nail Art Designs', 'imageUrl': 'https://i.imgur.com/example_nail_art.png'},
    {'title': '40% OFF', 'description': 'Hair Color Combo: Global + Cut', 'imageUrl': 'https://i.imgur.com/example_hair_color.png'},
    {'title': '10% OFF', 'description': 'Detan + Cleanup', 'imageUrl': 'https://i.imgur.com/example_facial.png'},
  ]).map((data) => Offer.fromMap(data)).toList();

  final List<Category> categories = [
    Category(id: '1', name: 'Nail Salon', iconUrl: 'https://i.imgur.com/example_nails.png'),
    Category(id: '2', name: 'Hair Salon', iconUrl: 'https://i.imgur.com/example_hair.png'),
    Category(id: '3', name: 'Spa', iconUrl: 'https://i.imgur.com/example_spa.png'),
    Category(id: '4', name: 'Makeup', iconUrl: 'https://i.imgur.com/example_makeup.png'),
    Category(id: '5', name: 'Skin Care', iconUrl: 'https://i.imgur.com/example_skincare.png'),
    Category(id: '6', name: 'Bridal', iconUrl: 'https://i.imgur.com/example_bridal.png'),
  ];

  final List<Salon> popularSalons = [
    Salon(
      name: 'Nidhi Hair & Nail Salon',
      salonType: 'Hair Salon',
      address: 'KBT Circle, Nashik',
      rating: 4.9,
      clientCount: 299,
      imageUrl: 'https://i.imgur.com/salon1.png',
      description: 'A full-service salon offering the latest trends in hair and beauty.',
      hasNewOffer: true,
    ),
    Salon(
      name: 'Vishakha Salon',
      salonType: 'Hair Salon',
      address: 'Dream Castle, Nashik',
      rating: 3.4,
      clientCount: 209,
      imageUrl: 'https://i.imgur.com/salon2.png',
      description: 'Specializing in vibrant color and modern styling.',
    ),
  ];

  final List<Salon> recommendedSalons = [
     Salon(
        name: 'Facebook Salon',
        salonType: 'Hair Salon',
        address: 'Humbard Road, Nashik',
        rating: 3.9,
        clientCount: 150,
        imageUrl: 'https://i.imgur.com/salon3.png',
        description: 'A cozy and friendly salon for all your beauty needs.',
    ),
    Salon(
        name: 'LuxeClear Salon',
        salonType: 'Hair Salon',
        address: 'Shivaji Nagar, Jail Rd, Nashik',
        rating: 3.4,
        clientCount: 109,
        imageUrl: 'https://i.imgur.com/salon4.png',
        description: 'High-end services for a luxurious experience.',
    ),
  ];

  List<Product> products = [];

  void init() {
    _loadProducts();
  }

  void _loadProducts() async {
    isLoading = true;
    onStateChanged?.call();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));



    isLoading = false;
    onStateChanged?.call();
  }




}