import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/review_order_controller.dart';
import 'package:glow_vita_salon/model/product_detail.dart';
import 'package:provider/provider.dart';

class ReviewOrderScreen extends StatelessWidget {
  final ProductDetail product;

  const ReviewOrderScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReviewOrderController(product: product),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review Your Order',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: const Color(0xFF4A2B47), // Dark purple
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Consumer<ReviewOrderController>(
          builder: (context, controller, child) {
            // The UI for the rest of the screen will go here
            return const Center(
              child: Text('Review order screen UI goes here'),
            );
          },
        ),
      ),
    );
  }
}
