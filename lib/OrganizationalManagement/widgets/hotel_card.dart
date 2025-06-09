import 'package:flutter/material.dart';
import 'package:sweetmanager/OrganizationalManagement/models/hotel.dart';
import 'package:sweetmanager/OrganizationalManagement/models/multimedia.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final Multimedia? multimedia;

  final VoidCallback onTap;

  const HotelCard({
    Key? key,
    required this.hotel,
    required this.multimedia,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    multimedia?.url ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC49nTeeuObEO_ZI-NpfFx2SaVWvh8_bOw9w&s',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2), // cambia el width aquí si deseas
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIQ9WUL_LFf-l4PPaBUyvF37jWLVSYTjwVTg&s',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error, size: 24, color: Colors.red),
                        ),
                      ),
                    ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    hotel.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'S/ 200', // acaaaa incorporar el precio del bc reservation
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      Text(
                        ' per night',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
