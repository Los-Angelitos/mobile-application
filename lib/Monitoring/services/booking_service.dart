// services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/booking.dart';
import '../../shared/infrastructure/services/base_service.dart';

class BookingService extends BaseService {

  // Método para obtener headers con autenticación
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'token');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('Using token for request: ${token.substring(0, 20)}...'); // Log parcial del token
    } else {
      print('No token found in storage');
    }

    return headers;
  }

  Future<List<Booking>> getBookingsByCustomer(String customerId) async {
    try {
      final headers = await _getAuthHeaders();
      print('Making request to: $baseUrl/booking/get-booking-by-customer-id?customerId=$customerId');

      final response = await https.get(
        Uri.parse('$baseUrl/booking/get-booking-by-customer-id?customerId=$customerId'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Manejar diferentes estructuras de respuesta
        List<dynamic> bookingsJson = [];

        if (data is List) {
          // Si la respuesta es directamente un array
          bookingsJson = data;
        } else if (data is Map && data['data'] != null) {
          // Si la respuesta tiene estructura { data: [...] }
          bookingsJson = data['data'];
        } else if (data is Map && data.containsKey('id')) {
          // Si la respuesta es un solo objeto
          bookingsJson = [data];
        }

        print('Processing ${bookingsJson.length} bookings');

        return bookingsJson.map((json) {
          try {
            return Booking.fromJson(json);
          } catch (e) {
            print('Error parsing booking: $e');
            print('Booking data: $json');
            // Crear un booking con valores por defecto para datos faltantes
            return _createBookingWithDefaults(json);
          }
        }).toList();

      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getBookingsByCustomer: $e');
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Método auxiliar para crear booking con valores por defecto
  Booking _createBookingWithDefaults(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      paymentCustomerId: json['paymentCustomerId']?.toString() ?? json['customerId']?.toString() ?? '',
      roomId: json['roomId']?.toString() ?? json['room_id']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: _parseDate(json['startDate']) ?? DateTime.now(),
      finalDate: _parseDate(json['finalDate']) ?? DateTime.now().add(const Duration(days: 1)),
      priceRoom: _parseDouble(json['priceRoom'] ?? json['price_room'] ?? json['price']) ?? 0.0,
      nightCount: _parseInt(json['nightCount'] ?? json['night_count']) ?? 1,
      amount: _parseDouble(json['amount']) ?? 0.0,
      state: json['state']?.toString()?.toLowerCase() ?? 'inactive',
      preferenceId: json['preferenceId']?.toString() ?? json['preference_id']?.toString(),
      hotelName: json['hotelName']?.toString() ?? json['hotel_name']?.toString() ?? 'Hotel',
      hotelLogo: json['hotelLogo']?.toString() ?? json['hotel_logo']?.toString(),
    );
  }

  // Métodos auxiliares para parsing seguro
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
      return null;
    } catch (e) {
      print('Error parsing date: $value');
      return null;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    try {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.parse(value);
      }
      return null;
    } catch (e) {
      print('Error parsing double: $value');
      return null;
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    try {
      if (value is int) {
        return value;
      }
      if (value is String) {
        return int.parse(value);
      }
      if (value is double) {
        return value.toInt();
      }
      return null;
    } catch (e) {
      print('Error parsing int: $value');
      return null;
    }
  }

  Future<bool> updateBooking(String bookingId, String state) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await https.put(
        Uri.parse('$baseUrl/booking/update-booking-state'),
        headers: headers,
        body: json.encode({
          'id': bookingId,
          'state': state,
        }),
      );

      if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Error in updateBooking: $e');
      throw Exception('Error updating booking state: $e');
    }
  }

  Future<Booking> createBooking(Booking booking) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await https.post(
        Uri.parse('$baseUrl/booking/create-booking'),
        headers: headers,
        body: json.encode(Booking.toDisplayableBooking(booking)),
      );

      if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createBooking: $e');
      throw Exception('Error creating booking: $e');
    }
  }

  Future<List<Booking>> getBookings(String hotelId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await https.get(
        Uri.parse('$baseUrl/booking/get-all-bookings?hotelId=$hotelId'),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw Exception('No autorizado. Por favor, inicia sesión nuevamente.');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bookingsJson = data['data'] ?? [];
        return bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getBookings: $e');
      throw Exception('Error fetching bookings: $e');
    }
  }
}