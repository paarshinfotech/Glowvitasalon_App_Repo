import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;

  LatLng _selectedLocation = const LatLng(20.5937, 78.9629); // Default to India
  bool _isLoading = true;
  bool _isFetchingAddress = false;

  String _address = 'Move the map to select a location';
  String _city = '';
  String _state = '';
  String _pincode = '';

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _finishLoading(error: "Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _finishLoading(error: "Location permissions are denied.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _getAddressFromLatLng(_selectedLocation);
    } catch (e) {
      _finishLoading(error: "Failed to get current location.");
    } finally {
      _finishLoading();
    }
  }

  void _finishLoading({String? error}) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error != null) {
        _address = error;
      }
    });
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    if (!mounted) return;
    setState(() => _isFetchingAddress = true);

    try {
      final placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;

        setState(() {
          _city = place.locality ?? place.subAdministrativeArea ?? '';
          _state = place.administrativeArea ?? '';
          _pincode = place.postalCode ?? '';
          
          _address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((element) => element != null && element.isNotEmpty).join(', ');

          if (_address.isEmpty) {
            _address =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address =
          'Could not fetch address for this location.';
        });
      }
    } finally {
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }
  
  void _onCameraMove(CameraPosition position) {
    if (mounted) {
      setState(() {
        _selectedLocation = position.target;
      });
    }
  }

  void _onCameraIdle() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _getAddressFromLatLng(_selectedLocation);
    });
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    FocusScope.of(context).unfocus();

    try {
      final locations =
      await locationFromAddress(_searchController.text.trim());
      if (locations.isNotEmpty && mounted) {
        final loc = locations.first;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(loc.latitude, loc.longitude),
            15,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error searching location')));
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': _selectedLocation.latitude,
      'lng': _selectedLocation.longitude,
      'address': _address,
      'city': _city,
      'state': _state,
      'pincode': _pincode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFF4A2C3F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A2C3F)))
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_selectedLocation.latitude != 20.5937) {
                 controller.animateCamera(
                  CameraUpdate.newLatLngZoom(_selectedLocation, 15),
                );
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Search
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _searchLocation(),
                decoration: InputDecoration(
                  hintText: 'Search location',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF4A2C3F)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                ),
              ),
            ),
          ),

          // Pin
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Icon(Icons.location_pin,
                  size: 50, color: Color(0xFF4A2C3F)),
            ),
          ),

          // Address card
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _address,
                        style: const TextStyle(fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isFetchingAddress)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF4A2C3F)),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: ElevatedButton(
          onPressed: _isFetchingAddress ? null : _confirmLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A2C3F),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('CONFIRM LOCATION', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
