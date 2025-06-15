import 'package:flutter/material.dart';

class HotelSetupScreen extends StatefulWidget {
  const HotelSetupScreen({super.key});

  @override
  State<HotelSetupScreen> createState() => _HotelSetupScreenState();
}

class _HotelSetupScreenState extends State<HotelSetupScreen> {
  final TextEditingController _inviteAdminController = TextEditingController();
  
  // Controllers for room counts
  final TextEditingController _simpleRoomController = TextEditingController();
  final TextEditingController _masterRoomController = TextEditingController();
  final TextEditingController _doubleRoomController = TextEditingController();
  final TextEditingController _balconyRoomController = TextEditingController();

  final List<String> _selectedRoomTypes = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Constants
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _textColor = Color(0xFF2C3E50);
  static const Color _subtitleColor = Color(0xFF95A5A6);
  static const Color _purpleColor = Color(0xFF9C27B0);
  static const Color _inputBorderColor = Color(0xFFE0E0E0);
  static const double _borderRadius = 8.0;

  @override
  void initState() {
    super.initState();
    _inviteAdminController.text = 'admin.jose@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hotel\'s details',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Complete the form:',
          style: TextStyle(
            fontSize: 16,
            color: _subtitleColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoomTypesSection(),
        const SizedBox(height: 32),
        _buildInviteAdminField(),
      ],
    );
  }

  Widget _buildRoomTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Room\'s Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _purpleColor,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _purpleColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '*',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRoomTypeCheckboxes(),
      ],
    );
  }

  Widget _buildRoomTypeCheckboxes() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildRoomTypeWithInput('Simple Room', _simpleRoomController),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRoomTypeWithInput('Master Room', _masterRoomController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRoomTypeWithInput('Double Room', _doubleRoomController),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRoomTypeWithInput('Balcony Rooms', _balconyRoomController),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomTypeWithInput(String roomType, TextEditingController controller) {
    final isSelected = _selectedRoomTypes.contains(roomType);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedRoomTypes.remove(roomType);
                controller.clear();
              } else {
                _selectedRoomTypes.add(roomType);
              }
            });
          },
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSelected ? _purpleColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _purpleColor : _inputBorderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  roomType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? _purpleColor : _textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isSelected) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(color: _inputBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 14,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Number of rooms',
                hintStyle: TextStyle(
                  color: _subtitleColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (isSelected && (value == null || value.trim().isEmpty)) {
                  return 'Required';
                }
                if (isSelected && int.tryParse(value!) == null) {
                  return 'Enter valid number';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInviteAdminField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invite admin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _subtitleColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_borderRadius),
                  border: Border.all(color: _inputBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _inviteAdminController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  validator: _validateEmail,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _inputBorderColor,
                borderRadius: BorderRadius.circular(_borderRadius),
              ),
              child: const Text(
                'ari@mail.com',
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildBackButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildContinueButton(),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: _handleBack,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: _inputBorderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Back',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  bool _validateForm() {
    bool isValid = _formKey.currentState!.validate();
    
    if (_selectedRoomTypes.isEmpty) {
      _showErrorMessage('Please select at least one room type');
      isValid = false;
    }
    
    return isValid;
  }

  // Action handlers
  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _showInfoMessage('No previous screen available');
    }
  }

  void _handleContinue() {
    if (!_validateForm()) {
      return;
    }

    _processHotelDetails();
  }

  void _processHotelDetails() {
    final hotelDetails = {
      'roomTypes': _selectedRoomTypes.map((roomType) {
        TextEditingController controller;
        switch (roomType) {
          case 'Simple Room':
            controller = _simpleRoomController;
            break;
          case 'Master Room':
            controller = _masterRoomController;
            break;
          case 'Double Room':
            controller = _doubleRoomController;
            break;
          case 'Balcony Rooms':
            controller = _balconyRoomController;
            break;
          default:
            controller = TextEditingController();
        }
        return {
          'type': roomType,
          'count': int.tryParse(controller.text) ?? 0,
        };
      }).toList(),
      'inviteAdmin': _inviteAdminController.text.trim(),
    };

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: _primaryBlue),
      ),
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog(hotelDetails);
    });
  }

  void _showSuccessDialog(Map<String, dynamic> hotelDetails) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Hotel Details Saved'),
        content: Text(
          'Hotel details have been saved successfully!\n\n'
          'Room Quantity: ${hotelDetails['roomQuantity']}\n'
          'Room Types: ${(hotelDetails['roomTypes'] as List).join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToNextScreen();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _navigateToNextScreen() {
    // Replace with your actual navigation logic
    Navigator.pushReplacementNamed(context, '/hotel/set-up/review');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _inviteAdminController.dispose();
    super.dispose();
  }
}