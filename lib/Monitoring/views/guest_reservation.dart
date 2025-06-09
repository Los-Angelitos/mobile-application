// views/guest_reservation_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/hotel.dart';
import '../services/hotel_service.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';

class GuestReservationView extends StatefulWidget {
  const GuestReservationView({Key? key}) : super(key: key);

  @override
  State<GuestReservationView> createState() => _GuestReservationViewState();
}

class _GuestReservationViewState extends State<GuestReservationView> {
  final HotelService _hotelService = HotelService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Hotel? hotel;
  bool isLoading = true;
  String? error;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadHotelData();
  }

  Future<void> _loadUserRole() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return;

      final parts = token.split('.');
      if (parts.length != 3) return;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      final role = payloadMap['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']?.toString();

      setState(() {
        userRole = role ?? 'ROLE_GUEST';
      });
    } catch (e) {
      print('Error loading user role: $e');
      setState(() {
        userRole = 'ROLE_GUEST';
      });
    }
  }

  Future<String?> _getHotelIdFromToken() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        print('No token found in storage');
        return null;
      }

      // Decodificar el JWT token para obtener el hotelId
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid token format');
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      print('Token payload: $payloadMap');

      // El hotelId está en la clave específica del schema XML
      final hotelId = payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality']?.toString();

      if (hotelId != null) {
        print('Hotel ID extracted from token: $hotelId');
        return hotelId;
      } else {
        print('Hotel ID not found in token payload');
        return null;
      }
    } catch (e) {
      print('Error extracting hotel ID from token: $e');
      return null;
    }
  }

  Future<void> _loadHotelData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final hotelId = await _getHotelIdFromToken();
      if (hotelId == null) {
        setState(() {
          error = 'No se pudo obtener el ID del hotel del token';
          isLoading = false;
        });
        return;
      }

      print('Loading hotel data for ID: $hotelId');
      final hotelData = await _hotelService.getHotelById(hotelId);

      if (hotelData != null) {
        print('Hotel data loaded successfully: ${hotelData.name}');
        setState(() {
          hotel = hotelData;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'No se pudo cargar la información del hotel';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading hotel data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      role: userRole,
      childScreen: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header personalizado (reemplaza el AppBar anterior)
          _buildCustomHeader(),
          // Contenido principal
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHotelData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
                : hotel == null
                ? const Center(child: Text('Hotel no encontrado'))
                : _buildHotelContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            hotel?.name ?? 'Hotel Details',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hotel Images Gallery
          _buildImageGallery(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Hotel Info and Price/Booking (side by side)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left container - Hotel Info
                      Expanded(
                        child: _buildHotelHeader(),
                      ),
                      const SizedBox(width: 12),
                      // Right container - Price and Booking
                      Expanded(
                        child: _buildPriceAndBookingSection(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Location
                _buildLocationInfo(),

                const SizedBox(height: 20),

                // 4. About This Place
                _buildAboutSection(),

                const SizedBox(height: 20),

                // 5. Amenities/Services
                _buildAmenitiesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Container(
      height: 200,
      child: PageView(
        children: [
          _buildImageCard('Hotel View 1'),
          _buildImageCard('Hotel View 2'),
          _buildImageCard('Hotel View 3'),
        ],
      ),
    );
  }

  Widget _buildImageCard(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hotel,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.hotel,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hotel!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${hotel!.address}, ${hotel!.city}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (hotel!.phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        hotel!.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndBookingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'S/ 320',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'per night',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showBookingDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Quote your next booking',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.red, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${hotel!.city}, ${hotel!.address} - Perú',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About This Place',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          hotel!.description.isNotEmpty
              ? hotel!.description
              : 'This vibrant all-inclusive hotel is nestled among palm trees on Punta Sal beach, 6 km from the town center and 89 km from Tumbes Airport. Simple rooms feature a terrace or balcony, flat-screen TV, and internet access (chargeable); some have a sitting area. Free amenities include water sports, evening entertainment, and beach equipment rentals, plus meals and drinks served at 3 restaurants and 5 bars.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = [
      {'icon': Icons.wifi, 'label': 'Paid Wi-Fi'},
      {'icon': Icons.restaurant, 'label': 'Breakfast included'},
      {'icon': Icons.local_parking, 'label': 'Free parking'},
      {'icon': Icons.pool, 'label': 'Outdoor pool'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...amenities.map((amenity) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                amenity['icon'] as IconData,
                size: 20,
                color: Colors.teal,
              ),
              const SizedBox(width: 12),
              Text(
                amenity['label'] as String,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservar ${hotel!.name}'),
          content: const Text('La funcionalidad de reserva se implementará aquí.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Manejar la reserva real
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }
}