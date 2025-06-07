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

  // MÉTODO PÚBLICO: Cambiado de privado a público para acceso desde RoomsView
  Future<int?> getHotelIdFromToken() async {
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

      final hotelId = await getHotelIdFromToken(); // Usando el método público
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
      final hotelId = await getHotelIdFromToken(); // Usando el método público
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
        final responseData = jsonDecode(response.body);

        // Intentar crear el Room desde la respuesta del servidor
        try {
          return Room.fromJson(responseData);
        } catch (e) {
          // Si falla, crear un Room manual
          return Room(
            id: DateTime.now().millisecondsSinceEpoch,
            number: request.roomNumber ?? request.number ?? request.name ?? 'Nueva habitación',
            guest: '',
            checkIn: '',
            checkOut: '',
            available: request.state == 'Disponible',
            typeRoomId: request.typeRoomId,
            state: request.state,
          );
        }
      } else {
        _handleHttpError(response);
        throw Exception('Error al crear habitación');
      }

    } catch (error) {
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception('Error inesperado al crear habitación: $error');
      }
    }
  }

  Future<Room> updateRoomState(int roomId, String newState) async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación válido');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/room/update-room-state/$roomId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'state': newState,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Room.fromJson(responseData);
      } else {
        _handleHttpError(response);
        throw Exception('Error al actualizar estado de la habitación');
      }

    } catch (error) {
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception('Error inesperado al actualizar estado: $error');
      }
    }
  }

  Future<bool> deleteRoom(int roomId) async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación válido');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/room/delete-room/$roomId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        _handleHttpError(response);
        return false;
      }

    } catch (error) {
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception('Error inesperado al eliminar habitación: $error');
      }
    }
  }

  void _handleHttpError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw Exception('Solicitud inválida: ${response.body}');
      case 401:
        throw Exception('No autorizado. Token inválido o expirado');
      case 403:
        throw Exception('Acceso prohibido');
      case 404:
        throw Exception('Recurso no encontrado');
      case 500:
        throw Exception('Error interno del servidor');
      default:
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
    }
  }
}