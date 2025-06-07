import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';
import '../models/provider.dart';

class ProviderService extends BaseService {
  Future<List<Provider>> getProvidersByHotelId(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/hotel/$hotelId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Provider.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Provider>> getProviders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Provider.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Provider?> getProviderById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/providers/$id'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Provider.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> createProvider(Provider provider) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/providers'),
        headers: {
          'Content-Type': 'application/json'
        },
        body: jsonEncode(provider.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProvider(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/providers/$id'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
