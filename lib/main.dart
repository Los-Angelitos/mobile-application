import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/views/authscreen.dart';
import 'package:sweetmanager/IAM/views/home.dart';
import 'package:sweetmanager/IAM/views/user_profile_info.dart';
import 'package:sweetmanager/IAM/views/user_profile_account.dart';
import 'package:sweetmanager/IAM/views/user_profile_preferences.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';
import 'package:sweetmanager/Monitoring/views/reservations_view.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyHomePage());
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sweet Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeView(),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeView(), // the default app's entry point
        '/profile/account': (context) => AccountPage(),
        '/profile/info': (context) => ProfilePage(ownerProfile: null, guestProfile: null),
        '/profile/preferences': (context) => UserPreferencesPage(),
        '/signup': (context) =>  BaseLayout(
          role: 'admin',
          childScreen: const AuthScreen(),
        ),
        '/bookings': (context) => BaseLayout(
          role: 'guest',
          childScreen: const ReservationsView(),
        )
        /*'/dashboard': (context) => const DashboardScreen(),
        / '/login': (context) => const LogInScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/home': (context) => const HomeView(), // the default app's entry point 
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