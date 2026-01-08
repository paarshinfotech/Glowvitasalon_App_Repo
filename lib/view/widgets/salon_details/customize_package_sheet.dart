import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/model/wedding_package.dart';
import 'package:glow_vita_salon/model/service.dart';

class CustomizePackageSheet extends StatelessWidget {
  final WeddingPackage package;

  const CustomizePackageSheet({super.key, required this.package});

  static void show(
    BuildContext context,
    SalonDetailsController controller,
    WeddingPackage package,
  ) {
    // Ensure package services are initialized in controller
    // Only initialize if package is NOT already selected
    if (!controller.selectedPackages.contains(package)) {
      // Package not selected yet - initialize with default package services
      controller.setPackageServices(
        package,
        package.services.map((ps) => ps.service).toList(),
      );
    }
    // If package IS selected, keep existing services (preserves user's changes)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeNotifierProvider.value(
        value: controller,
        child: CustomizePackageSheet(package: package),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Consumer<SalonDetailsController>(
                builder: (context, ctrl, child) {
                  // Get ALL services that are selected for this package
                  // This includes both package services AND salon services

                  // First, get package services
                  final packageServicesList = package.services
                      .map((ps) => ps.service)
                      .toList();

                  // Then, get salon services that are selected
                  final selectedSalonServices = ctrl.services
                      .where(
                        (s) => ctrl.isServiceSelectedForPackage(package, s),
                      )
                      .toList();

                  // Build display services list
                  final displayServicesList = <Service>[];
                  final addedKeys = <String>{};

                  // Add selected salon services
                  for (final service in selectedSalonServices) {
                    final key = '${service.name}_${service.category}';
                    displayServicesList.add(service);
                    addedKeys.add(key);
                  }

                  // Check package services - only add if selected
                  for (final ps in package.services) {
                    final service = ps.service;
                    final key = '${service.name}_${service.category}';

                    // Skip if already added (from salon services)
                    if (addedKeys.contains(key)) continue;

                    // Only add if selected in controller
                    if (ctrl.isServiceSelectedForPackage(package, service)) {
                      displayServicesList.add(service);
                      addedKeys.add(key);
                    }
                  }

                  // If empty, initialize with package services (first time)
                  final displayServices = displayServicesList.isEmpty
                      ? packageServicesList
                      : displayServicesList;

                  final currentPrice = displayServices.fold<double>(
                    0,
                    (sum, service) => sum + service.price,
                  );

                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      // Header Image & Info
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    package.imageUrl ??
                                        'https://via.placeholder.com/400',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          package.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '₹${currentPrice.toStringAsFixed(0)}/-',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildHeaderChip(
                                        Icons.list,
                                        '${displayServices.length} Services',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildHeaderChip(
                                        Icons.access_time,
                                        package.duration,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildHeaderChip(
                                        Icons.people,
                                        '2 Staff',
                                      ), // Placeholder/Static for now as per design
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: CircleAvatar(
                                backgroundColor: Colors.black26,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            package.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // Included Services
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.list,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Included Services',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A2C3F),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${displayServices.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _showEditServicesDialog(
                                  context,
                                  ctrl,
                                  package,
                                ),
                                icon: const Icon(
                                  Icons.edit_square,
                                  color: Color(0xFF4A2C3F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),

                      // Simple Service List - All Services (Package + Additional)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final service = displayServices[index];
                            final isPackageService = package.services.any(
                              (ps) => ps.service == service,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  // Bullet point
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4A2C3F),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Service Name and Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                service.name,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (!isPackageService)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[50],
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Colors.green,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Added',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${service.duration} • ₹${service.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }, childCount: displayServices.length),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // Expert Staff Members
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[50],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.people,
                                      color: Colors.purple,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Expert Staff Members',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 130,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: ctrl.specialists.length,
                                  itemBuilder: (context, index) {
                                    final specialist = ctrl.specialists[index];
                                    return Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF4A2C3F),
                                                width: 2,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 32,
                                              backgroundImage: NetworkImage(
                                                specialist.imageUrl,
                                              ),
                                              onBackgroundImageError:
                                                  (_, __) {},
                                              child: specialist.imageUrl.isEmpty
                                                  ? const Icon(Icons.person)
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            specialist.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Expert',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),

                      // Pricing Card with Service Breakdown
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text('💰', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Package Pricing',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Service Breakdown
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Services (${displayServices.length})',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Price',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      ...displayServices.map((service) {
                                        final isPackageService = package
                                            .services
                                            .any((ps) => ps.service == service);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 4,
                                                      height: 4,
                                                      decoration: BoxDecoration(
                                                        color: isPackageService
                                                            ? const Color(
                                                                0xFF4A2C3F,
                                                              )
                                                            : Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        service.name,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[800],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '₹${service.price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Total Price
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.shade50,
                                        Colors.pink.shade50,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Package Price',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'All services included',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₹${currentPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 30)),
                    ],
                  );
                },
              ),
            ),
            // Bottom Buttons
            Consumer<SalonDetailsController>(
              builder: (context, controller, child) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!controller.selectedPackages.contains(
                              package,
                            )) {
                              controller.togglePackage(package);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFE91E63,
                            ), // Pinkish Red
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditServicesDialog(
    BuildContext context,
    SalonDetailsController controller,
    WeddingPackage package,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add Services',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${package.services.length} services included • ${controller.services.length} available',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Builder(
                  builder: (context) {
                    // Get package services
                    final packageServices = package.services
                        .map((ps) => ps.service)
                        .toList();

                    // Merge package services with salon services
                    // Use a Set to avoid duplicates, then convert to List
                    final allAvailableServices = {
                      ...packageServices,
                      ...controller.services,
                    }.toList();

                    // Build initial selection from what's actually selected in controller
                    // Do NOT automatically select all package services
                    final initialSelected = <Service>{};

                    // Check package services - only add if selected in controller
                    for (final ps in package.services) {
                      if (controller.isServiceSelectedForPackage(
                        package,
                        ps.service,
                      )) {
                        initialSelected.add(ps.service);
                      }
                    }

                    // Add salon services that are selected in controller
                    for (final service in controller.services) {
                      if (controller.isServiceSelectedForPackage(
                        package,
                        service,
                      )) {
                        initialSelected.add(service);
                      }
                    }

                    return _EditServicesList(
                      package: package,
                      allServices: allAvailableServices,
                      initialSelected: initialSelected,
                      onSave: (newSelection) {
                        // Debug: Print what we're saving
                        print('Saving ${newSelection.length} services:');
                        for (final service in newSelection) {
                          print('  - ${service.name}');
                        }

                        controller.setPackageServices(package, newSelection);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditServicesList extends StatefulWidget {
  final WeddingPackage package;
  final List<Service> allServices;
  final Set<Service> initialSelected;
  final Function(List<Service>) onSave;

  const _EditServicesList({
    required this.package,
    required this.allServices,
    required this.initialSelected,
    required this.onSave,
  });

  @override
  State<_EditServicesList> createState() => _EditServicesListState();
}

class _EditServicesListState extends State<_EditServicesList> {
  late Set<Service> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected); // Create a copy
  }

  @override
  Widget build(BuildContext context) {
    // Get list of original package services for visual indication
    final packageServices = widget.package.services
        .map((ps) => ps.service)
        .toSet();

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widget.allServices.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final service = widget.allServices[index];
              final isSelected = _selected.contains(service);
              final isPackageService = packageServices.contains(service);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      print('Removing: ${service.name}');
                      _selected.remove(service);
                    } else {
                      print('Adding: ${service.name}');
                      _selected.add(service);
                    }
                    print('Total selected: ${_selected.length}');
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A2C3F)
                          : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            service.imageUrl ??
                                'https://via.placeholder.com/60',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.spa,
                                    color: Colors.grey[400],
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
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.duration} • ₹${service.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Show package badge if it's a package service
                        if (isPackageService)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A2C3F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF4A2C3F),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Package',
                              style: TextStyle(
                                color: Color(0xFF4A2C3F),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Show selection icon
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4A2C3F),
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey[400],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              print('_selected contains ${_selected.length} services:');
              for (final service in _selected) {
                print('  - ${service.name} (${service.hashCode})');
              }
              widget.onSave(_selected.toList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A2C3F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Configuration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
