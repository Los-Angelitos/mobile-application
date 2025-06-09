import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sweetmanager/OrganizationalManagement/models/hotel.dart';
import 'package:sweetmanager/OrganizationalManagement/models/multimedia.dart';
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';

class HotelService extends BaseService {
    Future<List<Hotel>> getHotels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hotels'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
    Future<Hotel?> getHotelById(int hotelId) async {
        try {
        final response = await http.get(
            Uri.parse('$baseUrl/hotels/$hotelId'),
            headers: {
            'Content-Type': 'application/json'
            },
        );
    
        if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            return Hotel.fromJson(data);
        } else {
            return null;
        }
        } catch (e) {
        return null;
        }
    }
  
    Future<List<Hotel>> getHotelByCategory(String category) async {
        try {
        final response = await http.get(
            Uri.parse('$baseUrl/hotels?category=$category'),
            headers: {
            'Content-Type': 'application/json'
            },
        );

        if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            return data.map((json) => Hotel.fromJson(json)).toList();
        } else {
            return [];
        }
        } catch (e) {
        return [];
        }
    }

  Future<Multimedia?> getMainHotelMultimedia(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/multimedia/main?hotelId=$hotelId'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Multimedia.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Multimedia?> getHotelLogoMultimedia(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/multimedia/logo?hotel=$hotelId'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Multimedia.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Multimedia>> getHotelDetailMultimedia(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/multimedia/details?hotelId=$hotelId'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Multimedia.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}