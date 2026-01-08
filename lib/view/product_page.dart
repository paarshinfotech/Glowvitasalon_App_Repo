import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glow_vita_salon/model/product.dart';
import 'package:glow_vita_salon/services/api_service.dart';
import 'package:glow_vita_salon/widget/product_card.dart';
import 'package:glow_vita_salon/view/home.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentIndex = 4;
  late Future<List<Product>> _productsFuture;
  // State variables for filtering
  String? _selectedCategory;
  String? _selectedSalon;
  RangeValues _selectedPriceRange = const RangeValues(0, 10000);
  double _maxPrice = 10000;
  bool _isPriceFilterActive = false;

  List<String> _categories = ['All'];
  List<String> _salons = ['All'];

  @override
  void initState() {
    super.initState();
    // Load products and dynamically populate categories, salons, and price range
    _productsFuture = _loadProductsAndCategories();
  }

  Future<List<Product>> _loadProductsAndCategories() async {
    try {
      final products = await ApiService.getProducts();
      if (mounted) {
        // Extract unique categories
        final uniqueCategories = products
            .map((p) => p.category)
            .where((c) => c.isNotEmpty)
            .toSet();

        // Extract unique vendor names (salons)
        final uniqueSalons = products
            .map((p) => p.vendorName)
            .where((v) => v.isNotEmpty)
            .toSet();

        // Calculate max price for the range slider
        double maxPrice = 0;
        if (products.isNotEmpty) {
          maxPrice = products
              .map((p) => p.price.toDouble())
              .reduce((a, b) => a > b ? a : b);
        }
        // Add a buffer to max price for better UX, or round it up
        maxPrice = (maxPrice / 100).ceil() * 100.0;
        if (maxPrice == 0) maxPrice = 1000; // Fallback

        // Update state
        setState(() {
          _categories = ['All', ...uniqueCategories];
          _salons = ['All', ...uniqueSalons];
          _maxPrice = maxPrice;
          // Only reset range if it hasn't been touched or matches defaults in a way that implies reset might be needed.
          // For now, let's initialize it to full range.
          if (!_isPriceFilterActive) {
            _selectedPriceRange = RangeValues(0, _maxPrice);
          }
        });
      }
      return products;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xFF4A2C3F),
        foregroundColor: Colors.white,
        title: const Text('Products'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A2C3F)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching products: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            final allProducts = snapshot.data!;
            final flashSaleProducts = allProducts
                .where((p) => p.isFlashSale)
                .toList();

            // Apply Filters
            final filteredProducts = allProducts.where((p) {
              // Category Filter
              final matchCategory =
                  _selectedCategory == null || _selectedCategory == 'All'
                  ? true
                  : p.category == _selectedCategory;

              // Salon Filter
              final matchSalon =
                  _selectedSalon == null || _selectedSalon == 'All'
                  ? true
                  : p.vendorName == _selectedSalon;

              // Price Filter
              final matchPrice = !_isPriceFilterActive
                  ? true
                  : (p.price >= _selectedPriceRange.start &&
                        p.price <= _selectedPriceRange.end);

              return matchCategory && matchSalon && matchPrice;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildSearchBar()),
                if (flashSaleProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildFlashSaleSection(flashSaleProducts),
                  ),
                ],
                SliverToBoxAdapter(child: _buildFilterSection()),
                _buildAllProductsGrid(filteredProducts),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search products by name',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashSaleSection(List<Product> flashSaleProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'FLA',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.flash_on,
                        size: 18,
                        color: Color(0xFF4A2C3F),
                      ),
                      Text(
                        'H SALE',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 2.5,
                    width: 100,
                    color: const Color(0xFF4A2C3F).withOpacity(0.8),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Ends in', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2C3F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '01',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      ':',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2C3F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '21',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Text(
                      ':',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2C3F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '42',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF4A2C3F),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: flashSaleProducts.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: ProductCard(product: flashSaleProducts[index]),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        children: [
          _buildFilterDropdown(
            _selectedCategory ?? 'Categories',
            () => _showCategoryModal(),
          ),
          const SizedBox(width: 8),
          _buildFilterDropdown(
            _selectedSalon ?? 'Salons',
            () => _showSalonModal(),
          ),
          const SizedBox(width: 8),
          _buildFilterDropdown(
            _isPriceFilterActive
                ? '₹${_selectedPriceRange.start.round()} - ₹${_selectedPriceRange.end.round()}'
                : 'Price Range',
            () => _showPriceRangeModal(),
          ),
        ],
      ),
    );
  }

  void _showPriceRangeModal() {
    // Temporary state variable for the modal interaction
    RangeValues tempRange = _selectedPriceRange;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Price Range',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${tempRange.start.round()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${tempRange.end.round()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: tempRange,
                    min: 0,
                    max: _maxPrice,
                    divisions: 100, // Optional: makes it discrete
                    activeColor: const Color(0xFF4A2C3F),
                    labels: RangeLabels(
                      '₹${tempRange.start.round()}',
                      '₹${tempRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        tempRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Clear Filter
                            setState(() {
                              _selectedPriceRange = RangeValues(0, _maxPrice);
                              _isPriceFilterActive = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(color: Color(0xFF4A2C3F)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply Filter
                            setState(() {
                              _selectedPriceRange = tempRange;
                              _isPriceFilterActive = true;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A2C3F),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSalonModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Salon',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            // Use the dynamic _salons list here
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: _salons
                    .map(
                      (salon) => ListTile(
                        title: Text(salon),
                        onTap: () {
                          setState(() {
                            _selectedSalon = salon;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCategoryModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Category',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            // Use the dynamic _categories list here
            ..._categories
                .map(
                  (category) => ListTile(
                    title: Text(category),
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }

  SliverPadding _buildAllProductsGrid(List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${products.length} Products Found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: products[index]),
              childCount: products.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(color: Color(0xFF4A2C3F)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(FontAwesomeIcons.houseChimney, "Home", 0),
          _navItem(FontAwesomeIcons.store, "Salons", 1),
          _navItem(FontAwesomeIcons.solidCalendar, "Bookings", 2),
          _navItem(FontAwesomeIcons.userDoctor, "doctor", 3),
          _navItem(FontAwesomeIcons.boxOpen, "products", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(initialIndex: 0),
            ),
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(initialIndex: 1),
            ),
            (route) => false,
          );
        } else if (index == 2) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(initialIndex: 2),
            ),
            (route) => false,
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF4A2C3F) : Colors.white,
            ),
          ),
          if (isSelected) ...[
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
