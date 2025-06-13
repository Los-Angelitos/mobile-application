import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sweetmanager/shared/infrastructure/misc/token_helper.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';
import '../../IAM/infrastructure/auth/auth_service.dart';
import '../models/provider.dart';
import '../services/provider_service.dart';
import '../widgets/provider_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProvidersView extends StatefulWidget {
  const ProvidersView({super.key});

  @override
  State<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends State<ProvidersView> {
  final ProviderService _providerService = ProviderService();
  final AuthService _authService = AuthService();
  List<Provider> _providers = [];
  final TokenHelper _tokenHelper = TokenHelper();
  bool _loading = true;
  late Future<bool> _fetchProvidersCall;
  @override
  void initState() {
    super.initState();
    _fetchProvidersCall = _fetchProviders();
  }

  /* Future<String?> getHotelIdFromToken() async {
    try {
      final token = await _authService.storage.read(key: 'token');
      if (token == null) {
        throw Exception('No token found');
      }

      print('Token found: ${token.substring(0, 20)}...');

      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT format');
      }

      String base64Payload = parts[1];

      while (base64Payload.length % 4 != 0) {
        base64Payload += '=';
      }

      final payload = json.decode(utf8.decode(base64Decode(base64Payload)));
      print('Token payload: $payload');

      // Intenta diferentes claims posibles
      final possibleClaims = [
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality",
        "locality",
        "hotelId",
      ];

      String? hotelId;
      for (final claim in possibleClaims) {
        if (payload[claim] != null) {
          hotelId = payload[claim].toString();
          print('Found hotel ID in claim "$claim": $hotelId');
          break;
        }
      }

      if (hotelId == null) {
        print('Available claims in token: ${payload.keys.toList()}');
        throw Exception('Customer ID not found in token');
      }

      return hotelId;
    } catch (e) {
      print('Error getting hotel ID from token: $e');
      return null;
    }
  }

  Future<String?> getRoleFromToken() async {
    try {
      final token = await _authService.storage.read(key: 'token');
      if (token == null) {
        throw Exception('No token found');
      }

      print('Token found: ${token.substring(0, 20)}...');

      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT format');
      }

      String base64Payload = parts[1];

      while (base64Payload.length % 4 != 0) {
        base64Payload += '=';
      }

      final payload = json.decode(utf8.decode(base64Decode(base64Payload)));
      print('Token payload: $payload');

      // Posibles claims donde se podría almacenar el rol del usuario
      final possibleClaims = [
        "http://schemas.microsoft.com/ws/2008/06/identity/claims/role",
        "role",
      ];

      String? userRole;
      for (final claim in possibleClaims) {
        if (payload.containsKey(claim)) {
          userRole = payload[claim].toString();
          print('Found role in claim "$claim": $userRole');
          break;
        }
      }

      if (userRole == null) {
        print('Available claims in token: ${payload.keys.toList()}');
        throw Exception('User role not found in token');
      }

      return userRole;
    } catch (e) {
      print('Error getting role from token: $e');
      return null;
    }
  } */

  Future<bool> _fetchProviders() async {
    final hotelId = await _tokenHelper.getLocality();
    if (hotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el hotelId del token')),
      );
      setState(() => _loading = false);
      return false;
    }

    final result = await _providerService.getProvidersByHotelId(hotelId);
    setState(() {
      _providers = result.where((p) => p.state.toLowerCase() == 'active').toList();
      _loading = false;
    });
    return true;
  }

  void _showDetails(Provider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            const SizedBox(height: 12),
            Text(provider.name, textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${provider.email}'),
            Text('Phone: ${provider.phone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  void _deleteProvider(Provider provider) async {
    final success = await _providerService.deleteProvider(provider.id);
    if (success == false) {
      _fetchProviders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete provider')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: _fetchProvidersCall, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
            return BaseLayout(role: "ROLE_OWNER", childScreen: getContentBuild(context));
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center,));
      }
    );
  }

  Widget getContentBuild(BuildContext context) {
  return Scaffold(
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _providers.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No hay proveedores para mostrar.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loading = true;
                          _fetchProvidersCall = _fetchProviders(); // Refresh data
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Recargar'),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  itemCount: _providers.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final provider = _providers[index];
                    return ProviderCard(
                      provider: provider,
                      onDetailsPressed: () => _showDetails(provider),
                      onDeletePressed: () => _deleteProvider(provider),
                    );
                  },
                ),
              ),
  );
}
}
