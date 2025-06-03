// widgets/reservation_card.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';

class ReservationCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const ReservationCard({
    Key? key,
    required this.booking,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
        child: Column(
          mainAxisSize: MainAxisSize.min, // Importante: usar el mínimo espacio necesario
          children: [
            // Hotel logo - reducido
            Container(
              width: 60, // Reducido de 80 a 60
              height: 60, // Reducido de 80 a 60
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2196F3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: booking.hotelLogo != null
                  ? ClipOval(
                child: Image.network(
                  booking.hotelLogo!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultLogo(),
                ),
              )
                  : _buildDefaultLogo(),
            ),

            const SizedBox(height: 8), // Reducido de 12 a 8

            // Hotel name - texto más compacto
            Flexible( // Usar Flexible para evitar overflow
              child: Text(
                booking.hotelName ?? 'Hoteles Decameron Perú',
                style: const TextStyle(
                  fontSize: 14, // Reducido de 16 a 14
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Máximo 2 líneas
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6), // Reducido de 8 a 6

            // Phone number - más compacto
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone,
                  color: Colors.red,
                  size: 14, // Reducido de 16 a 14
                ),
                const SizedBox(width: 4),
                Text(
                  '(072) 596730',
                  style: TextStyle(
                    fontSize: 11, // Reducido de 12 a 11
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12), // Reducido de 16 a 12

            // Status badge - más compacto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6), // Reducido de 8 a 6
              decoration: BoxDecoration(
                color: _getStatusColor(booking.state),
                borderRadius: BorderRadius.circular(16), // Reducido de 20 a 16
              ),
              child: Text(
                booking.statusText,
                style: TextStyle(
                  color: _getStatusTextColor(booking.state),
                  fontWeight: FontWeight.w600,
                  fontSize: 12, // Reducido de 14 a 12
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8), // Reducido de 12 a 8

            // Cancel button - más compacto
            if (booking.canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8), // Reducido de 12 a 8
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(color: Colors.grey[400]!),
                    minimumSize: const Size(0, 32), // Altura mínima del botón
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12, // Reducido de 14 a 12
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 60, // Actualizado para coincidir con el nuevo tamaño
      height: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF2196F3),
      ),
      child: const Icon(
        Icons.hotel,
        color: Colors.white,
        size: 30, // Reducido de 40 a 30
      ),
    );
  }

  Color _getStatusColor(String state) {
    switch (state.toLowerCase()) {
      case 'active':
      case 'confirmed':
        return const Color(0xFFE3F2FD);
      case 'cancelled':
      case 'inactive':
        return const Color(0xFFFFEBEE);
      case 'pending':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _getStatusTextColor(String state) {
    switch (state.toLowerCase()) {
      case 'active':
      case 'confirmed':
        return const Color(0xFF1976D2);
      case 'cancelled':
      case 'inactive':
        return const Color(0xFFD32F2F);
      case 'pending':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFFD32F2F);
    }
  }
}