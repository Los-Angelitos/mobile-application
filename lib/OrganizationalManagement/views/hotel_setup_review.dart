import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class HotelSetupReviewScreen extends StatefulWidget {
  const HotelSetupReviewScreen({super.key});

  @override
  State<HotelSetupReviewScreen> createState() => _HotelPhotoUploadScreenState();
}

class _HotelPhotoUploadScreenState extends State<HotelSetupReviewScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _logoImage;
  File? _mainImage;
  File? _roomImage;
  File? _poolImage;
  
  // For web compatibility
  Uint8List? _logoImageBytes;
  Uint8List? _mainImageBytes;
  Uint8List? _roomImageBytes;
  Uint8List? _poolImageBytes;

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

  Widget _buildImageWidget({
    required File? file,
    required Uint8List? bytes,
    required double width,
    required double height,
  }) {
    if (kIsWeb && bytes != null) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.grey,
              size: 24,
            ),
          );
        },
      );
    } else if (!kIsWeb && file != null) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.grey,
              size: 24,
            ),
          );
        },
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(
          Icons.error,
          color: Colors.grey,
          size: 24,
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Everything ready?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
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
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      const Text(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Royal Decameron Punta Sal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Av. Panamericana N, Punta Sal 24560',
          style: TextStyle(
            fontSize: 14,
            color: _subtitleColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
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
          imageBytes: _mainImageBytes,
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
                    imageBytes: _roomImageBytes,
                    onTap: () => _pickImage(ImageType.room),
                    height: 70,
                    label: 'Room Photo',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhotoUpload(
                    image: _poolImage,
                    imageBytes: _poolImageBytes,
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
    required Uint8List? imageBytes,
    required VoidCallback onTap,
    required double height,
    required String label,
  }) {
    final hasImage = image != null || imageBytes != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: hasImage ? _primaryBlue : _borderColor,
            width: hasImage ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(_borderRadius - 1),
                child: Stack(
                  children: [
                    _buildImageWidget(
                      file: image,
                      bytes: imageBytes,
                      width: double.infinity,
                      height: double.infinity,
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
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 16,
            color: _subtitleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
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
      children: [
        Expanded(
          flex: 1,
          child: _buildBackButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildFinishButton(),
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
          side: const BorderSide(color: _borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
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
      // Show image source selection dialog
      await _showImageSourceDialog(type);
    } catch (e) {
      _showErrorMessage('Failed to open image selector: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromSourceHotel(ImageSource source, ImageType type) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // For web, read as bytes
          final Uint8List imageBytes = await pickedFile.readAsBytes();
          setState(() {
            switch (type) {
              case ImageType.logo:
                _logoImageBytes = imageBytes;
                _logoImage = null;
                break;
              case ImageType.main:
                _mainImageBytes = imageBytes;
                _mainImage = null;
                break;
              case ImageType.room:
                _roomImageBytes = imageBytes;
                _roomImage = null;
                break;
              case ImageType.pool:
                _poolImageBytes = imageBytes;
                _poolImage = null;
                break;
            }
          });
        } else {
          // For mobile, use File
          final File imageFile = File(pickedFile.path);
          if (await imageFile.exists()) {
            // Try to read the file to ensure it's valid
            await imageFile.readAsBytes();
            
            setState(() {
              switch (type) {
                case ImageType.logo:
                  _logoImage = imageFile;
                  _logoImageBytes = null;
                  break;
                case ImageType.main:
                  _mainImage = imageFile;
                  _mainImageBytes = null;
                  break;
                case ImageType.room:
                  _roomImage = imageFile;
                  _roomImageBytes = null;
                  break;
                case ImageType.pool:
                  _poolImage = imageFile;
                  _poolImageBytes = null;
                  break;
              }
            });
          } else {
            _showErrorMessage('Selected image file is not accessible');
          }
        }
      }
    } on PlatformException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'photo_access_denied':
          errorMessage = 'Photo access denied. Please grant permission in device settings.';
          break;
        case 'camera_access_denied':
          errorMessage = 'Camera access denied. Please grant permission in device settings.';
          break;
        case 'invalid_image':
          errorMessage = 'The selected file is not a valid image.';
          break;
        default:
          errorMessage = 'Failed to pick image: ${e.message ?? e.code}';
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      _showErrorMessage('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<void> _showImageSourceDialog(ImageType type) async {
    return showModalBottomSheet(
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
                  _pickImageFromSourceHotel(ImageSource.gallery, type);
                },
              ),
              const SizedBox(height: 16),
              _buildImageSourceOption(
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: 'Take a new photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSourceHotel(ImageSource.camera, type);
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
                    style: TextStyle(
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
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        // Verify the file exists and is readable
        final File imageFile = File(pickedFile.path);
        if (await imageFile.exists()) {
          // Try to read the file to ensure it's valid
          await imageFile.readAsBytes();
          
          setState(() {
            switch (type) {
              case ImageType.logo:
                _logoImage = imageFile;
                break;
              case ImageType.main:
                _mainImage = imageFile;
                break;
              case ImageType.room:
                _roomImage = imageFile;
                break;
              case ImageType.pool:
                _poolImage = imageFile;
                break;
            }
          });
        } else {
          _showErrorMessage('Selected image file is not accessible');
        }
      }
    } on PlatformException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'photo_access_denied':
          errorMessage = 'Photo access denied. Please grant permission in device settings.';
          break;
        case 'camera_access_denied':
          errorMessage = 'Camera access denied. Please grant permission in device settings.';
          break;
        case 'invalid_image':
          errorMessage = 'The selected file is not a valid image.';
          break;
        default:
          errorMessage = 'Failed to pick image: ${e.message ?? e.code}';
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      _showErrorMessage('An unexpected error occurred: ${e.toString()}');
    }
  }

  // Action handlers
  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _showInfoMessage('No previous screen available');
    }
  }

  void _handleFinish() {
    final hasMainImage = _mainImage != null || _mainImageBytes != null;
    if (!hasMainImage) {
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