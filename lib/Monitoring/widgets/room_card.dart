// lib/Monitoring/widgets/room_card_widget.dart
import 'package:flutter/material.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';

class RoomCardWidget extends StatelessWidget {
  final Room room;
  final VoidCallback? onChangeState;

  const RoomCardWidget({
    super.key,
    required this.room,
    this.onChangeState,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4), // CORREGIDO: Reducido margen
      child: Padding(
        padding: const EdgeInsets.all(12), // CORREGIDO: Reducido padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // CORREGIDO: Tamaño mínimo
          children: [
            // CORREGIDO: Icono de puerta más compacto
            Container(
              width: 50, // CORREGIDO: Reducido
              height: 60, // CORREGIDO: Reducido
              decoration: BoxDecoration(
                color: room.available ? const Color(0xFFE6F0FF) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: room.available ? const Color(0xFF0066CC) : const Color(0xFFDDD),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 35, // CORREGIDO: Tamaño fijo para consistencia
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.brown[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset(
                        '../assets/images/door.png',
                        width: 40,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback si no se encuentra la imagen
                          return Container(
                            width: 40,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.brown[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.door_front_door,
                              color: Colors.brown,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Manija de la puerta
                  Positioned(
                    left: 10,
                    top: 30,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8), // CORREGIDO: Reducido

            // Número de habitación
            Text(
              room.number.isNotEmpty ? room.number : 'Habitación ${room.id}',
              style: const TextStyle(
                fontSize: 14, // CORREGIDO: Reducido
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // CORREGIDO: Limitado a 1 línea
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6), // CORREGIDO: Reducido

            // Estado de la habitación
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // CORREGIDO: Reducido
              decoration: BoxDecoration(
                color: _getStateColor(room.state).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                room.state,
                style: TextStyle(
                  fontSize: 10, // CORREGIDO: Reducido
                  color: _getStateColor(room.state),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8), // CORREGIDO: Reducido

            // CORREGIDO: Información de huésped más compacta
            if (room.guest.isNotEmpty) ...[
              Text(
                room.guest,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
            ],

            // CORREGIDO: Fechas más compactas
            if (room.checkIn.isNotEmpty || room.checkOut.isNotEmpty) ...[
              Column(
                children: [
                  if (room.checkIn.isNotEmpty)
                    Text(
                      'In: ${room.checkIn}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (room.checkOut.isNotEmpty)
                    Text(
                      'Out: ${room.checkOut}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // CORREGIDO: Botones más compactos
            Expanded( // CORREGIDO: Usa el espacio disponible
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botón de disponibilidad
                  SizedBox(
                    width: double.infinity,
                    height: 28, // CORREGIDO: Altura fija
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: room.available
                            ? const Color(0xFFE6F0FF)
                            : const Color(0xFFFF6B6B),
                        foregroundColor: room.available
                            ? const Color(0xFF0066CC)
                            : Colors.white,
                        disabledBackgroundColor: room.available
                            ? const Color(0xFFE6F0FF)
                            : const Color(0xFFFF6B6B),
                        disabledForegroundColor: room.available
                            ? const Color(0xFF0066CC)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 4), // CORREGIDO
                      ),
                      child: Text(
                        room.available ? 'Disponible' : 'No Disponible',
                        style: const TextStyle(fontSize: 10), // CORREGIDO
                      ),
                    ),
                  ),

                  const SizedBox(height: 6), // CORREGIDO: Reducido

                  // Botón para cambiar estado
                  SizedBox(
                    width: double.infinity,
                    height: 28, // CORREGIDO: Altura fija
                    child: OutlinedButton(
                      onPressed: onChangeState,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0066CC),
                        side: const BorderSide(color: Color(0xFF0066CC)),
                        padding: const EdgeInsets.symmetric(horizontal: 4), // CORREGIDO
                      ),
                      child: const Text(
                        'Cambiar Estado',
                        style: TextStyle(fontSize: 10), // CORREGIDO
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'disponible':
      case 'available':
        return Colors.green;
      case 'ocupada':
      case 'occupied':
        return Colors.red;
      case 'mantenimiento':
      case 'maintenance':
        return Colors.orange;
      case 'limpieza':
      case 'cleaning':
        return Colors.blue;
      case 'fuera de servicio':
      case 'out of service':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}