import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/views/user_profile_info.dart';
import 'package:sweetmanager/IAM/views/user_profile_preferences.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void navigateTo(BuildContext context, String routeName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderPage(title: routeName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B61B6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=3'), // imagen ejemplo
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      const Text(
                        'Arian Rodriguez',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Guest',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  buildListTile(
                    context,
                    icon: Icons.person,
                    text: 'Personal Information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ProfilePage()),
                      );
                    },
                    isSelected: true,
                  ),
                  buildListTile(context,
                      icon: Icons.tune,
                      text: 'My preferences as a Guest', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserPreferencesPage()),
                    );
                  }),
                  buildListTile(
                    context,
                    icon: Icons.schedule,
                    text: 'My Reservations',
                    onTap: () => navigateTo(context, 'My Reservations'),
                  ),
                  buildListTile(
                    context,
                    icon: Icons.logout,
                    text: 'Logout',
                    onTap: () => Navigator.pop(context),
                    textColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                  const Divider(height: 1),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('SweetManager',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black54),
      title: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? Colors.blue[50] : null,
      onTap: onTap,
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page')),
    );
  }
}
