import 'package:sweetmanager/IAM/domain/model/aggregates/guest.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/owner.dart';
import 'package:sweetmanager/IAM/domain/model/queries/update_user_profile_request.dart';
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService extends BaseService {
  final tempToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiI3MjIyMTU3MSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2hhc2giOiJ0MUlXZ0gvckhNMWlBdHY0dlZPcytnPT03YzhkamJ3RzNCSithNDY0VUlhd3lnPT0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJST0xFX09XTkVSIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbG9jYWxpdHkiOiIwIiwiZXhwIjoxNzQ5MDAyNzc3LCJpc3MiOiJsb2NhbGhvc3QiLCJhdWQiOiJsb2NhbGhvc3QifQ.9Py34daIBlkljXQrNRN50XsBulbq6rU7TlGMuxlorno";

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await storage.read(key: 'auth_token');
      headers['Authorization'] = 'Bearer $tempToken';

      if (token != null) {
        headers['Authorization'] = 'Bearer $tempToken';
      }
    }

    return headers;
  }

  Future<Owner?> getOwnerProfile(int userId) async {
    try {
      final headers = await _getHeaders();
      print('uri $baseUrl/user/owners/$userId');
      print('headers $headers');

      final response = await http.get(
        Uri.parse('$baseUrl/user/owners/$userId'),
        headers: headers,
      );
      print(response.body);
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load user profile: ${response.reasonPhrase}');
      }

      final data = json.decode(response.body);
      return Owner.fromJson(data);
    } catch (e) {
      print(e);
    }
  }

  Future<Guest?> getGuestProfile(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/guests/$userId'),
        headers: headers,
      );
      print('Response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load user profile: ${response.reasonPhrase}');
      }

      final data = json.decode(response.body);
      return Guest.fromJson(data);
    } catch (e) {
      print(e);
    }
  }

  Future<bool> updateUserProfile(
      EditUserProfileRequest request, int userId, int roleId) async {
    try {
      final headers = await _getHeaders();
      final uri = (roleId == 3)
          ? Uri.parse('$baseUrl/user/guests/$userId')
          : Uri.parse('$baseUrl/user/owners/$userId');

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update owner profile: ${response.reasonPhrase}');
      }

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
