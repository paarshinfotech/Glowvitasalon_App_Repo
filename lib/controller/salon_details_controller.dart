import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/feedback.dart';
import 'package:glow_vita_salon/model/product.dart';
import 'package:glow_vita_salon/model/salon.dart';
import 'package:glow_vita_salon/model/service.dart';
import 'package:glow_vita_salon/model/specialist.dart';
import 'package:glow_vita_salon/model/wedding_package.dart';
import 'package:glow_vita_salon/services/api_service.dart';
import 'package:glow_vita_salon/controller/feedback_controller.dart';

enum PaymentMethod { payAtSalon, payOnline }
enum SalonDetailsState { services, staff, dateTime }
enum ServiceType { individual, wedding }
enum BookingPreference { visitSalon, homeService }

class SalonDetailsController extends ChangeNotifier {
  SalonDetailsController(this.salon) {
    _pageController = PageController();
    _imageUrls = [salon.imageUrl, salon.imageUrl, salon.imageUrl];
    _productsFuture = ApiService.getProducts();
  }

  final Salon salon;

  late final PageController _pageController;
  PageController get pageController => _pageController;

  int _currentPage = 0;
  int get currentPage => _currentPage;

  late final List<String> _imageUrls;
  List<String> get imageUrls => _imageUrls;

  String _selectedServiceCategory = 'Hair Cuts';
  String get selectedServiceCategory => _selectedServiceCategory;

  ServiceType _serviceType = ServiceType.individual;
  ServiceType get serviceType => _serviceType;

  BookingPreference _bookingPreference = BookingPreference.visitSalon;
  BookingPreference get bookingPreference => _bookingPreference;

  final List<Service> _selectedServices = [];
  List<Service> get selectedServices => _selectedServices;

  int _numberOfPeople = 1;
  int get numberOfPeople => _numberOfPeople;

  late Future<List<Product>> _productsFuture;
  Future<List<Product>> get productsFuture => _productsFuture;

  final FeedbackController _feedbackController = FeedbackController();
  FeedbackController get feedbackController => _feedbackController;

  SalonDetailsState _currentState = SalonDetailsState.services;
  SalonDetailsState get currentState => _currentState;


  final Map<String, Specialist> _selectedStaff = {};
  Map<String, Specialist> get selectedStaff => _selectedStaff;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  String? _selectedTime;
  String? get selectedTime => _selectedTime;

  PaymentMethod? _paymentMethod;
  PaymentMethod? get paymentMethod => _paymentMethod;

  final List<String> _serviceCategories = ['All Categories', 'Hair Cuts', 'Hair Treatment', 'Nail Art', 'Makeup'];
  List<String> get serviceCategories => _serviceCategories;

