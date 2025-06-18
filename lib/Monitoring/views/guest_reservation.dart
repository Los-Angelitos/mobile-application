import 'package:flutter/material.dart';
import 'package:sweetmanager/Monitoring/models/booking.dart';
import 'package:sweetmanager/Monitoring/services/booking_service.dart';
import 'package:sweetmanager/shared/infrastructure/misc/token_helper.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart'; // Adjust path as needed

class GuestReservationView extends StatefulWidget {
  const GuestReservationView({super.key});

  @override
  State<GuestReservationView> createState() => _GuestReservationScreenState();
}

class _GuestReservationScreenState extends State<GuestReservationView> {
  final BookingService _bookingService = BookingService();
  final TokenHelper _tokenHelper = TokenHelper();
  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _customerId;

  // Constants
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _textColor = Color(0xFF2C3E50);
  static const Color _subtitleColor = Color(0xFF95A5A6);
  static const Color _cardBackground = Colors.white;
  static const Color _activeColor = Color(0xFF4CAF50);
  static const double _borderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadBookings();
  }

  Future<void> _initializeAndLoadBookings() async {
    try {
      _customerId = await _tokenHelper.getIdentity();
      if (_customerId != null) {
        await _loadBookings();
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBookings() async {
    if (_customerId == null) return;
    
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      final bookings = await _bookingService.getBookingsByCustomer(_customerId!);
      
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      childScreen: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      role: 'ROLE_GUEST',
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: const Column(
        children: [
          Text(
            'Reservations',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Check all your reservations,\ntheir status, and be ready for\nadventure!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: _subtitleColor,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryBlue,
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load reservations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: _subtitleColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeAndLoadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: _subtitleColor,
            ),
            SizedBox(height: 16),
            Text(
              'No reservations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start exploring to make your first booking!',
              style: TextStyle(
                fontSize: 14,
                color: _subtitleColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: _primaryBlue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85, // Adjust this to control card height
          ),
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            return _buildBookingCard(_bookings[index]);
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final statusColor = _getStatusColor(booking.statusText);
    
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hotel Logo - Use hotelLogo if available, otherwise default icon
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: _primaryBlue,
                shape: BoxShape.circle,
              ),
              child: booking.hotelLogo != null && booking.hotelLogo!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        booking.hotelLogo!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.hotel,
                            color: Colors.white,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.hotel,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
            
            const SizedBox(height: 12),
            
            // Hotel Name - Use hotelName if available, otherwise description
            Text(
              booking.hotelName ?? booking.description ?? 'Hotel',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // Phone Number - Use hotelPhone if available
            Column(
              children: [
                if (booking.hotelPhone != null && booking.hotelPhone!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: _subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.hotelPhone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _subtitleColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        size: 14,
                        color: _subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Room ${booking.roomId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _subtitleColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Text(
                  '\$${booking.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status Badge - Use statusText from your model
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                booking.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Cancel Button - Only show if booking can be cancelled
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                onPressed: booking.canCancel ? () => _showCancelDialog(booking) : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: booking.canCancel 
                        ? _subtitleColor.withOpacity(0.5)
                        : _subtitleColor.withOpacity(0.2)
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: booking.canCancel ? _subtitleColor : _subtitleColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return _activeColor;
      case 'CONFIRMED':
        return Colors.blue;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return _subtitleColor;
    }
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Reservation'),
          content: Text(
            'Are you sure you want to cancel your reservation for ${booking.hotelName ?? booking.description ?? 'this hotel'}?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(booking);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: _primaryBlue),
        ),
      );

      // Replace with your actual cancel booking service call if available
      // await _bookingService.cancelBooking(booking.id);
      
      // Simulate API call for now
      await Future.delayed(const Duration(seconds: 1));

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Refresh the bookings list to get updated data
      await _loadBookings();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservation cancelled successfully'),
            backgroundColor: _activeColor,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel reservation: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}