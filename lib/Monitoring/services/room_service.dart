import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Monitoring/models/room_type.dart';
import 'package:sweetmanager/shared/infrastructure/services/base_service.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';
import 'package:sweetmanager/Monitoring/models/room_type.dart';

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

      final hotelId = await getHotelIdFromToken();
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
      final hotelId = await getHotelIdFromToken();
      if (hotelId == null) {
        throw Exception('Hotel ID not found in token');
      }

      // CORREGIDO: Crear el request con el ID especificado por el usuario
      final createRequest = CreateRoomRequest(
        id: request.id, // CORREGIDO: Usar el ID proporcionado por el usuario
        typeRoomId: request.typeRoomId,
        hotelId: hotelId,
        state: 'DISPONIBLE', // CORREGIDO: Usar el formato esperado por la API
        roomNumber: request.id.toString(), // Usar el ID como número de habitación
      );

      final response = await http.post(
        Uri.parse('$baseUrl/room/create-room'),
        headers: await _getHeaders(),
        body: jsonEncode(createRequest.toJson()),
      );

      print('Request payload: ${jsonEncode(createRequest.toJson())}'); // DEBUG
      print('Response status: ${response.statusCode}'); // DEBUG
      print('Response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // CORREGIDO: Crear el Room con los datos correctos
        try {
          return Room.fromJson(responseData);
        } catch (e) {
          print('Error parsing response, creating manual room: $e'); // DEBUG
          // Si falla el parsing, crear un Room manual con los datos conocidos
          return Room(
            id: request.id,
            number: request.id.toString(),
            guest: '',
            checkIn: '',
            checkOut: '',
            available: true, // Estado inicial disponible
            typeRoomId: request.typeRoomId,
            state: 'DISPONIBLE',
          );
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}'); // DEBUG
        _handleHttpError(response);
        throw Exception('Error al crear habitación');
      }

    } catch (error) {
      print('Exception in createRoom: $error'); // DEBUG
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

      // CORREGIDO: Usar el formato de estado que espera la API
      final apiState = _convertStateToApiFormat(newState);

      final response = await http.put(
        Uri.parse('$baseUrl/room/update-room-state/$roomId'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'state': apiState,
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

  // NUEVO: Método para convertir estados de la UI al formato de la API
  String _convertStateToApiFormat(String uiState) {
    switch (uiState) {
      case 'Disponible':
        return 'DISPONIBLE';
      case 'Ocupada':
        return 'OCUPADA';
      case 'Mantenimiento':
        return 'MANTENIMIENTO';
      case 'Limpieza':
        return 'LIMPIEZA';
      case 'Fuera de Servicio':
        return 'FUERA_DE_SERVICIO';
      default:
        return 'DISPONIBLE';
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

  Future<List<RoomType>> getTypeRoomsByHotel(int hotelId) async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(Uri.parse('$baseUrl/type-room/get-all-type-rooms?hotelId=$hotelId'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
      
        return jsonList.map((json) {
          return RoomType(
            id: json['id'] ?? 0,
            name: json['description'] ?? '', // map 'description' to 'name'
            price: json['price'] ?? '',
          );
        }).toList();
      }

      return [];
    }
    catch(e) {
      rethrow;
    }
  }

  Future<double> getMinimumPriceRoomByHotelId(int hotelId) async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(Uri.parse('$baseUrl/type-room/get-minimum-price-type-room-by-hotel-id?hotelId=$hotelId'),headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        return responseJson['minimumPrice'] as double;
      }
      return 0;
    }
    catch(e) {
      rethrow;
    }
  }
  
  Future<int> getRoomByTypeRoomId(int typeRoomId) async {
    try {
      final token = await storage.read(key: 'token');
      final response = await http.get(
        Uri.parse('$baseUrl/room/get-room-by-type-room?typeRoomId=$typeRoomId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rooms = jsonDecode(response.body);

        // Filter only rooms with status == "active"
        final activeRooms = rooms.where((room) => room['status'] == 'active').toList();

        if (activeRooms.isNotEmpty) {
          final randomRoom = activeRooms[Random().nextInt(activeRooms.length)];
          return randomRoom['id'] as int;
        }
      }

      return 0; // No active room found or bad response
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RoomType>> getRoomTypesByHotel() async {
    try {
      final token = await _getValidToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación válido');
      }

      final hotelId = await getHotelIdFromToken();
      if (hotelId == null) {
        throw Exception('No se pudo obtener el ID del hotel del token');
      }

      // CORREGIDO: Usar el parámetro correcto 'hotelid' (minúscula)
      final uri = Uri.parse('$baseUrl/type-room/get-all-type-rooms').replace(
          queryParameters: {'hotelid': hotelId.toString()} // CORREGIDO: 'hotelid' en minúscula
      );

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('Room types response status: ${response.statusCode}'); // DEBUG
      print('Room types response body: ${response.body}'); // DEBUG

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> roomTypesJson;

        if (responseData is List) {
          roomTypesJson = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          roomTypesJson = responseData['data'] as List;
        } else {
          return [];
        }

        // CORREGIDO: Manejar duplicados del servidor
        final Map<int, RoomType> uniqueRoomTypes = {};

        for (final json in roomTypesJson) {
          try {
            final roomType = RoomType.fromJson(json);

            // Solo agregar si es válido y no está duplicado
            if (roomType.id > 0) {
              uniqueRoomTypes[roomType.id] = roomType;
            }
          } catch (e) {
            print('Error parsing room type: $e, json: $json'); // DEBUG
            continue;
          }
        }

        final result = uniqueRoomTypes.values.toList();
        print('Unique room types: ${result.length}'); // DEBUG

        return result;

      } else {
        _handleHttpError(response);
        return [];
      }

    } catch (error) {
      print('Error loading room types: $error');
      throw error;
    }
  }
}