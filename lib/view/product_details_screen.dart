
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/product.dart';
import 'package:glow_vita_salon/model/product_detail.dart';
import 'package:glow_vita_salon/services/api_service.dart';
import 'package:glow_vita_salon/view/review_order_screen.dart';
import 'package:glow_vita_salon/widget/related_product_card.dart';

// Helper class to hold all page data
class _ProductPageData {
  final ProductDetail productDetail;
  final List<Product> relatedProducts;

  _ProductPageData({required this.productDetail, required this.relatedProducts});
}

class ProductDetailsScreen extends StatefulWidget {
  final Product product; // Passed from the product card

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  _ProductPageData? _pageData;
  final ApiService _apiService = ApiService();
  Timer? _timer;
  Duration _dealDuration = const Duration(hours: 1, minutes: 21, seconds: 42);
  bool _isAdditionalDetailsExpanded = true;
  bool _showAllRelated = false; // Manages the state of the 'You might also like' section

  @override
  void initState() {
    super.initState();
    _loadData();
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // This now fetches data and stores it in the state, making it accessible to the whole build method
    final data = await _fetchPageData(widget.product.id);
    if (mounted) {
      setState(() {
        _pageData = data;
      });
    }
  }

  Future<_ProductPageData> _fetchPageData(String productId) async {
    final productDetail = await _apiService.getProductDetails(productId);
    final allVendorProducts = await _apiService.getProductsByVendor(productDetail.vendorId);
    final relatedProducts = allVendorProducts.where((p) => p.id != productId).toList();
    return _ProductPageData(productDetail: productDetail, relatedProducts: relatedProducts);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      if (_dealDuration.inSeconds > 0) {
        setState(() {
          _dealDuration -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading scaffold while data is being fetched
    if (_pageData == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text("Loading details for ${widget.product.name}..."),
            ],
          ),
        ),
      );
    }

    // Once data is available, build the full UI
    final productDetail = _pageData!.productDetail;
    final relatedProducts = _pageData!.relatedProducts;
    final previewProducts = relatedProducts.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Image Slider and Main Product Details UI remains the same)
             SizedBox(
              height: 300,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: productDetail.images.isEmpty ? 1 : productDetail.images.length,
                itemBuilder: (context, index) {
                  if (productDetail.images.isEmpty) {
                     return _buildErrorImage();
                  }
                  return Image.network(
                    productDetail.images[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorImage();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Page Indicator for Slider
            if (productDetail.images.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(productDetail.images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 5.0,
                    width: _currentPage == index ? 25.0 : 10.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFF4A2B47)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 16),

            // Product Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productDetail.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            if (productDetail.productForm != null && productDetail.productForm!.isNotEmpty)
                              Text(
                                productDetail.productForm!,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                            color: Colors.grey[800],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined),
                            color: Colors.grey[800],
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹${productDetail.salePrice}',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (productDetail.price > productDetail.salePrice)
                        Text(
                          '₹${productDetail.price}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (productDetail.price > 0 && productDetail.price > productDetail.salePrice)
                        Text(
                          '${((productDetail.price - productDetail.salePrice) / productDetail.price * 100).toStringAsFixed(0)}% off',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Deal ends in ',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      _buildTimeBox(_dealDuration.inHours.remainder(24)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      _buildTimeBox(_dealDuration.inMinutes.remainder(60)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      _buildTimeBox(_dealDuration.inSeconds.remainder(60)),
                    ],
                  ),
                  const SizedBox(height: 12),
                   const Text(
                    'Free Delivery',
                    style: TextStyle(fontSize: 14, color: Color(0xFF008069), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF008069),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Text(
                              productDetail.rating,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.star,
                                color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${productDetail.reviewCount} reviews)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // --- Product Highlights ---
                  const Text(
                    'Product Highlights',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem('Net Quantity', productDetail.stock.toString()),
                  const SizedBox(height: 16),
                  if (productDetail.keyIngredients.isNotEmpty)
                    _buildDetailItem('Key Ingredients', productDetail.keyIngredients.join(', ')),
                  const SizedBox(height: 24),

                  // --- Additional Details ---
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isAdditionalDetailsExpanded = !_isAdditionalDetailsExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Additional Details',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Icon(_isAdditionalDetailsExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_isAdditionalDetailsExpanded)
                    Column(
                      children: [
                        if (productDetail.productForm?.isNotEmpty ?? false)
                          _buildAdditionalDetailRow('Type', productDetail.productForm!),
                        if (productDetail.brand?.isNotEmpty ?? false)
                          _buildAdditionalDetailRow('Brand', productDetail.brand!),
                        if (productDetail.size?.isNotEmpty ?? false)
                          _buildAdditionalDetailRow(
                              'Capacity', '${productDetail.size}${productDetail.sizeMetric ?? ''}'),
                        if (productDetail.forBodyPart?.isNotEmpty ?? false)
                          _buildAdditionalDetailRow('For Body Part', productDetail.forBodyPart!),
                         _buildAdditionalDetailRow('Vendor', productDetail.vendorName),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // You might also like Section
            if (relatedProducts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You might also like',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (relatedProducts.length > 2)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showAllRelated = !_showAllRelated;
                              });
                            },
                            child: Text(_showAllRelated ? 'View Less' : 'View All', style: const TextStyle(color: Colors.pinkAccent)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _showAllRelated
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: relatedProducts.length,
                            itemBuilder: (context, index) {
                              return RelatedProductCard(product: relatedProducts[index]);
                            },
                          ),
                        )
                      : SizedBox(
                          height: 290,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: previewProducts.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 170,
                                child: RelatedProductCard(product: previewProducts[index]),
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                          ),
                        ),
                ],
              ),

               // --- Customer Ratings & Reviews Section ---
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Ratings & Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildRatingSummaryBox(productDetail),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: _buildRatingBreakdown(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
       bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to cart'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                   onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewOrderScreen(product: productDetail),
                      ),
                    );
                  },
                  icon: const Icon(Icons.double_arrow),
                  label: const Text('Buy Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF4A2B47),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSummaryBox(ProductDetail productDetail) {
    // Placeholder for reviews count as it's not in the API model
    const reviewsCount = 1581;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF008069),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                productDetail.rating,
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, color: Colors.white, size: 28),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              Text(
                '${productDetail.reviewCount} ratings',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewsCount reviews',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRatingBreakdown() {
    // Placeholder data as it's not in the API
    final ratings = {
      'Very Good': 1909,
      'Good': 456,
      'Ok-Ok': 205,
      'Bad': 57,
      'Very Bad': 288,
    };
    final total = ratings.values.reduce((a, b) => a + b);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildRatingBar('Very Good', ratings['Very Good']!, total, const Color(0xFF008069)),
        _buildRatingBar('Good', ratings['Good']!, total, const Color(0xFF23A455)),
        _buildRatingBar('Ok-Ok', ratings['Ok-Ok']!, total, const Color(0xFFF1B500)),
        _buildRatingBar('Bad', ratings['Bad']!, total, const Color(0xFFF27400)),
        _buildRatingBar('Very Bad', ratings['Very Bad']!, total, const Color(0xFFD93025)),
      ],
    );
  }

  Widget _buildRatingBar(String label, int count, int total, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: count / total,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }


  Widget _buildTimeBox(int time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEECEB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        time.toString().padLeft(2, '0'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD95A5A)),
      ),
    );
  }
  
  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
     return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 50,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            "Image not available",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
