import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'data/services/local_storage_service.dart';
import 'data/services/notification_service.dart';
import 'data/repositories/reminder_repository.dart';
import 'data/repositories/recharge_repository.dart';
import 'presentation/bloc/reminder/reminder_bloc.dart';
import 'presentation/bloc/recharge/recharge_bloc.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  try {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  } catch (e) {
    debugPrint("Could not solve timezone, defaulting to UTC");
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize services
  final localStorageService = LocalStorageService(prefs);
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize repositories
  final reminderRepository =
  ReminderRepository(localStorageService, notificationService);
  final rechargeRepository =
  RechargeRepository(localStorageService, notificationService);

  runApp(MyApp(
    reminderRepository: reminderRepository,
    rechargeRepository: rechargeRepository,
  ));
}

class MyApp extends StatelessWidget {
  final ReminderRepository reminderRepository;
  final RechargeRepository rechargeRepository;

  const MyApp({
    super.key,
    required this.reminderRepository,
    required this.rechargeRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          ReminderBloc(reminderRepository)..add(LoadReminders()),
        ),
        BlocProvider(
          create: (context) =>
          RechargeBloc(rechargeRepository)..add(LoadRecharges()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}