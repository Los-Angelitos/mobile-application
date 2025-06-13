import 'package:flutter/material.dart';
import 'package:sweetmanager/Commerce/views/subscription_plans.dart';
import 'package:sweetmanager/IAM/views/advice_set_up.dart';
import 'package:sweetmanager/IAM/views/authscreen.dart';
import 'package:sweetmanager/IAM/views/home.dart';
import 'package:sweetmanager/OrganizationalManagement/views/main_page.dart';
import 'package:sweetmanager/IAM/views/user_profile_info.dart';
import 'package:sweetmanager/IAM/views/user_profile_account.dart';
import 'package:sweetmanager/IAM/views/user_profile_preferences.dart';
import 'package:sweetmanager/Monitoring/views/guest_reservation.dart';
import 'package:sweetmanager/Monitoring/views/rooms_view.dart';
import 'package:sweetmanager/OrganizationalManagement/views/hotel_overview.dart';
import 'package:sweetmanager/OrganizationalManagement/views/my_organization.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';
import 'package:sweetmanager/Monitoring/views/reservations_view.dart';
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
        '/bookings': (context) => BaseLayout(
          role: 'guest',
          childScreen: const ReservationsView(),
        ),
        '/subscriptions': (context) => const SubscriptionPlans(),
        '/main': (context) => const HomeScreen(),
        '/hotel/overview': (context) => const HotelOverview(),
        '/advice': (context) => const AdviceSetupView()
        /*'/dashboard': (context) => const DashboardScreen(),
        // '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LogInScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // '/subscription': (context) => const SubscriptionPlansView(),
        '/rooms': (context) => const TableRoom(),
        '/providers': (context) => const ProvidersManagement(),
        // ignore: prefer_const_constructors
        '/supplies': (context) => InventoryManagement() ,
        '/messages': (context) => MessagesScreen(),
        // ignore: prefer_const_constructors
        '/reports': (context) => ReportList(),
        '/profiles': (context) => ProfilePage(),
        '/writemessage': (context) => WriteMessage(),
        '/alerts': (context) => const AlertsScreen(),
        '/writealert': (context) => WriteAlertScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/worker-areas-selection': (context) => const WorkerAreasSelection(),
        '/bookings': (context) => const TableBooking(),
        '/admins-management': (context) => const AdminManagement(),
        '/workers-management': (context) => const WorkerManagement(),
        '/customers-management': (context) => const CustomersManagement(),
        '/current-subscription': (context) => const CurrentSubscription(), */
      },
    );
  }
}