  final List<Service> _services = [
    Service(name: 'Straight Cut', duration: '10 mins - 15 mins', price: 250, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=1'),
    Service(name: 'Layer Cut', duration: '20 mins - 30 mins', price: 500, category: 'Hair Cuts', isDiscounted: true, discountLabel: 'Save 50%', imageUrl: 'https://i.pravatar.cc/150?img=2'),
    Service(name: 'Step Cut', duration: '25 mins - 35 mins', price: 400, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=3'),
    Service(name: 'Feather Cut', duration: '20 mins - 30 mins', price: 350, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=4'),
    Service(name: 'Kids Hair Cut (Boys/Girls)', duration: '10 mins - 20 mins', price: 150, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=5'),
    Service(name: 'Advanced Haircut (Any Style)', duration: '30 mins - 45 mins', price: 600, category: 'Hair Cuts', imageUrl: 'https://i.pravatar.cc/150?img=6'),
    Service(name: 'Hair Spa', duration: '45 mins', price: 800, category: 'Hair Treatment', imageUrl: 'https://i.pravatar.cc/150?img=7'),
    Service(name: 'Manicure', duration: '30 mins', price: 400, category: 'Nail Art', imageUrl: 'https://i.pravatar.cc/150?img=8'),
    Service(name: 'Pedicure', duration: '45 mins', price: 600, category: 'Nail Art', imageUrl: 'https://i.pravatar.cc/150?img=9'),
    Service(name: 'Bridal Makeup', duration: '2 hours', price: 5000, category: 'Makeup', imageUrl: 'https://i.pravatar.cc/150?img=10'),
  ];
  List<Service> get services => _services;

  final List<WeddingPackage> _weddingPackages = [];
  List<WeddingPackage> get weddingPackages => _weddingPackages;

  List<WeddingPackage> get allWeddingPackages {
    if (_weddingPackages.isEmpty) {
      // Initialize wedding packages if empty
      _weddingPackages.addAll([
        WeddingPackage(
          name: 'Silver Glow Bride',
          description: 'Perfect for intimate ceremonies. Includes essential bridal makeup and hair styling.',
          duration: '4 hours',
          price: 15000,
          imageUrl: 'https://i.pravatar.cc/150?img=10',
          services: [
             PackageService(service: _services.firstWhere((s) => s.name == 'Bridal Makeup'), isLocked: true),
             PackageService(service: _services.firstWhere((s) => s.name == 'Straight Cut'), isLocked: false), // Optional
             PackageService(service: _services.firstWhere((s) => s.name == 'Manicure'), isLocked: false), // Optional
          ],
        ),
        WeddingPackage(
          name: 'Gold Radiance Bride',
          description: 'Our most popular package. Comprehensive care for your big day.',
          duration: '6 hours',
          price: 25000,
          imageUrl: 'https://i.pravatar.cc/150?img=11',
          services: [
            PackageService(service: _services.firstWhere((s) => s.name == 'Bridal Makeup'), isLocked: true),
            PackageService(service: _services.firstWhere((s) => s.name == 'Advanced Haircut (Any Style)'), isLocked: true),
            PackageService(service: _services.firstWhere((s) => s.name == 'Hair Spa'), isLocked: false),
            PackageService(service: _services.firstWhere((s) => s.name == 'Pedicure'), isLocked: false),
          ],
        ),
        WeddingPackage(
          name: 'Platinum Luxury Bride',
          description: 'The ultimate indulgence. All-inclusive royal treatment.',
          duration: '8 hours',
          price: 35000,
          imageUrl: 'https://i.pravatar.cc/150?img=12',
          services: [
             PackageService(service: _services.firstWhere((s) => s.name == 'Bridal Makeup'), isLocked: true),
             PackageService(service: _services.firstWhere((s) => s.name == 'Advanced Haircut (Any Style)'), isLocked: true),
             PackageService(service: _services.firstWhere((s) => s.name == 'Hair Spa'), isLocked: false),
             PackageService(service: _services.firstWhere((s) => s.name == 'Manicure'), isLocked: false),
             PackageService(service: _services.firstWhere((s) => s.name == 'Pedicure'), isLocked: false),
          ],
        ),
      ]);
    }
    return _weddingPackages;
  }

  final List<Specialist> _specialists = [
    Specialist(name: 'Rohit Roy', imageUrl: 'https://i.pravatar.cc/150?img=12'),
    Specialist(name: 'Dnyanada Deny', imageUrl: 'https://i.pravatar.cc/150?img=33'),
    Specialist(name: 'Jolie Torp', imageUrl: 'https://i.pravatar.cc/150?img=32'),
    Specialist(name: 'Rocky Roy', imageUrl: 'https://i.pravatar.cc/150?img=60'),
  ];
  List<Specialist> get specialists => _specialists;


  final List<String> _morningSlots = ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM'];
  List<String> get morningSlots => _morningSlots;

  final List<String> _afternoonSlots = ['12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM'];
  List<String> get afternoonSlots => _afternoonSlots;

  final List<String> _eveningSlots = ['04:00 PM', '04:30 PM', '05:00 PM'];
  List<String> get eveningSlots => _eveningSlots;

  WeddingPackage? _selectedPackage;
  WeddingPackage? get selectedPackage => _selectedPackage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void selectServiceCategory(String category) {
    _selectedServiceCategory = category;
    notifyListeners();
  }

  void setServiceType(ServiceType type) {
    _serviceType = type;
    _selectedServices.clear();
    _selectedPackage = null;
    if (type == ServiceType.wedding) {
      _selectedServiceCategory = 'Makeup';
    } else {
      _selectedServiceCategory = 'All Categories';
    }
    notifyListeners();
  }

  void selectPackage(WeddingPackage package) {
    if (_selectedPackage == package) {
      // _selectedPackage = null;
      // _selectedServices.clear();
    } else {
      _selectedPackage = package;
      _selectedServices.clear();
      // Add all services from the package initially
      _selectedServices.addAll(package.services.map((ps) => ps.service));
    }
    notifyListeners();
  }

  void togglePackageService(PackageService packageService) {
    if (packageService.isLocked) return;

    final service = packageService.service;
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }


  void setBookingPreference(BookingPreference preference) {
    _bookingPreference = preference;
    notifyListeners();
  }

  void setNumberOfPeople(int numberOfPeople) {
    _numberOfPeople = numberOfPeople;
    notifyListeners();
  }

  void updateWeddingPackage(List<Service> services, int numberOfPeople) {
    _selectedServices.clear();
    _selectedServices.addAll(services);
    _numberOfPeople = numberOfPeople;
    notifyListeners();
  }

  void toggleService(Service service) {
    // Only for individual
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  void proceedToStaffSelection() {
    if (_selectedServices.isNotEmpty) {
      _currentState = SalonDetailsState.staff;
      notifyListeners();
    }
  }

  void proceedToDateSelectionFromPackage() {
     if (_selectedPackage != null && _selectedServices.isNotEmpty) {
      _currentState = SalonDetailsState.dateTime;
      notifyListeners();
     }
  }

  void backToServiceSelection() {
    _currentState = SalonDetailsState.services;
    notifyListeners();
  }

  void selectStaff(Specialist specialist) {
    if (_selectedStaff.containsValue(specialist)) {
      _selectedStaff.clear();
    } else {
      _selectedStaff.clear();
      for (var service in _selectedServices) {
        _selectedStaff[service.name] = specialist;
      }
    }
    notifyListeners();
  }

  void proceedToDateTimeSelection() {
    if (_selectedStaff.isNotEmpty) {
      _currentState = SalonDetailsState.dateTime;
      notifyListeners();
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void selectPaymentMethod(PaymentMethod? method) {
    _paymentMethod = method;
    notifyListeners();
  }

  double get totalAmount {
    // If wedding package, total = sum of selected services * number of people
    // The base price of package is just a guidance, we calculate real time based on user selection
    final subtotal = _selectedServices.fold<double>(0, (sum, service) => sum + service.price);
    
    if (_serviceType == ServiceType.wedding) {
       return (subtotal * _numberOfPeople); 
    }

    const platformFee = 20.0;
    const gst = 2.50;
    return subtotal + platformFee + gst;
  }
  
  double get subtotal {
      return _selectedServices.fold<double>(0, (sum, service) => sum + service.price);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Service> get filteredServices {
    if (_serviceType == ServiceType.wedding) {
      return _services.where((s) => s.category == 'Makeup').toList();
    } else {
      if (_selectedServiceCategory == 'All Categories') {
        return _services.where((s) => s.category != 'Makeup').toList();
      }
      return _services.where((s) => s.category == _selectedServiceCategory).toList();
    }
  }

  bool isStaffSelected(Specialist specialist) {
    return _selectedStaff.containsValue(specialist);
  }

  void handleBackButton() {
    if (_selectedPackage != null && _currentState == SalonDetailsState.dateTime) {
         // Stay in package customization (services state) but keep the package selected
         _currentState = SalonDetailsState.services;
         notifyListeners();
         return;
    }

    if (_currentState == SalonDetailsState.dateTime) {
      _currentState = SalonDetailsState.staff;
    } else if (_currentState == SalonDetailsState.staff) {
      _currentState = SalonDetailsState.services;
    }
    notifyListeners();
  }

  void reset() {
    _currentState = SalonDetailsState.services;
    _selectedServices.clear();
    _selectedStaff.clear();
    _selectedDate = DateTime.now();
    _selectedTime = null;
    _paymentMethod = null;
    _serviceType = ServiceType.individual;
    _selectedServiceCategory = 'All Categories';
    _bookingPreference = BookingPreference.visitSalon;
    _selectedPackage = null;
    _numberOfPeople = 1;
    notifyListeners();
  }
}
