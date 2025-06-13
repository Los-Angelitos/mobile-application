import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/auth_service.dart';

class BaseLayout extends StatelessWidget {
  final Widget childScreen; // The content of the screen
  final String? role; // User's role to define sidebar's list

  BaseLayout({required this.role, required this.childScreen, super.key});

  // final _tokenHelper = TokenHelper();

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Sweet Manager'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: FutureBuilder<List<Widget>>(
            future: _getSidebarOptions(context), // Updated to FutureBuilder
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading sidebar options'));
              } else {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: snapshot.data!,
                );
              }
            },
          ),
        ),
      ),
      body: childScreen

      /* SingleChildScrollView(
        reverse: true,
        child: childScreen,
      ) */
    );
  }

  Future<List<Widget>> _getSidebarOptions(BuildContext context) async {
    if (role == '') {
      return [
        ListTile(
          leading: const Icon(Icons.not_accessible),
          title: const Text('No current Routes for now'),
          subtitle: const Text('Login First :)'),
          onTap: () {},
        ),
      ];
    }

    if (role == 'ROLE_OWNER') {
      return [
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Organization Members'),
          onTap: () {
            Navigator.pushNamed(context, '/organization');
          },
        ),
        ListTile(
          leading: const Icon(Icons.support_outlined),
          title: const Text('Providers Management'),
          onTap: () {
            Navigator.pushNamed(context, '/providers');
          },
        ),
        ListTile(
          leading: const Icon(Icons.room),
          title: const Text('Rooms Management'),
          onTap: () {
            Navigator.pushNamed(context, '/rooms');
          },
        ),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text('Reservations'),
          onTap: () {
            Navigator.pushNamed(context, '/reservations');
          },
        ),
        ListTile(
          leading: const Icon(Icons.subscriptions),
          title: const Text('Subscriptions'),
          onTap: () {
            Navigator.pushNamed(context, '/subscriptions');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile Info'),
          onTap: () {
            Navigator.pushNamed(context, '/profile/info');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile Account'),
          onTap: () {
            Navigator.pushNamed(context, '/profile/account');
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sign Out'),
          onTap: () {
            _authService.logout();
              
            Navigator.pushNamed(context, '/home');
          },
        ),
      ];
    } else if (role == 'ROLE_GUEST') {
      return [
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            Navigator.pushNamed(context, '/main');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('My Reservations'),
          onTap: () {
            Navigator.pushNamed(context, '/guest-reservation');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile Preferences'),
          onTap: () {
            Navigator.pushNamed(context, '/profile/preferences');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile Info'),
          onTap: () {
            Navigator.pushNamed(context, '/profile/info');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile Account'),
          onTap: () {
            Navigator.pushNamed(context, '/profile/account');
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sign Out'),
          onTap: () {
            _authService.logout();
              
            Navigator.pushNamed(context, '/home');
          },
        ),
      ];
    } else {
      return [
        const ListTile(
          title: Text('No role'),
          subtitle: Text('Check code'),
        ),
      ];
    }
  }
}