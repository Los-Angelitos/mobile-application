import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/guest.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/owner.dart';
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService extends BaseService {
  final tempToken =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9zaWQiOiI3MjIyMTU3MiIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2hhc2giOiJGOHUydVYxMnBqS3VpZUIvNmtpc1FRPT01dVZveVk4U1JTam5RRFdMQUFKU1F3PT0iLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3JvbGUiOiJST0xFX0dVRVNUIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbG9jYWxpdHkiOiIwIiwiZXhwIjoxNzQ4NzEwNDQwLCJpc3MiOiJsb2NhbGhvc3QiLCJhdWQiOiJsb2NhbGhvc3QifQ.Y-zy1PObl2F1inijCpbB_ibLWoSedhqwCvkua7U8GYo";

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

  Future<Guest> getGuestProfile(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/guests/$userId'),
        headers: headers,
      );
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to load user profile: ${response.reasonPhrase}');
      }

      final data = json.decode(response.body);
      return Guest.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }
}
