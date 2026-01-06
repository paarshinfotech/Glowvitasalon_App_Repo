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
    _scrollController = ScrollController();
    _imageUrls = [salon.imageUrl, salon.imageUrl, salon.imageUrl];
    _productsFuture = ApiService.getProducts();
  }

  final Salon salon;

  late final PageController _pageController;
  PageController get pageController => _pageController;

  late final ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;

  final GlobalKey productsKey = GlobalKey();

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

  final Map<WeddingPackage, List<Service>> _weddingPackageServices = {};
  List<Service> get selectedServices {
    if (_serviceType == ServiceType.wedding) {
      return _weddingPackageServices.values.expand((l) => l).toList();
    }
    return _individualServices;
  }

  final List<Service> _individualServices = [];

  int _numberOfPeople = 1;
  int get numberOfPeople => _numberOfPeople;

  late Future<List<Product>> _productsFuture;
  Future<List<Product>> get productsFuture => _productsFuture;

  final FeedbackController _feedbackController = FeedbackController();
  FeedbackController get feedbackController => _feedbackController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  // Address fields for wedding/home service
  String? _userAddress;
  String? get userAddress => _userAddress;

  String? _userCity;
  String? get userCity => _userCity;

  String? _userState;
  String? get userState => _userState;

  String? _userPincode;
  String? get userPincode => _userPincode;

  double? _userLat;
  double? get userLat => _userLat;

  double? _userLng;
  double? get userLng => _userLng;

  final List<String> _serviceCategories = [
    'All Categories',
    'Hair Cuts',
    'Hair Treatment',
    'Nail Art',
    'Makeup',
  ];
  List<String> get serviceCategories => _serviceCategories;

  final List<Service> _services = [
    Service(
      name: 'Straight Cut',
      duration: '10 mins - 15 mins',
      price: 250,
      category: 'Hair Cuts',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    Service(
      name: 'Layer Cut',
      duration: '20 mins - 30 mins',
      price: 500,
      category: 'Hair Cuts',
      isDiscounted: true,
      discountLabel: 'Save 50%',
      imageUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    Service(
      name: 'Step Cut',
      duration: '25 mins - 35 mins',
      price: 400,
      category: 'Hair Cuts',
      imageUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    Service(
      name: 'Feather Cut',
      duration: '20 mins - 30 mins',
      price: 350,
      category: 'Hair Cuts',
      imageUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    Service(
      name: 'Kids Hair Cut (Boys/Girls)',
      duration: '10 mins - 20 mins',
      price: 150,
      category: 'Hair Cuts',
      imageUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    Service(
      name: 'Advanced Haircut (Any Style)',
      duration: '30 mins - 45 mins',
      price: 600,
      category: 'Hair Cuts',
      imageUrl: 'https://i.pravatar.cc/150?img=6',
    ),
    Service(
      name: 'Hair Spa',
      duration: '45 mins',
      price: 800,
      category: 'Hair Treatment',
      imageUrl: 'https://i.pravatar.cc/150?img=7',
    ),
    Service(
      name: 'Manicure',
      duration: '30 mins',
      price: 400,
      category: 'Nail Art',
      imageUrl: 'https://i.pravatar.cc/150?img=8',
    ),
    Service(
      name: 'Pedicure',
      duration: '45 mins',
      price: 600,
      category: 'Nail Art',
      imageUrl: 'https://i.pravatar.cc/150?img=9',
    ),
    Service(
      name: 'Bridal Makeup',
      duration: '2 hours',
      price: 5000,
      category: 'Makeup',
      imageUrl: 'https://i.pravatar.cc/150?img=10',
    ),
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
          description:
              'Perfect for intimate ceremonies. Includes essential bridal makeup and hair styling.',
          duration: '4 hours',
          price: 5650,
          imageUrl: 'https://i.pravatar.cc/150?img=10',
          services: [
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Bridal Makeup'),
              isLocked: true,
            ),
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Straight Cut'),
              isLocked: false,
            ), // Optional
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Manicure'),
              isLocked: false,
            ), // Optional
          ],
        ),
        WeddingPackage(
          name: 'Gold Radiance Bride',
          description:
              'Our most popular package. Comprehensive care for your big day.',
          duration: '6 hours',
          price: 7000,
          imageUrl: 'https://i.pravatar.cc/150?img=11',
          services: [
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Bridal Makeup'),
              isLocked: true,
            ),
            PackageService(
              service: _services.firstWhere(
                (s) => s.name == 'Advanced Haircut (Any Style)',
              ),
              isLocked: true,
            ),
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Hair Spa'),
              isLocked: false,
            ),
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Pedicure'),
              isLocked: false,
            ),
          ],
        ),
        WeddingPackage(
          name: 'Platinum Luxury Bride',
          description:
              'The ultimate indulgence. All-inclusive royal treatment.',
          duration: '8 hours',
          price: 7400,
          imageUrl: 'https://i.pravatar.cc/150?img=12',
          services: [
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Bridal Makeup'),
              isLocked: true,
            ),
            PackageService(
              service: _services.firstWhere(
                (s) => s.name == 'Advanced Haircut (Any Style)',
              ),
              isLocked: true,
            ),
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Hair Spa'),
              isLocked: false,
            ),
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Manicure'),
              isLocked: false,
            ),
            PackageService(
              service: _services.firstWhere((s) => s.name == 'Pedicure'),
              isLocked: false,
            ),
          ],
        ),
      ]);
    }
    return _weddingPackages;
  }

  final List<Specialist> _specialists = [
    Specialist(name: 'Rohit Roy', imageUrl: 'https://i.pravatar.cc/150?img=12'),
    Specialist(
      name: 'Dnyanada Deny',
      imageUrl: 'https://i.pravatar.cc/150?img=33',
    ),
    Specialist(
      name: 'Jolie Torp',
      imageUrl: 'https://i.pravatar.cc/150?img=32',
    ),
    Specialist(name: 'Rocky Roy', imageUrl: 'https://i.pravatar.cc/150?img=60'),
  ];
  List<Specialist> get specialists => _specialists;

  final List<String> _morningSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
  ];
  List<String> get morningSlots => _morningSlots;

  final List<String> _afternoonSlots = [
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
  ];
  List<String> get afternoonSlots => _afternoonSlots;

  final List<String> _eveningSlots = ['04:00 PM', '04:30 PM', '05:00 PM'];
  List<String> get eveningSlots => _eveningSlots;

  List<WeddingPackage> get selectedPackages =>
      _weddingPackageServices.keys.toList();
  // Helper for single selection backwards compatibility if needed, using the last selected
  WeddingPackage? get selectedPackage =>
      selectedPackages.isNotEmpty ? selectedPackages.last : null;

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
    _individualServices.clear();
    _weddingPackageServices.clear();
    if (type == ServiceType.wedding) {
      _selectedServiceCategory = 'Makeup';
    } else {
      _selectedServiceCategory = 'All Categories';
    }
    notifyListeners();
  }

  void togglePackage(WeddingPackage package) {
    if (_weddingPackageServices.containsKey(package)) {
      _weddingPackageServices.remove(package);
    } else {
      // Add all services from the package initially
      _weddingPackageServices[package] = package.services
          .map((ps) => ps.service)
          .toList();
    }
    notifyListeners();
  }

  void selectPackage(WeddingPackage package) {
    // Deprecated single select, mapping to toggle for compatibility or exclusive select
    // But since user wants multiple, this should behave like toggle or add-if-not-present
    if (!_weddingPackageServices.containsKey(package)) {
      _weddingPackageServices[package] = package.services
          .map((ps) => ps.service)
          .toList();
      notifyListeners();
    }
  }

  bool isServiceSelectedForPackage(WeddingPackage package, Service service) {
    return _weddingPackageServices[package]?.contains(service) ?? false;
  }

  void togglePackageServiceForPackage(
    WeddingPackage package,
    PackageService packageService,
  ) {
    if (packageService.isLocked) return;

    final service = packageService.service;
    final servicesList = _weddingPackageServices[package];
    if (servicesList != null) {
      if (servicesList.contains(service)) {
        servicesList.remove(service);
      } else {
        servicesList.add(service);
      }
      notifyListeners();
    }
  }

  void togglePackageService(PackageService packageService) {
    // Legacy method for single selected package.
    // Try to find which package this service might belong to in the selection?
    // This is ambiguous if multiple packages are selected.
    // Ideally the UI should call togglePackageServiceForPackage.
    // Fallback: Use the last selected package?
    if (selectedPackage != null) {
      togglePackageServiceForPackage(selectedPackage!, packageService);
    }
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
    // Warning: This overrides everything for the single package flow.
    // For multiple packages, this method is ambiguous.
    // Assuming this updates the "current" or "last" package?
    // Let's deprecate usage or apply to the last selected.
    if (selectedPackage != null) {
      _weddingPackageServices[selectedPackage!] = List.from(services);
    }
    _numberOfPeople = numberOfPeople;
    notifyListeners();
  }

  void updateSelectedServices(List<Service> services) {
    // Updates services for individual service flow
    if (_serviceType == ServiceType.individual) {
      _individualServices.clear();
      _individualServices.addAll(services);
      notifyListeners();
    } else {
      // For package flow, this is ambiguous.
      // Used in EditServicesList likely.
      // We should pass the package to update.
    }
  }

  void updateSelectedServicesForPackage(
    WeddingPackage package,
    List<Service> services,
  ) {
    if (_weddingPackageServices.containsKey(package)) {
      _weddingPackageServices[package] = List.from(services);
      notifyListeners();
    }
  }

  void toggleService(Service service) {
    // Only for individual
    if (_individualServices.contains(service)) {
      _individualServices.remove(service);
    } else {
      _individualServices.add(service);
    }
    notifyListeners();
  }

  void proceedToStaffSelection() {
    if (selectedServices.isNotEmpty) {
      _currentState = SalonDetailsState.staff;
      notifyListeners();
    }
  }

  void proceedToDateSelectionFromPackage() {
    if (selectedPackages.isNotEmpty && selectedServices.isNotEmpty) {
      _currentState = SalonDetailsState.dateTime;
      notifyListeners();
    }
  }

  void backToServiceSelection() {
    _currentState = SalonDetailsState.services;
    notifyListeners();
  }

  void backToStaffSelection() {
    _currentState = SalonDetailsState.staff;
    notifyListeners();
  }

  void selectStaff(Specialist specialist) {
    if (_selectedStaff.containsValue(specialist)) {
      _selectedStaff.clear();
    } else {
      _selectedStaff.clear();
      // Assign staff to services?
      // For multiple packages, flattening everything?
      _selectedStaff['primary'] = specialist;
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
    final services = selectedServices;
    final subtotal = services.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );

    if (subtotal == 0) return 0.0;

    if (_serviceType == ServiceType.wedding) {
      return (subtotal * _numberOfPeople);
    }

    const platformFee = 20.0;
    const gst = 2.50;
    return subtotal + platformFee + gst;
  }

  double get subtotal {
    return selectedServices.fold<double>(
      0,
      (sum, service) => sum + service.price,
    );
  }

  void setUserAddress({
    required String address,
    required String city,
    required String state,
    required String pincode,
    required double lat,
    required double lng,
  }) {
    _userAddress = address;
    _userCity = city;
    _userState = state;
    _userPincode = pincode;
    _userLat = lat;
    _userLng = lng;
    notifyListeners();
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
      return _services
          .where((s) => s.category == _selectedServiceCategory)
          .toList();
    }
  }

  bool isStaffSelected(Specialist specialist) {
    return _selectedStaff.containsValue(specialist);
  }

  void handleBackButton() {
    if (selectedPackages.isNotEmpty &&
        _currentState == SalonDetailsState.dateTime) {
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
    _individualServices.clear();
    _weddingPackageServices.clear();
    _selectedStaff.clear();
    _selectedDate = DateTime.now();
    _selectedTime = null;
    _paymentMethod = null;
    _serviceType = ServiceType.individual;
    _selectedServiceCategory = 'All Categories';
    _bookingPreference = BookingPreference.visitSalon;
    _numberOfPeople = 1;
    notifyListeners();
  }
}
