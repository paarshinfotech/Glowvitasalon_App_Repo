import 'package:flutter/material.dart';
import '../model/salon.dart';
import '../view/appointments_screen.dart';
import '../view/home.dart';
import '../view/login_screen.dart';
import '../view/map_picker_screen.dart';
import '../view/notification_screen.dart';
import '../view/register_screen.dart';
import '../view/salon_list_screen.dart';
import '../view/salondetails_screen.dart';
import '../view/booking_screen.dart';
import '../view/product_details_screen.dart';
import '../model/product.dart';
import '../view/product_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/'; // Login is now the initial route
  static const String salonDetails = '/salon-details';
  static const String booking = '/booking';
  static const String productDetails = '/product-details';
  static const String register = '/register';
  static const String mappicker = '/mappicker';
  static const String products = '/products';
  static const String appointment = '/appointment';
  static const String notification = '/notification';
  static const String salonList = '/salonList';



  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const Home());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case mappicker:
          return MaterialPageRoute(builder: (_) => const MapPickerScreen());
      case products:
          return MaterialPageRoute(builder: (_) => const ProductPage());
      case appointment:
          return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case salonList:
          return MaterialPageRoute(builder: (_) => const SalonListScreen());
      case notification:
          return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case salonDetails:
        if (settings.arguments is Salon) {
          final salon = settings.arguments as Salon;
          return MaterialPageRoute(
              builder: (_) => SalonDetailsScreen(salon: salon));
        }
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final salon = args['salon'] as Salon?;
          if (salon != null) {
            final scrollToProducts = args['scrollToProducts'] as bool? ?? false;
            return MaterialPageRoute(
                builder: (_) => SalonDetailsScreen(
                    salon: salon, scrollToProducts: scrollToProducts));
          }
        }
        return _errorRoute();
      case booking:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              selectedServices: List<String>.from(args['selectedServices'] as List),
              selectedStaff: Map<String, String>.from(args['selectedStaff'] as Map),
              selectedDate: args['selectedDate'] as DateTime,
              selectedTime: args['selectedTime'] as String,
              totalAmount: args['totalAmount'] as double,
            ),
          );
        }
        return _errorRoute();
      case productDetails:
        if (settings.arguments is Product) {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product));
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      );
    });
  }
}
