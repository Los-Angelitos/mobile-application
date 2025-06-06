import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/views/authscreen.dart';
import 'package:sweetmanager/IAM/views/home.dart';
import 'package:sweetmanager/IAM/views/user_profile_info.dart';
import 'package:sweetmanager/IAM/views/user_profile_account.dart';
import 'package:sweetmanager/IAM/views/user_profile_preferences.dart';
import 'package:sweetmanager/Monitoring/views/guest_reservation.dart';
import 'package:sweetmanager/Monitoring/views/rooms_view.dart';
import 'package:sweetmanager/Organizational-Management/views/organization_view.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';
import 'package:sweetmanager/Monitoring/views/reservations_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeView(),
        '/profile/account': (context) => AccountPage(),
        '/profile/info': (context) => ProfilePage(ownerProfile: null, guestProfile: null),
        '/profile/preferences': (context) => UserPreferencesPage(),
        '/signup': (context) => BaseLayout(
          role: 'admin',
          childScreen: const AuthScreen(),
        ),

        '/guest-reservation': (context) => const GuestReservationView(),
        '/reservations': (context) => const ReservationsView(),
        '/rooms': (context) => const RoomsView(),
        '/organization': (context) => const OrganizationPage(),




      },
    );
  }
}

