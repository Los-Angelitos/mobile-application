import 'package:flutter/material.dart';
import 'package:sweetmanager/OrganizationalManagement/models/hotel.dart';
import 'package:sweetmanager/OrganizationalManagement/models/multimedia.dart';

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  final Multimedia? multimedia;
  final Multimedia? logo;

  final VoidCallback onTap;

  const HotelCard({
    Key? key,
    required this.hotel,
    required this.multimedia,
    required this.logo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),          
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
            child:
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12), bottom: Radius.circular(12)),
                  child: Image.network(
                    multimedia?.url ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC49nTeeuObEO_ZI-NpfFx2SaVWvh8_bOw9w&s',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(

                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2), 
                      ),
                      child: ClipOval(
                        child: Image.network(
                          logo?.url ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTC49nTeeuObEO_ZI-NpfFx2SaVWvh8_bOw9w&s',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ),
              ],
            ),
            ),
            Expanded(
              flex: 2,
              child:
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    hotel.address,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'S/ 200', // acaaaa incorporar el precio del bc reservation
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      Text(
                        ' per night',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
