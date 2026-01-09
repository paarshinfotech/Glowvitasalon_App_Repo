import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/model/service.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/customize_package_sheet.dart';
import 'package:glow_vita_salon/widget/wedding_package_card.dart';

class WeddingPackageList extends StatelessWidget {
  final SalonDetailsController controller;

  const WeddingPackageList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final package = controller.allWeddingPackages[index];
        final isSelected = controller.selectedPackages.contains(package);

        // Calculate price dynamically if this package is selected
        double displayPrice = package.price;
        if (isSelected) {
          // Build list of all selected services (package + salon)
          final selectedServices = <Service>[];

          // Check package services
          for (final ps in package.services) {
            if (controller.isServiceSelectedForPackage(package, ps.service)) {
              selectedServices.add(ps.service);
            }
          }

          // Check salon services (avoid duplicates)
          for (final service in controller.services) {
            if (controller.isServiceSelectedForPackage(package, service)) {
              final isDuplicate = selectedServices.any(
                (s) => s.name == service.name && s.category == service.category,
              );
              if (!isDuplicate) {
                selectedServices.add(service);
              }
            }
          }

          // Calculate total price
          if (selectedServices.isNotEmpty) {
            displayPrice = selectedServices.fold<double>(
              0,
              (sum, s) => sum + s.price,
            );
          }
        }

        return WeddingPackageCard(
          package: package,
          isSelected: isSelected,
          displayPrice: displayPrice,
          onViewTap: () =>
              CustomizePackageSheet.show(context, controller, package),
          onSelectTap: () => controller.togglePackage(package),
        );
      }, childCount: controller.allWeddingPackages.length),
    );
  }
}