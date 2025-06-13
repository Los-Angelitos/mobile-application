import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/guest.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/owner.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/user_service.dart';
import 'package:sweetmanager/IAM/views/user_profile_info.dart';
import 'package:sweetmanager/IAM/views/user_profile_preferences.dart';
import 'package:sweetmanager/shared/infrastructure/misc/token_helper.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key});
  final UserService userService = UserService();
  Guest? guestProfile;
  Owner? ownerProfile;
  int? roleId;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    getRoleId();
  }

  String get userFullName {
    return widget.ownerProfile?.name ??
        widget.guestProfile?.name ??
        'Unknown User';
  }

  String get userRole {
    return widget.ownerProfile != null ? 'Owner' : 'Guest';
  }

  String get userPhotoURL {
    return widget.ownerProfile?.photoURL ??
        widget.guestProfile?.photoURL ??
        'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg'; // Default image
  }

  Future<void> fetchUserProfile() async {
    try {
      widget.guestProfile = await widget.userService.getGuestProfile();
      widget.ownerProfile = await widget.userService.getOwnerProfile();
      setState(() {});

      print(
          'User profile fetched successfully: ${widget.guestProfile?.toJson()}');
      print(
          'Owner profile fetched successfully: ${widget.ownerProfile?.toJson()}');
    } catch (e) {
      print('Error fetching user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> getRoleId() async {
    try {
      final roleId = await TokenHelper().getRole();
      if (roleId == null) {
        throw Exception('Role ID not found in token');
      }

      print('Role ID: $roleId');
      widget.roleId = roleId == "ROLE_OWNER" ? 1 : 3;
      setState(() {});
      print('Role ID set to: ${widget.roleId}');
    } catch (e) {
      print('Error fetching role ID: $e');
    }
  }

  void navigateTo(BuildContext context, String routeName) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaceholderPage(title: routeName)),
    );
  }

  Future<void> logOut() async {
    final storage = const FlutterSecureStorage();
    await storage.delete(key: 'token');
    await storage.delete(key: 'roleId');
    await storage.delete(key: 'id');
    await storage.delete(key: 'userId');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRoleId(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(child: CircularProgressIndicator(),);
        }

        if (snapshot.hasData) 
        {
            int? role = widget.roleId!;

            if (role == 1) {
              return BaseLayout(role: "ROLE_OWNER", childScreen: getContentView());
            }
            else{
              return BaseLayout(role: "ROLE_GUEST", childScreen: getContentView());
            }
        }

        return const Center(child: Text('Unable to get information', textAlign: TextAlign.center,));
      }
    );
  }

  Widget getContentView() {
    return Center(
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
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2B61B6),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(userPhotoURL.isNotEmpty
                          ? userPhotoURL
                          : 'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg')),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Text(
                        userFullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userRole,
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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(
                            ownerProfile: widget.ownerProfile,
                            guestProfile: widget.guestProfile,
                            userType: userRole,
                          ),
                        ),
                      );
                      fetchUserProfile(); // Refresh profile data
                    },
                    isSelected: true,
                  ),
                  if (widget.roleId == 3)
                    buildListTile(
                      context,
                      icon: Icons.tune,
                      text: 'My preferences as a Guest',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => UserPreferencesPage()),
                        );
                      },
                    ),
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
                    onTap: () => logOut(),
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
