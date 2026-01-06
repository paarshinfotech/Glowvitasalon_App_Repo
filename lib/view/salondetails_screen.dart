import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glow_vita_salon/controller/salon_details_controller.dart';
import 'package:glow_vita_salon/model/salon.dart';

// Widgets
import 'package:glow_vita_salon/view/widgets/salon_details/salon_image_carousel.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/salon_info_sections.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/service_selection_view.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/wedding_package_list.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/staff_date_time_view.dart';
import 'package:glow_vita_salon/view/widgets/salon_details/booking_bottom_sheet.dart';

class SalonDetailsScreen extends StatelessWidget {
  final Salon salon;
  final bool scrollToProducts;

  const SalonDetailsScreen({
    super.key,
    required this.salon,
    this.scrollToProducts = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SalonDetailsController(salon),
      child: Consumer<SalonDetailsController>(
        builder: (context, controller, child) {
          // Handle scroll to products
          if (scrollToProducts) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.productsKey.currentContext != null) {
                Scrollable.ensureVisible(
                  controller.productsKey.currentContext!,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              }
            });
          }

          return WillPopScope(
            onWillPop: () async {
              controller.handleBackButton();
              return false; // Prevent default pop
            },
            child: Scaffold(
              body: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SalonImageCarousel(
                      controller: controller,
                      salon: salon,
                    ),
                  ),
                  SliverToBoxAdapter(child: ActionsSection(salon: salon)),
                  SliverToBoxAdapter(child: OffersSection(salon: salon)),

                  // Service Selection Section
                  if (controller.currentState ==
                      SalonDetailsState.services) ...[
                    SliverToBoxAdapter(
                      child: ServiceSelectionHeader(controller: controller),
                    ),
                    if (controller.serviceType == ServiceType.wedding)
                      WeddingPackageList(controller: controller)
                    else
                      ServiceList(
                        controller: controller,
                        services: controller.filteredServices,
                      ),
                  ] else if (controller.currentState ==
                      SalonDetailsState.staff) ...[
                    SliverToBoxAdapter(
                      child: StaffSelectionList(controller: controller),
                    ),
                  ] else if (controller.currentState ==
                      SalonDetailsState.dateTime) ...[
                    SliverToBoxAdapter(
                      child: DateTimeSelectionList(controller: controller),
                    ),
                  ],

                  SliverToBoxAdapter(
                    child: SpecialistsSection(controller: controller),
                  ),

                  SliverToBoxAdapter(
                    key: controller.productsKey,
                    child: ProductSection(controller: controller),
                  ),

                  SliverToBoxAdapter(child: AboutSection(salon: salon)),

                  SliverToBoxAdapter(
                    child: FeedbackSection(controller: controller),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              bottomNavigationBar: SalonBottomNavBar(controller: controller),
            ),
          );
        },
      ),
    );
  }
}
