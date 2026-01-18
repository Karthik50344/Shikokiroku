import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shikokiroku/presentation/views/screens/home_screen.dart';
import '../../domain/models/reminder.dart';
import '../views/screens/reminders_screen.dart';
import '../views/screens/recharge_screen.dart';
import '../views/screens/add_reminder_screen.dart';
import '../views/screens/add_recharge_screen.dart';
import '../views/screens/recharge_history_screen.dart';
import '../views/screens/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String reminders = '/reminders';
  static const String recharge = '/recharge';
  static const String addReminder = '/add-reminder';
  static const String editReminder = '/edit-reminder';
  static const String addRecharge = '/add-recharge';
  static const String editRecharge = '/edit-recharge';
  static const String rechargeHistory = '/recharge-history';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: reminders,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: recharge,
        builder: (context, state) => const RechargeScreen(),
      ),
      GoRoute(
        path: addReminder,
        builder: (context, state) => const AddReminderScreen(),
      ),
      GoRoute(
        path: editReminder,
        builder: (context, state) {
          final reminder = state.extra as Reminder;
          return AddReminderScreen(reminder: reminder);
        },
      ),
      GoRoute(
        path: addRecharge,
        builder: (context, state) => const AddRechargeScreen(),
      ),
      GoRoute(
        path: editRecharge,
        builder: (context, state) {
          final recharge = state.extra as MobileRecharge;
          return AddRechargeScreen(recharge: recharge);
        },
      ),
      GoRoute(
        path: rechargeHistory,
        builder: (context, state) => const RechargeHistoryScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}