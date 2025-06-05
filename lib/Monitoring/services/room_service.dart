import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';

class RoomService extends BaseService {

  Future<String?> _getValidToken() async {
    try {
      final token = await storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        return null;
      }

      if (JwtDecoder.isExpired(token)) {
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  Future<int?> _getHotelIdFromToken() async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);

      const hotelIdClaim = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality";

      if (decodedToken.containsKey(hotelIdClaim)) {
        final hotelId = int.tryParse(decodedToken[hotelIdClaim].toString());
        if (hotelId != null) {
          return hotelId;
        }
      }

      const possibleHotelClaims = [
        "hotelId", "hotel_id", "hotel", "HotelId", "HOTEL_ID"
      ];

      for (final claim in possibleHotelClaims) {
        if (decodedToken.containsKey(claim)) {
          final hotelId = int.tryParse(decodedToken[claim].toString());
          if (hotelId != null) {
            return hotelId;
          }
        }
      }

      return null;

    } catch (error) {
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getValidToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (token != null) 'X-Auth-Token': token,
    };
  }

  Future<List<Room>> getRoomsByHotel() async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación válido');
      }

      final hotelId = await _getHotelIdFromToken();
      if (hotelId == null) {
        throw Exception('No se pudo obtener el ID del hotel del token');
      }

      final uri = Uri.parse('$baseUrl/room/get-all-rooms').replace(
          queryParameters: {'hotelId': hotelId.toString()}
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> roomsJson;

        if (responseData is List) {
          roomsJson = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          roomsJson = responseData['data'] as List;
        } else {
          return [];
        }

        final rooms = roomsJson.map((json) => Room.fromJson(json)).toList();
        return rooms;

      } else {
        _handleHttpError(response);
        return [];
      }

    } catch (error) {
      rethrow;
    }
  }

  Future<Room> createRoom(CreateRoomRequest request) async {
    try {
      final hotelId = await _getHotelIdFromToken();
      if (hotelId == null) {
        throw Exception('Hotel ID not found in token');
      }

      final List<Map<String, dynamic>> payloadOptions = [
        CreateRoomRequest(
          typeRoomId: request.typeRoomId,
          hotelId: hotelId,
          state: request.state,
          roomNumber: request.roomNumber ?? request.number ?? request.name,
        ).toJson(),
        CreateRoomRequest(
          typeRoomId: request.typeRoomId,
          hotelId: hotelId,
          state: request.state,
          number: request.roomNumber ?? request.number ?? request.name,
        ).toJson(),
        CreateRoomRequest(
          typeRoomId: request.typeRoomId,
          hotelId: hotelId,
          state: request.state,
          name: request.roomNumber ?? request.number ?? request.name,
        ).toJson(),
      ];

      http.Response? response;
      Object? lastError;

      for (int i = 0; i < payloadOptions.length; i++) {
        try {
          response = await http.post(
            Uri.parse('$baseUrl/room/create-room'),
            headers: await _getHeaders(),
            body: jsonEncode(payloadOptions[i]),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            break;
          } else {
            lastError = 'HTTP ${response.statusCode}: ${response.body}';
          }
        } catch (e) {
          lastError = e;
          continue;
        }
      }

      if (response == null) {
        throw Exception('Todos los intentos de creación fallaron. Último error: $lastError');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final createdRoom = Room(
          id: DateTime.now().millisecondsSinceEpoch,
          number: request.roomNumber ?? request.number ?? request.name ?? 'Nueva habitación',
          guest: '',
          checkIn: '',
          checkOut: '',
          available: request.state == 'Disponible',
          typeRoomId: request.typeRoomId,
          state: request.state,
        );

        return createdRoom;
      } else {
        _handleHttpError(response);
        throw Exception('Error al crear habitación');
      }

    } catch (error) {
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception('Error creando habitación: $error');
      }
    }
  }

  // MÉTODO CORREGIDO: Mejor manejo de la respuesta del servidor
  Future<Room> updateRoomState(int roomId, String state) async {
    try {
      final request = UpdateRoomStateRequest(id: roomId, state: state);

      final response = await http.put(
        Uri.parse('$baseUrl/room/update-room-state'),
        headers: await _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Manejo mejorado de diferentes tipos de respuesta
        if (response.body.isNotEmpty) {
          try {
            final responseData = jsonDecode(response.body);

            // Si la respuesta es un objeto con datos
            if (responseData is Map<String, dynamic>) {
              if (responseData.containsKey('data') && responseData['data'] is Map) {
                return Room.fromJson(responseData['data']);
              } else if (responseData.containsKey('id')) {
                // Si la respuesta contiene directamente los datos de la habitación
                return Room.fromJson(responseData);
              }
            }
          } catch (e) {
            // Si hay error al parsear JSON, continuamos con la lógica de fallback
            print('Error parsing response JSON: $e');
          }
        }

        // FALLBACK: Crear un objeto Room temporal con los datos conocidos
        // Esto evita el error y permite que la actualización local funcione
        return Room(
          id: roomId,
          number: 'Habitación $roomId', // Valor temporal
          guest: '',
          checkIn: '',
          checkOut: '',
          available: state == 'Disponible',
          typeRoomId: 1, // Valor por defecto
          state: state,
        );

      } else {
        _handleHttpError(response);
        throw Exception('Error al actualizar estado de habitación');
      }

    } catch (error) {
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception('Error actualizando estado: $error');
      }
    }
  }

  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw Exception('Token de autenticación inválido. Por favor, inicia sesión nuevamente.');
      case 403:
        throw Exception('No tienes permisos para acceder a esta información.');
      case 404:
        throw Exception('Endpoint no encontrado. Verifica la URL de la API.');
      case 500:
      case 502:
      case 503:
        throw Exception('Error del servidor. Por favor, intenta más tarde.');
      default:
        try {
          final responseData = jsonDecode(response.body);
          final message = responseData['message'] ?? 'Error desconocido';
          throw Exception(message);
        } catch (e) {
          throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
        }
    }
  }
}