import 'package:dorm_booking_app/screens/Admin/coupon_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dorm_booking_app/Widget/auth_wrapper.dart';

import 'screens/home_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/Admin/admin_home_screen.dart';          // ✅ Add this
import 'screens/Admin/admin_dormitories_screen.dart';       // ✅ (create later)
import 'screens/Admin/admin_users_screen.dart';             // ✅ (create later)
import 'screens/Admin/admin_bookings_screen.dart';          // ✅ (create later)
import 'screens/Admin/admin_payments_screen.dart';          // ✅ (create later)
import 'screens/Admin/admin_branches_screen.dart';          // ✅ (create later)
import 'screens/Admin/admin_banners_screen.dart';          // ✅ (create later)
import 'screens/Admin/admin_announcements_screen.dart';          // ✅ (create later)
import 'screens/Admin/admin_category_manage_screen.dart';          // ✅ (create later)
import 'screens/Admin/admin_apartment_screen.dart';          // ✅ (create later)
import 'screens/booking_screen.dart';          // ✅ (create later)

import 'dev/seeder.dart';
import 'dev/seed_bookings.dart';
import 'dev/payment_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await seedAppData();
  // await seedDormitories();
  // await seedBookings();
  // await seedCategories();
  // await seedDummyPayment();

  Stripe.publishableKey = "pk_test_51ROej705MoqbnIvWnwxsoSeYja2nnK32AjuWE4XOjnuPVB8SN9IHXpArlm3mw1P0Tt67wd7WeuAbizQcONnbWIx300cCs2tH9f";

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,     // ✅ cleaner look
      title: 'Dorm App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        // --- common
        '/splash': (_) => SplashScreen(),
        '/home': (_) => HomeScreen(),
        '/wishlist': (_) => WishlistScreen(),
        '/profile': (_) => ProfileScreen(),
        '/bookings': (_) => MyBookingsScreen(),
        // --- auth wrapper
        '/auth': (_) => AuthWrapper(),
        // --- admin routes ✅
        '/admin_dashboard': (_) => const AdminDashboardScreen(),
        '/admin_dormitories': (_) => const AdminDormitoriesScreen(),
        '/admin_categories_manage': (_) => const AdminCategoriesScreen(),
        '/admin_users': (_) => const AdminUsersScreen(),
        '/admin_bookings': (_) => const BookingsScreen(),
        '/admin_payments': (_) => const AdminPaymentsScreen(),
        '/admin_branches': (_) => const AdminBranchesScreen(),
        '/admin_announcements': (_) => const AdminAnnouncementsScreen(),
        '/admin_banners': (_) => const AdminBannersScreen(),
        '/admin_coupons': (_) => const CouponAdminPage(),
        '/admin_apartments': (_) => const AdminApartmentScreen(),
      },
    );
  }
}
