import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HotelSetupReviewScreen extends StatefulWidget {
  const HotelSetupReviewScreen({super.key});

  @override
  State<HotelSetupReviewScreen> createState() => _HotelSetUpReviewScreenState();
}

class _HotelSetUpReviewScreenState extends State<HotelSetupReviewScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _mainImage;
  File? _roomImage;
  File? _poolImage;

  // Constants
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _backgroundColor = Color(0xFFF8F9FA);
  static const Color _textColor = Color(0xFF2C3E50);
  static const Color _subtitleColor = Color(0xFF95A5A6);
  static const Color _borderColor = Color(0xFFE0E0E0);
  static const Color _tealColor = Color(0xFF00695C);
  static const double _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildContent(),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
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
          'Everything ready?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Choose and upload a photo of your hotel so it can\nbe found by the entire SweetManager community.',
          style: TextStyle(
            fontSize: 16,
            color: _subtitleColor,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLogoSection(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildPhotosSection(),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(ImageType.logo),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _logoImage != null ? Colors.transparent : _tealColor,
              shape: BoxShape.circle,
              border: _logoImage != null 
                  ? Border.all(color: _primaryBlue, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _logoImage != null
                ? ClipOval(
                    child: Stack(
                      children: [
                        Image.file(
                          _logoImage!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add Logo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
        _buildHotelInfo(),
      ],
    );
  }

  Widget _buildHotelInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Royal Decameron Punta Sal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Av. Panamericana N, Punta Sal 24560',
          style: TextStyle(
            fontSize: 14,
            color: _subtitleColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'We offer the most modern rooms in the country, from small to large, with beautiful ocean views and incredible service.',
          style: TextStyle(
            fontSize: 14,
            color: _textColor,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 250),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPhotoUpload(
            image: _mainImage,
            onTap: () => _pickImage(ImageType.main),
            height: 100,
            label: 'Main Hotel Photo',
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Row(
              children: [
                Expanded(
                  child: _buildPhotoUpload(
                    image: _roomImage,
                    onTap: () => _pickImage(ImageType.room),
                    height: 70,
                    label: 'Room Photo',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhotoUpload(
                    image: _poolImage,
                    onTap: () => _pickImage(ImageType.pool),
                    height: 70,
                    label: 'Pool Photo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload({
    required File? image,
    required VoidCallback onTap,
    required double height,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: image != null ? _primaryBlue : _borderColor,
            width: image != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(_borderRadius - 1),
                child: Stack(
                  children: [
                    Image.file(
                      image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _buildPlaceholder(label),
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _subtitleColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            size: 16,
            color: _subtitleColor,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add Photo',
          style: TextStyle(
            fontSize: 10,
            color: _subtitleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: _subtitleColor.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFinishButton()
      ],
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _handleFinish,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Finish',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Image picker methods
  Future<void> _pickImage(ImageType type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          switch (type) {
            case ImageType.logo:
              _logoImage = File(pickedFile.path);
              break;
            case ImageType.main:
              _mainImage = File(pickedFile.path);
              break;
            case ImageType.room:
              _roomImage = File(pickedFile.path);
              break;
            case ImageType.pool:
              _poolImage = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  Future<void> _showImageSourceDialog(ImageType type) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildImageSourceOption(
                icon: Icons.photo_library,
                title: 'Gallery',
                subtitle: 'Choose from your photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.gallery, type);
                },
              ),
              const SizedBox(height: 16),
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: 'Take a new photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(ImageSource.camera, type);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _subtitleColor,
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

  Future<void> _pickImageFromSource(ImageSource source, ImageType type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          switch (type) {
            case ImageType.logo:
              _logoImage = File(pickedFile.path);
              break;
            case ImageType.main:
              _mainImage = File(pickedFile.path);
              break;
            case ImageType.room:
              _roomImage = File(pickedFile.path);
              break;
            case ImageType.pool:
              _poolImage = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  // Action handlers

  void _handleFinish() {
    if (_mainImage == null) {
      _showErrorMessage('Please add at least a main hotel photo');
      return;
    }

    _processHotelSetup();
  }

  void _processHotelSetup() {
    final hotelSetup = {
      'logoImage': _logoImage?.path,
      'mainImage': _mainImage?.path,
      'roomImage': _roomImage?.path,
      'poolImage': _poolImage?.path,
      'completedAt': DateTime.now().toIso8601String(),
    };

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: _primaryBlue),
      ),
    );

    // Simulate API call for hotel setup completion
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog(hotelSetup);
    });
  }

  void _showSuccessDialog(Map<String, dynamic> hotelSetup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Hotel Setup Complete!'),
        content: const Text(
          'Congratulations! Your hotel has been successfully registered with SweetManager. '
          'Your property is now ready to welcome guests and be discovered by travelers worldwide.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDashboard();
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    // Replace with your actual navigation logic
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/hotel/overview',
      (route) => false,
    );
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
}

enum ImageType { logo, main, room, pool }