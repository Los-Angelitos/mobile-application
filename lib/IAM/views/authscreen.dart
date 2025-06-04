import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Estado de la vista actual
  bool _showAccountTypeSelection = false;
  
  // Controladores para Login
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _selectedLoginRole; // Nuevo: para selección de rol en login
  
  // Controladores para Sign Up
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureSignupPassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  
  // Variables para Account Type Selection
  String? _selectedAccountType;
  
  bool _isLoginTab = true;
  bool _isLoading = false;

  // Controladores de scroll para las scrollbars
  final ScrollController _loginScrollController = ScrollController();
  final ScrollController _signupScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _showAccountTypeSelection ? const Color(0xFF1976D2) : Colors.grey[50],
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: _showAccountTypeSelection 
              ? _buildAccountTypeScreen() 
              : _buildAuthScreen(),
        ),
      ),
    );
  }

  Widget _buildAuthScreen() {
    return Padding(
      key: const ValueKey('auth_screen'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Título
          const Text(
            'Welcome to Sweet Manager',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLoginTab 
                ? 'To use the app, please log in or register an account'
                : 'To use the application, please log in or register an organization',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _isLoginTab ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: _isLoginTab 
                            ? const Border(
                                bottom: BorderSide(
                                  color: Color(0xFF1976D2),
                                  width: 2,
                                ),
                              )
                            : null,
                      ),
                      child: _isLoading && _isLoginTab
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                              ),
                            )
                          : Text(
                              'Log in',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isLoginTab ? const Color(0xFF1976D2) : Colors.grey,
                                fontWeight: _isLoginTab ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: !_isLoginTab ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: !_isLoginTab 
                            ? const Border(
                                bottom: BorderSide(
                                  color: Color(0xFF1976D2),
                                  width: 2,
                                ),
                              )
                            : null,
                      ),
                      child: _isLoading && !_isLoginTab
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                              ),
                            )
                          : Text(
                              'Sign up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_isLoginTab ? const Color(0xFF1976D2) : Colors.grey,
                                fontWeight: !_isLoginTab ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Contenido con scroll y scrollbar
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Scrollbar(
                key: ValueKey(_isLoginTab),
                controller: _isLoginTab ? _loginScrollController : _signupScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: SingleChildScrollView(
                  controller: _isLoginTab ? _loginScrollController : _signupScrollController,
                  padding: const EdgeInsets.only(right: 12), // Espacio para la scrollbar
                  child: _isLoginTab ? _buildLoginForm() : _buildSignUpForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeScreen() {
    return Column(
      key: const ValueKey('account_type_screen'),
      children: [
        // Contenido principal en blanco
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Título "A last step!"
                  const Text(
                    'A last step!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtítulo
                  const Text(
                    'At SweetManager we care about providing the best experience possible.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pregunta
                  const Text(
                    'Who this account will be for?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Opción Guest
                  GestureDetector(
                    onTap: () => setState(() => _selectedAccountType = 'guest'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAccountType == 'guest' 
                              ? const Color(0xFF1976D2) 
                              : Colors.grey[300]!,
                          width: _selectedAccountType == 'guest' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'guest',
                            groupValue: _selectedAccountType,
                            onChanged: (value) => setState(() => _selectedAccountType = value),
                            activeColor: const Color(0xFF1976D2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Guest',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'I will use my account to search, book a stay within a hotel.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Opción Chief owner
                  GestureDetector(
                    onTap: () => setState(() => _selectedAccountType = 'chief_owner'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAccountType == 'chief_owner' 
                              ? const Color(0xFF1976D2) 
                              : Colors.grey[300]!,
                          width: _selectedAccountType == 'chief_owner' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'chief_owner',
                            groupValue: _selectedAccountType,
                            onChanged: (value) => setState(() => _selectedAccountType = value),
                            activeColor: const Color(0xFF1976D2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Chief owner',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'I will be in charge of all the activities inside my hotel and I will manage what is necessary for my clients.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Botón Sign up
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAccountType != null
                          ? () async {
                              final fullName = _fullNameController.text.trim();
                              print("Full name: $fullName");

                              final nameParts = fullName.split(' ');
                              final name = nameParts.isNotEmpty ? nameParts[0] : '';
                              final surname = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                              print("Parsed name: $name, surname: $surname");

                              final email = _signupEmailController.text;
                              final phone = _phoneController.text;
                              final password = _signupPasswordController.text;
                              final accountType = _selectedAccountType!;
                              final dni = _dniController.text.trim();
                              final id = int.tryParse(dni);
                              final photoURL = ''; // Placeholder for photo URL

                              print("Email: $email, Phone: $phone, AccountType: $accountType, DNI: $dni");

                              if (id == null) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text("Error"),
                                    content: Text("El DNI debe ser un número válido."),
                                  ),
                                );
                                return;
                              }

                              final authService = AuthService();
                              bool success = false;

                              try {
                                if (accountType == 'guest') {
                                  print("Calling signupGuest...");
                                  success = await authService.signupGuest(
                                    id,
                                    name,
                                    surname,
                                    phone,
                                    email,
                                    password,
                                    photoURL,
                                  );
                                  print("signupGuest result: $success");
                                } else if (accountType == 'chief_owner') {
                                  print("Calling signupOwner...");
                                  success = await authService.signupOwner(
                                    id,
                                    name,
                                    surname,
                                    phone,
                                    email,
                                    password,
                                    photoURL
                                  );
                                  print("signupOwner result: $success");
                                }
                              } catch (e, stack) {
                                print("Exception during signup: $e");
                                print("Stack trace: $stack");
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: Text('Ocurrió un error inesperado: $e'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              if (success) {
                                print("Signup successful, navigating to /home...");
                                Navigator.pushNamed(context, '/home');
                              } else {
                                print("Signup failed (success = false)");
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text('Error al registrar usuario'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _switchTab(bool isLogin) async {
    if (_isLoading) return; // Prevenir múltiples clics durante la carga
    
    setState(() {
      _isLoading = true;
    });
    
    // Simular una pequeña carga para hacer la transición más visible
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      _isLoginTab = isLogin;
      _isLoading = false;
      // Resetear selección de rol cuando se cambia de tab
      _selectedLoginRole = null;
    });
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Campo Email
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Campo Password
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Remember me checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) => setState(() => _rememberMe = value ?? false),
              activeColor: const Color(0xFF1976D2),
            ),
            const Text(
              'Remember me',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Selección de rol
        const Text(
          'Select your role:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Radio buttons para rol
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Opción Guest
              RadioListTile<String>(
                title: const Text(
                  'Guest',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'I want to search and book hotel stays',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                value: 'guest',
                groupValue: _selectedLoginRole,
                onChanged: (value) => setState(() => _selectedLoginRole = value),
                activeColor: const Color(0xFF1976D2),
                dense: true,
              ),
              const Divider(height: 1),
              // Opción Owner
              RadioListTile<String>(
                title: const Text(
                  'Owner',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'I want to manage my hotel business',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                value: 'owner',
                groupValue: _selectedLoginRole,
                onChanged: (value) => setState(() => _selectedLoginRole = value),
                activeColor: const Color(0xFF1976D2),
                dense: true,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Botón Log in
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedLoginRole != null
    ? () async {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final role = _selectedLoginRole!;
        int roleId = 0;

        print("Login attempt:");
        print("Email: $email");
        print("Password: $password"); // ⚠️ Solo para debug, quita esto en producción
        print("Selected role: $role");

        final authService = AuthService();

        if (role == 'guest') {
          roleId = 3;
          print("Mapped role to ID: $roleId (guest)");
        } else if (role == 'owner') {
          roleId = 1;
          print("Mapped role to ID: $roleId (owner)");
        } else {
          print("Unknown role: $role");
        }

        bool success = false;

        try {
          print("Calling login API...");
          success = await authService.login(email, password, roleId);
          print("Login result: $success");
        } catch (e, stack) {
          print("Exception during login: $e");
          print("Stack trace: $stack");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Ocurrió un error al intentar iniciar sesión: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        if (success) {
          print("Login successful, navigating to /home");
          Navigator.pushNamed(context, '/home');
        } else {
          print("Login failed: invalid credentials or server error");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Credenciales incorrectas'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                )
              ],
            ),
          );
        }
      }
    : null,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Log in',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Forgot password
        Center(
          child: TextButton(
            onPressed: () {
              print('Forgot password pressed');
            },
            child: const Text(
              'Forgot my password',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo Full name
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full name',
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Campo Email address
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _signupEmailController,
            decoration: const InputDecoration(
              labelText: 'Email address',
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        // Campo Dni
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _dniController,
            decoration: const InputDecoration(
              labelText: 'Dni',
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Campo Phone number
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Campo Password
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _signupPasswordController,
            obscureText: _obscureSignupPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureSignupPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Campo Confirm your password
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm your password',
              labelStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Requisitos de contraseña
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 6, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'At least one character in uppercase and lowercase',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 6, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'At least a number',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 6, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'At least a special character',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.circle, size: 6, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'At least 8 characters',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Terms and conditions checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
              activeColor: const Color(0xFF1976D2),
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  children: [
                    const TextSpan(text: "I've read and accept the "),
                    TextSpan(
                      text: 'Terms and Conditions',
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Terms and Conditions tapped');
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print('Privacy policy tapped');
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Botón Continue
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _acceptTerms
                ? () {
                    // Debug prints
                    print('SignUp - Full name: ${_fullNameController.text}');
                    print('SignUp - Email: ${_signupEmailController.text}');
                    print('SignUp - DNI: ${_dniController.text}');
                    print('SignUp - Phone: ${_phoneController.text}');
                    print('SignUp - Password: ${_signupPasswordController.text}');
                    print('SignUp - Confirm Password: ${_confirmPasswordController.text}');

                    // Cambiar a la vista de selección de tipo de cuenta
                    setState(() {
                      _showAccountTypeSelection = true;
                    });
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _signupEmailController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    _loginScrollController.dispose();
    _signupScrollController.dispose();
    super.dispose();
  }
}