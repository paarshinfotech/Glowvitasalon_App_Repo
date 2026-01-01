import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/product_detail.dart';

class ReviewOrderController with ChangeNotifier {
  final ProductDetail product;
  Timer? _timer;
  // Initialize with a default duration
  Duration dealDuration = const Duration(hours: 0, minutes: 21, seconds: 42);
  int quantity = 1; // Default quantity

  ReviewOrderController({required this.product}) {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (dealDuration.inSeconds <= 0) {
        _timer?.cancel();
      } else {
        dealDuration = dealDuration - const Duration(seconds: 1);
        notifyListeners(); // Notify UI to rebuild and show updated time
      }
    });
  }

  // Logic to calculate discount percentage
  double get discountPercentage {
    if (product.price > 0 && product.price > product.salePrice) {
      return (product.price - product.salePrice) / product.price * 100;
    }
    return 0;
  }

  void incrementQuantity() {
    quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
