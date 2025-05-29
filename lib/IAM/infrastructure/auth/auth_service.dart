import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';

class AuthService extends BaseService {

  Future<bool> login(String email, String password, int roleId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/authentication/sign-in'),
      headers: {
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'roleId': roleId
      }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await storage.write(key: 'token', value: data['token']);

        return true;
      }

      return false;
    } catch(e) {
      rethrow;
    }
  }

  // Future<bool>signUpOwner

  // Future<bool>signUpGuest

  Future<void> logout() async{
    await storage.delete(key: 'token');
  }

  Future<bool> isAuthenticated() async{
    final token = await storage.read(key: 'token');

    return token == null? false: true;
  }
}