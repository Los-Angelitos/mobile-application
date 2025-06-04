import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/guest.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/owner.dart';
import 'package:sweetmanager/IAM/domain/model/entities/guest_preference.dart';
import 'package:sweetmanager/IAM/domain/model/queries/update_guest_preferences.dart';
import 'package:sweetmanager/IAM/domain/model/queries/update_user_profile_request.dart';
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService extends BaseService {
  final tempToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiI3MjIyMTU3MyIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2hhc2giOiJSc2ptZUlHOGJ0ZE51S0pqa080UWl3PT1WR01jTXhCcWQ0dkd3QU5BY3FwcEpnPT0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJST0xFX0dVRVNUIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbG9jYWxpdHkiOiIwIiwiZXhwIjoxNzQ5MDE2MTI5LCJpc3MiOiJsb2NhbGhvc3QiLCJhdWQiOiJsb2NhbGhvc3QifQ.mwW7jjLWJhhKwEVPjAZoL8jDWbKQdj0IiNTm2z-OUc8";

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

  Future<bool> setGuestPreferences(GuestPreferences preferences) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/guest-preferences'),
        headers: headers,
        body: json.encode(preferences.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to set guest preferences: ${response.reasonPhrase}');
      }

      return true;
    } catch (e) {
      print('Error setting guest preferences: $e');
      return false;
    }
  }

  Future<GuestPreferences?> getGuestPreferences(int guestId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/guest-preferences/guests/$guestId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load guest preferences: ${response.reasonPhrase}');
      }

      final data = json.decode(response.body);
      return GuestPreferences.fromJson(data);
    } catch (e) {
      print('Error fetching guest preferences: $e');
      return null;
    }
  }

  Future<bool> updateGuestPreferences(
      EditGuestPreferences preferences, int preferenceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/guest-preferences/$preferenceId'),
        headers: headers,
        body: json.encode(preferences.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update guest preferences: ${response.reasonPhrase}');
      }

      return true;
    } catch (e) {
      print('Error updating guest preferences: $e');
      return false;
    }
  }
}
