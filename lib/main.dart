import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/providers/user_provider.dart';
// import 'package:habitgo/screens/home_screen.dart';
// import 'package:habitgo/screens/main_screen.dart'; // больше не нужен
// import 'package:habitgo/screens/welcome_screen.dart'; // если не нужен onboarding
import 'package:habitgo/screens/home_screen.dart';
import 'package:habitgo/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'HabitGo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            primary: const Color(0xFF2196F3),
            secondary: const Color(0xFF03A9F4),
            tertiary: const Color(0xFF00BCD4),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: const Color(0xFF2196F3),
            unselectedItemColor: Colors.grey.shade600,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initializeUser();

    if (mounted) {
      if (userProvider.isInitialized) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
