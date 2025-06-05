import 'package:flutter/material.dart';
import '../services/organization_service.dart';
import '../widgets/organization_card.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({Key? key}) : super(key: key);

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  final OrganizationApiService _organizationService = OrganizationApiService();

  Map<String, dynamic>? currentUser;
  bool isLoading = true;
  bool showModal = false;
  String? errorMessage;
  bool hasAuthError = false;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _checkSessionAndLoadUser();
  }

  Future<void> _checkSessionAndLoadUser() async {
    try {
      // Verificar si hay una sesión activa
      final hasSession = await _organizationService.hasActiveSession();

      if (!hasSession) {
        setState(() {
          hasAuthError = true;
          errorMessage = 'No active session found. Please login.';
          isLoading = false;
        });
        return;
      }

      // Extraer el rol del token
      userRole = await _organizationService.getUserRoleFromToken();

      await _loadCurrentUser();
    } catch (e) {
      print('Error checking session: $e');
      setState(() {
        hasAuthError = true;
        errorMessage = 'Authentication error. Please login again.';
        isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        hasAuthError = false;
      });

      print('Loading current user... Role: $userRole');

      Map<String, dynamic>? response;

      // Cargar el usuario basado en su rol
      if (userRole?.contains('GUEST') == true) {
        response = await _organizationService.getCurrentGuest();
      } else if (userRole?.contains('OWNER') == true) {
        response = await _organizationService.getCurrentOwner();
      } else {
        // Por defecto, intentar cargar como guest
        response = await _organizationService.getCurrentGuest();
      }

      if (response != null) {
        setState(() {
          currentUser = response;
          isLoading = false;
        });
        print('Current user loaded successfully: ${currentUser?['name'] ?? 'Unknown'}');
      } else {
        print('No user data received from API');
        setState(() {
          currentUser = null;
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error loading current user: $error');

      // Verificar si es un error de autenticación
      if (error.toString().contains('Unauthorized') ||
          error.toString().contains('Invalid token') ||
          error.toString().contains('Please login again')) {

        setState(() {
          hasAuthError = true;
          errorMessage = 'Your session has expired. Please login again.';
          currentUser = null;
          isLoading = false;
        });

        // Mostrar diálogo de error de autenticación
        _showAuthErrorDialog();

      } else {
        setState(() {
          currentUser = null;
          isLoading = false;
          errorMessage = 'Failed to load user information. Please try again.';
        });
      }
    }
  }

  void _showAuthErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    // Aquí debes implementar la navegación a tu pantalla de login
    // Por ejemplo:
    // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    print('Navigate to login screen');
  }

  void _showEditUserModal() {
    if (hasAuthError || currentUser == null) {
      _showAuthErrorDialog();
      return;
    }

    setState(() {
      showModal = true;
    });
  }

  void _hideEditUserModal() {
    setState(() {
      showModal = false;
    });
  }

  void _handleUpdateUser(Map<String, dynamic> updatedData) async {
    try {
      print('Updating user with data: $updatedData');

      bool success;
      if (userRole?.contains('GUEST') == true) {
        success = await _organizationService.updateCurrentGuest(updatedData);
      } else if (userRole?.contains('OWNER') == true) {
        success = await _organizationService.updateCurrentOwner(updatedData);
      } else {
        success = await _organizationService.updateCurrentGuest(updatedData);
      }

      if (success) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar los datos del usuario
        _loadCurrentUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user information'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error updating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _refreshUser() {
    if (hasAuthError) {
      _checkSessionAndLoadUser();
    } else {
      _loadCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Organization',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: _refreshUser,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 30),

              // Content
              if (hasAuthError)
                _buildErrorState()
              else
                _buildUserProfile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Royal Decameron Punta Sal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: Colors.orange.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Authentication Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage ?? 'Please login to view your profile',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (errorMessage != null && !hasAuthError) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _refreshUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No profile found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load your profile information',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Profile Card - Usando el widget GuestCard actualizado
        UserCard(
          userData: currentUser!,
          userRole: userRole,
          onTap: () => _showUserDetails(currentUser!),
        ),
      ],
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsModal(
        userData: user,
        userRole: userRole,
        onClose: () => Navigator.of(context).pop(),

      ),
    );
  }
}