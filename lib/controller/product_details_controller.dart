import 'package:flutter/material.dart';
import '../model/product.dart';

class ProductDetailsController extends ChangeNotifier {
  final Product product;

  ProductDetailsController(this.product);

  // Add any business logic for the product details page here
  // For example, handling quantity changes, adding to cart, etc.
}
