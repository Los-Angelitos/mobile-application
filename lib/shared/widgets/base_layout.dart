import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/auth_service.dart';
import 'package:sweetmanager/shared/infrastructure/misc/token_helper.dart';

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
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
        ListTile(
          leading: const Icon(Icons.message),
          title: const Text('Notifications'),
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        ListTile(
          leading: const Icon(Icons.subscriptions),
          title: const Text('Current Subscription'),
          onTap: () {
            Navigator.pushNamed(context, '/current-subscription');
          },
        ),
        ListTile(
          leading: const Icon(Icons.emoji_transportation),
          title: const Text('Suppliers Management'),
          onTap: () {
            Navigator.pushNamed(context, '/providers');
          },
        ),
        ListTile(
          leading: const Icon(Icons.food_bank),
          title: const Text('Supplies Management'),
          onTap: () {
            Navigator.pushNamed(context, '/supplies');
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
          leading: const Icon(Icons.admin_panel_settings),
          title: const Text('Admins Management'),
          onTap: () {
            Navigator.pushNamed(context, '/admins-management');
          },
        ),
        ListTile(
          leading: const Icon(Icons.work),
          title: const Text('Workers Management'),
          onTap: () {
            Navigator.pushNamed(context, '/workers-management');
          },
        ),
        ListTile(
          leading: const Icon(Icons.back_hand),
          title: const Text('Customers Management'),
          onTap: () {
            Navigator.pushNamed(context, '/customers-management');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profiles'),
          onTap: () {
            Navigator.pushNamed(context, '/profiles');
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
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
        ListTile(
          leading: const Icon(Icons.emoji_transportation),
          title: const Text('Suppliers Management'),
          onTap: () {
            Navigator.pushNamed(context, '/providers');
          },
        ),
        ListTile(
          leading: const Icon(Icons.food_bank),
          title: const Text('Supplies Management'),
          onTap: () {
            Navigator.pushNamed(context, '/supplies');
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
          leading: const Icon(Icons.message),
          title: const Text('Messages'),
          onTap: () {
            Navigator.pushNamed(context, '/messages');
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Reports'),
          onTap: () {
            Navigator.pushNamed(context, '/reports');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profiles'),
          onTap: () {
            Navigator.pushNamed(context, '/profiles');
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