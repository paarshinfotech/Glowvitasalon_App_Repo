import 'package:flutter/material.dart';
import '../model/wedding_package.dart';

class WeddingPackageCard extends StatelessWidget {
  final WeddingPackage package;
  final bool isSelected;
  final double displayPrice;
  final VoidCallback onViewTap;
  final VoidCallback onSelectTap;

  const WeddingPackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.displayPrice,
    required this.onViewTap,
    required this.onSelectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onViewTap,
        child: Container(
          height: 120, // Strict height constraint
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF4A2C3F)
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image Section - Left Side
              if (package.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: Image.network(
                    package.imageUrl!,
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),

              // Content Section - Right Side
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // Distribute vertically
                    children: [
                      // Header Row: Name + Check
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              package.name,
                              style: const TextStyle(
                                fontSize: 15, // Slightly smaller
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFF4A2C3F),
                                size: 18,
                              ),
                            ),
                        ],
                      ),

                      // Middle Row: Price & Duration
                      Row(
                        children: [
                          Text(
                            '₹${displayPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A2C3F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            package.duration,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Bottom Row: Compact Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 32, // Minimal button height
                              child: OutlinedButton(
                                onPressed: onViewTap,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  side: const BorderSide(
                                    color: Color(0xFF4A2C3F),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'View',
                                  style: TextStyle(
                                    color: Color(0xFF4A2C3F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: onSelectTap,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: isSelected
                                      ? Colors.grey.shade400
                                      : const Color(0xFF4A2C3F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  isSelected ? 'Selected' : 'Select',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
