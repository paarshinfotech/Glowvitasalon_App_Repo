import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/review_order_controller.dart';
import 'package:glow_vita_salon/model/product_detail.dart';
import 'package:provider/provider.dart';

class ReviewOrderScreen extends StatefulWidget {
  final ProductDetail product;

  const ReviewOrderScreen({super.key, required this.product});

  @override
  _ReviewOrderScreenState createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  late ReviewOrderController _controller;
  bool _isPriceDetailsExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = ReviewOrderController(product: widget.product);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePriceDetails() {
    setState(() {
      _isPriceDetailsExpanded = !_isPriceDetailsExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiscountBanner(controller),
                  const SizedBox(height: 16),
                  _buildProductSummaryCard(controller, context),
                  _buildSoldByInfo(controller),
                  _buildDeliveryDetails(context),
                  _buildPriceDetails(controller),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar:
            Consumer<ReviewOrderController>(builder: (context, controller, __) {
          return _buildBottomBar(context, controller);
        }),
      ),
    );
  }

  void _showProductDetailsModal(
      BuildContext context, ReviewOrderController controller) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return ChangeNotifierProvider.value(
            value: controller,
            child: Consumer<ReviewOrderController>(
              builder: (context, controller, child) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              controller.product.images.first,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(controller.product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  'Fight Acne & Pimples, Brighten Skin,...',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('₹ ${controller.product.salePrice}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text('₹ ${controller.product.price}',
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey.shade500)),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${controller.discountPercentage.toStringAsFixed(0)}% off',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Qty',
                                        style: TextStyle(
                                            color: Colors.grey.shade700)),
                                    const SizedBox(width: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey[300]!)),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: controller.decrementQuantity,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 8.0),
                                              child: Text('-'),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Text('${controller.quantity}'),
                                          ),
                                          InkWell(
                                            onTap: controller.incrementQuantity,
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 8.0),
                                              child: Text('+'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 32),
                      const Text(
                          'This item has No Return - Only Exchange Policy',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.block, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text('Return NOT allowed for any issue'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.sync_alt, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Text('Exchange allowed for :'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('• Wrong/defective product'),
                            SizedBox(height: 4),
                            Text('• Damaged Product'),
                          ],
                        ),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Price',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                              '₹ ${controller.product.salePrice * controller.quantity}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A2B47),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Continue',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  void _showChangeAddressModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Change Delivery Address',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    onPressed: () => Navigator.of(modalContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pratiksha Aher',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Dream Castle Park, Avadh Utopia, Makhmalabad Road, Dream castle Signal, Nashik, Maharashtra 422008.',
                          style: TextStyle(
                              color: Colors.grey.shade700, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+91 9307319123',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text('EDIT',
                              style: TextStyle(
                                  color: Color(0xFF4A2B47),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Radio(
                    value: true,
                    groupValue: true,
                    onChanged: (bool? value) {},
                    activeColor: const Color(0xFF4A2B47),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Add New Address',
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(modalContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A2B47),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Deliver to this Address',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        String? paymentMethod = 'cash'; // default selection
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Select Payment Method',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      IconButton(
                        onPressed: () => Navigator.of(modalContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  RadioListTile<String>(
                    title: const Text('Cash on delivery'),
                    value: 'cash',
                    groupValue: paymentMethod,
                    onChanged: (String? value) {
                      setState(() {
                        paymentMethod = value;
                      });
                    },
                    activeColor: const Color(0xFF4A2B47),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Pay Online'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Handle Pay Online
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2B47),
                      ),
                      child: const Text('Pay', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(modalContext).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2B47),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Continue',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiscountBanner(ReviewOrderController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F5F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${controller.discountPercentage.toStringAsFixed(0)}% off',
            style: const TextStyle(
              color: Color(0xFF008069),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Text('on this order', style: TextStyle(fontSize: 14)),
          const Spacer(),
          _buildTimeBox(controller.dealDuration.inHours.remainder(24)),
          const SizedBox(width: 2),
          const Text('h',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2B47))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(':',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF4A2B47))),
          ),
          _buildTimeBox(controller.dealDuration.inMinutes.remainder(60)),
          const SizedBox(width: 2),
          const Text('m',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2B47))),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(':',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF4A2B47))),
          ),
          _buildTimeBox(controller.dealDuration.inSeconds.remainder(60)),
          const SizedBox(width: 2),
          const Text('s',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2B47))),
        ],
      ),
    );
  }

  Widget _buildProductSummaryCard(
      ReviewOrderController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              controller.product.fullImageUrl,
              width: 90,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.product.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '₹ ${controller.product.salePrice}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    if (controller.product.price > controller.product.salePrice)
                      Text(
                        '₹ ${controller.product.price}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (controller.discountPercentage > 0)
                      Text(
                        '${controller.discountPercentage.toStringAsFixed(0)}% off',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('No Returns-Only Exchange',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(
                    'Size : ${controller.product.size ?? 'Free Size'} • Qty : ${controller.quantity}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showProductDetailsModal(context, controller),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoldByInfo(ReviewOrderController controller) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade300),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Sold by : ',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  children: <TextSpan>[
                    TextSpan(
                      text: controller.product.vendorName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Free Delivery',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildDeliveryDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined,
                  color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Estimated Delivery by Friday, 09th Jan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pratiksha Aher • 9632157657',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dream Castle Park, Avadh Utopia, Makhmalabad Road, Dream castle Signal, Nashik 422008.',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => _showChangeAddressModal(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(ReviewOrderController controller) {
    final price = controller.product.price;
    final salePrice = controller.product.salePrice;
    final discount = price - salePrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _togglePriceDetails,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price Details',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Icon(_isPriceDetailsExpanded
                    ? Icons.expand_less
                    : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_isPriceDetailsExpanded)
          Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Product Price',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 14)),
                  Text('+ ₹ $price',
                      style: TextStyle(
                          color: Colors.grey.shade700, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Discounts',
                      style: TextStyle(
                          color: Color(0xFF008069),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text('- ₹ $discount',
                      style: const TextStyle(
                          color: Color(0xFF008069),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Order Total',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('₹ $salePrice',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }

  Widget _buildTimeBox(int time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF4A2B47),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        time.toString().padLeft(2, '0'),
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ReviewOrderController controller) {
    final price = controller.product.price;
    final salePrice = controller.product.salePrice;
    final discount = price - salePrice;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '₹ $salePrice',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F5F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '₹ $discount OFF',
                        style: const TextStyle(
                            color: Color(0xFF008069),
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: _togglePriceDetails,
                child: const Text(
                  'View Price Details',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A2B47),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showPaymentSelectionModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A2B47),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
