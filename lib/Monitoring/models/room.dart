// lib/Monitoring/models/room_model.dart
class Room {
  final int id;
  final String number;
  final String guest;
  final String checkIn;
  final String checkOut;
  final bool available;
  final int typeRoomId;
  final String state;

  Room({
    required this.id,
    required this.number,
    this.guest = '',
    this.checkIn = '',
    this.checkOut = '',
    required this.available,
    required this.typeRoomId,
    required this.state,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      number: json['number'] ?? json['roomNumber'] ?? '',
      guest: json['guestName'] ?? json['guest'] ?? '',
      checkIn: json['checkInDate'] ?? json['checkIn'] ?? '',
      checkOut: json['checkOutDate'] ?? json['checkOut'] ?? '',
      available: json['state'] == 'Disponible' || json['state'] == 'Available' || json['available'] == true,
      typeRoomId: json['typeRoomId'] ?? json['roomTypeId'] ?? 0,
      state: json['state'] ?? json['status'] ?? 'Desconocido',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'guest': guest,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'available': available,
      'typeRoomId': typeRoomId,
      'state': state,
    };
  }
}

class RoomType {
  final int id;
  final String name;

  RoomType({
    required this.id,
    required this.name,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CreateRoomRequest {
  final int typeRoomId;
  final int hotelId;
  final String state;
  final String? roomNumber;
  final String? number;
  final String? name;

  CreateRoomRequest({
    required this.typeRoomId,
    required this.hotelId,
    this.state = 'Disponible',
    this.roomNumber,
    this.number,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'typeRoomId': typeRoomId,
      'hotelId': hotelId,
      'state': state,
    };

    if (roomNumber != null) json['roomNumber'] = roomNumber;
    if (number != null) json['number'] = number;
    if (name != null) json['name'] = name;

    return json;
  }
}

class UpdateRoomStateRequest {
  final int id;
  final String state;

  UpdateRoomStateRequest({
    required this.id,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
    };
  }
}