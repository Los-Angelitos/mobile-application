import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/auth_service.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';
import 'account_type_selection_screen.dart'; // Import la nueva pantalla

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _selectedLoginRole;
  
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
  
  bool _isLoginTab = true;
  bool _isLoading = false;
  final ScrollController _loginScrollController = ScrollController();
  final ScrollController _signupScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      role: '', 
      childScreen: _buildAuthContent(), 
    );
  }

  Widget _buildAuthContent() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _buildAuthScreen(),
      ),
    );
  }

  Widget _buildAuthScreen() {
    final textStyle = const TextStyle(fontSize: 14, color: Colors.grey);
    final scrollCtrl = _isLoginTab ? _loginScrollController : _signupScrollController;

    Widget _buildTab(String label, bool isLogin) {
      final active = _isLoginTab == isLogin;
      return Expanded(
        child: GestureDetector(
          onTap: () => _switchTab(isLogin),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: active
                  ? const Border(bottom: BorderSide(color: Color(0xFF1976D2), width: 2))
                  : null,
            ),
            child: _isLoading && active
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Color(0xFF1976D2)),
                    ),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active ? const Color(0xFF1976D2) : Colors.grey,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
          ),
        ),
      );
    }

    return Padding(
      key: const ValueKey('auth_screen'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('Welcome to Sweet Manager',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1976D2))),
          const SizedBox(height: 8),
          Text(
            _isLoginTab
                ? 'To use the app, please log in or register an account'
                : 'To use the application, please log in or register an organization',
            style: textStyle,
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 1))],
            ),
            child: Row(children: [_buildTab('Log in', true), _buildTab('Sign up', false)]),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Scrollbar(
                key: ValueKey(_isLoginTab),
                controller: scrollCtrl,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.only(right: 12),
                  child: _isLoginTab ? _buildLoginForm() : _buildSignUpForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchTab(bool isLogin) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      _isLoginTab = isLogin;
      _isLoading = false;
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
              RadioListTile<String>(
                title: const Text('Guest', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: const Text('I want to search and book hotel stays', style: TextStyle(fontSize: 12, color: Colors.grey)),
                value: 'guest',
                groupValue: _selectedLoginRole,
                onChanged: (value) => setState(() => _selectedLoginRole = value),
                activeColor: const Color(0xFF1976D2),
                dense: true,
              ),
              const Divider(height: 1),
              RadioListTile<String>(
                title: const Text('Owner', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: const Text('I want to manage my hotel business', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
            onPressed: _selectedLoginRole != null ? _handleLogin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Log in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Forgot password
        Center(
          child: TextButton(
            onPressed: () => print('Forgot password pressed'),
            child: const Text('Forgot my password', style: TextStyle(color: Color(0xFF1976D2), fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final role = _selectedLoginRole!;
    int roleId = 0;
    final authService = AuthService();

    if (role == 'guest') {
      roleId = 3;
    } else if (role == 'owner') {
      roleId = 1;
    } else {
      print("Unknown role: $role");
    }

    bool success = false;

    try {
      success = await authService.login(email, password, roleId);
    } catch (e, stack) {
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
      Navigator.pushNamed(context, '/organization');
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
              child: const Text('OK')
            )
          ],
        ),
      );
    }
  }

  Widget _buildSignUpForm() {
    Widget _inputField({
      required TextEditingController controller,
      required String label,
      bool obscure = false,
      bool toggleObscure = false,
      VoidCallback? onToggle,
    }) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: toggleObscure
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      );
    }

    const passwordHints = [
      'At least one character in uppercase and lowercase',
      'At least a number',
      'At least a special character',
      'At least 8 characters',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputField(controller: _fullNameController, label: 'Full name'),
        const SizedBox(height: 16),
        _inputField(controller: _signupEmailController, label: 'Email address'),
        const SizedBox(height: 16),
        _inputField(controller: _dniController, label: 'Dni'),
        const SizedBox(height: 16),
        _inputField(controller: _phoneController, label: 'Phone number'),
        const SizedBox(height: 16),
        _inputField(
          controller: _signupPasswordController,
          label: 'Password',
          obscure: _obscureSignupPassword,
          toggleObscure: true,
          onToggle: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _confirmPasswordController,
          label: 'Confirm your password',
          obscure: _obscureConfirmPassword,
          toggleObscure: true,
          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: passwordHints.map((hint) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (val) => setState(() => _acceptTerms = val ?? false),
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
                      recognizer: TapGestureRecognizer()..onTap = () => print('Terms tapped'),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: const TextStyle(
                        color: Color(0xFF1976D2),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () => print('Privacy tapped'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _acceptTerms ? _navigateToAccountTypeSelection : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _navigateToAccountTypeSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountTypeSelectionScreen(
          fullName: _fullNameController.text,
          email: _signupEmailController.text,
          dni: _dniController.text,
          phone: _phoneController.text,
          password: _signupPasswordController.text,
        ),
      ),
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