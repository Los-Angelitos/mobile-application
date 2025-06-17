import 'package:flutter/material.dart';
import 'package:sweetmanager/Commerce/views/subscription_plans.dart';
import 'package:sweetmanager/IAM/views/advice_set_up.dart';
import 'package:sweetmanager/IAM/views/authscreen.dart';
import 'package:sweetmanager/IAM/views/home.dart';
import 'package:sweetmanager/OrganizationalManagement/views/hotel_register.dart';
import 'package:sweetmanager/OrganizationalManagement/views/hotel_setup.dart';
import 'package:sweetmanager/OrganizationalManagement/views/hotel_setup_review.dart';
import 'package:sweetmanager/OrganizationalManagement/views/main_page.dart';
import 'package:sweetmanager/IAM/views/user_profile_info.dart';
import 'package:sweetmanager/IAM/views/user_profile_account.dart';
import 'package:sweetmanager/IAM/views/user_profile_preferences.dart';
import 'package:sweetmanager/Monitoring/views/guest_reservation.dart';
import 'package:sweetmanager/Monitoring/views/rooms_view.dart';
import 'package:sweetmanager/OrganizationalManagement/views/hotel_overview.dart';
import 'package:sweetmanager/Monitoring/views/reservations_view.dart';
import 'package:sweetmanager/OrganizationalManagement/views/my_organization.dart';
import 'Inventory/views/providers_view.dart';

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
        '/guest-reservation': (context) => const GuestReservationView(),
        '/reservations': (context) => const ReservationsView(),
        '/rooms': (context) => const RoomsView(),
        '/organization': (context) => const OrganizationPage(),
        '/signup': (context) => const AuthScreen(),
        '/providers': (context) => const ProvidersView(),
        '/subscriptions': (context) => const SubscriptionPlans(),
        '/main': (context) => const HomeScreen(),
        '/hotel/overview': (context) => const HotelOverview(),
        '/advice': (context) => const AdviceSetupView(),
        '/hotel/register': (context) => const HotelRegistrationScreen(),
        '/hotel/set-up': (context) => const HotelSetupScreen(),
        '/hotel/set-up/review': (context) => const HotelSetupReviewScreen()
      },
    );
  }
}

