import 'package:flutter/material.dart';
import 'dart:async';
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
  Timer? _autoSlideTimer;

  SalonDetailsController(this.salon) {
    _pageController = PageController();
    _scrollController = ScrollController();

    // Initialize with passed data
    _services = List.from(salon.services);

    if (salon.gallery.isNotEmpty) {
      _imageUrls = List.from(salon.gallery);
    } else {
      // Fallback to profile image if gallery is empty
      if (salon.imageUrl.isNotEmpty) {
        _imageUrls = [salon.imageUrl];
      } else {
        _imageUrls = [];
      }
    }

    _productsFuture = ApiService.getProducts(); // Ideally filter by vendor?

    // Fetch fresh details
    _fetchSalonDetails();
    _startAutoSlide();
  }

  final Salon salon;
  Salon? _fetchedSalon;
  Salon get currentSalon => _fetchedSalon ?? salon;

  late final PageController _pageController;
  PageController get pageController => _pageController;

  late final ScrollController _scrollController;
  ScrollController get scrollController => _scrollController;

  final GlobalKey productsKey = GlobalKey();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  late List<String> _imageUrls;
  List<String> get imageUrls => _imageUrls;

  String _selectedServiceCategory = 'All Categories'; // Default
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

  List<String> get serviceCategories {
    final categories = _services.map((s) => s.category).toSet().toList();
    categories.sort();
    return ['All Categories', ...categories];
  }

  late List<Service> _services;
  List<Service> get services => _services;

  Future<void> _fetchSalonDetails() async {
    print('Fetching details for ID: ${salon.id}');
    // If we don't have an ID, we can't fetch.
    if (salon.id.startsWith('static_') || salon.id.isEmpty) {
      print('Skipping fetch: Invalid ID');
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final vendor = await ApiService.getVendorDetails(salon.id);
      print(
        'Fetched vendor: ${vendor.businessName}, Gallery count: ${vendor.gallery.length}',
      );

      _fetchedSalon = Salon.fromVendor(vendor);

      _services = _fetchedSalon!.services;

      if (_fetchedSalon!.gallery.isNotEmpty) {
        print('Updating gallery images: ${_fetchedSalon!.gallery.length}');
        _imageUrls = List.from(_fetchedSalon!.gallery);

        // Reset page index
        _currentPage = 0;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      } else {
        print('Fetched gallery is empty');
      }

      // Reset category selection and clear services to prevent stale filtered list
      _selectedServiceCategory = 'All Categories';
      _individualServices.clear();

      notifyListeners();
    } catch (e) {
      print('Error fetching salon details: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  final List<WeddingPackage> _weddingPackages = [];
  List<WeddingPackage> get weddingPackages => _weddingPackages;

  List<WeddingPackage> get allWeddingPackages {
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

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && _imageUrls.length > 1) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _imageUrls.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Capabilities based on subCategories
  bool get hasHomeService => currentSalon.subCategories.contains('at-home');
  bool get hasSalonService => currentSalon.subCategories.contains('at-salon');

  // Assuming 'custom-location' implies wedding/external capability for packages
  bool get hasWeddingService =>
      currentSalon.subCategories.contains('custom-location');

  List<Service> get filteredServices {
    List<Service> baseList = _services;

    // Filter by Service Type (High level)
    if (_serviceType == ServiceType.wedding) {
      // Typically wedding services are specific.
      // If using packages, this list might not be used directly or used for "Add-ons".
      // If no packages are available but wedding mode is active, maybe show all wedding-available services?
      return baseList.where((s) => s.weddingServiceAvailable == true).toList();
    }

    // Filter by Booking Preference (Home vs Salon)
    if (_bookingPreference == BookingPreference.homeService) {
      baseList = baseList.where((s) => s.homeServiceAvailable == true).toList();
    } else {
      // Visit Salon: usually all services unless restricted?
      // Assuming all services are available at salon unless specified (which our model doesn't explicitly restrict).
    }

    // Filter by Category
    if (_selectedServiceCategory == 'All Categories') {
      // Exclude 'Makeup' from general list if needed?
      // The previous logic excluded 'Makeup'. I'll keep that behavior if desired,
      // but strictly speaking 'All Categories' should probably include all consistent with the mode.
      // Pre-existing logic: `s.category != 'Makeup'`.
      // I will respect typical "Salon" flow which separates Makeup/Packages.
      return baseList.where((s) => s.category != 'Makeup').toList();
    }

    return baseList
        .where((s) => s.category == _selectedServiceCategory)
        .toList();
  }

  bool isStaffSelected(Specialist specialist) {
    return _selectedStaff.containsValue(specialist);
  }

  bool handleBackButton() {
    if (selectedPackages.isNotEmpty &&
        _currentState == SalonDetailsState.dateTime) {
      _currentState = SalonDetailsState.services;
      notifyListeners();
      return true;
    }

    if (_currentState == SalonDetailsState.dateTime) {
      _currentState = SalonDetailsState.staff;
      notifyListeners();
      return true;
    } else if (_currentState == SalonDetailsState.staff) {
      _currentState = SalonDetailsState.services;
      notifyListeners();
      return true;
    }

    // Not handled internally, allow default back (pop)
    return false;
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
