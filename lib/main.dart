import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/providers/achievement_provider.dart';
import 'package:habitgo/screens/welcome_screen.dart';
import 'package:habitgo/screens/home_screen.dart';
import 'providers/recommendations_provider.dart';
import 'package:habitgo/providers/category_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // ignore: avoid_print
    debugPrint('FLUTTER ERROR: ' + details.exceptionAsString());
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized');
  } catch (e, stack) {
    debugPrint('FIREBASE INIT ERROR: $e');
    debugPrint(stack.toString());
  }
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
        ChangeNotifierProvider(create: (_) => RecommendationsProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (context) => AchievementProvider(
          context.read<UserProvider>(),
          context.read<HabitProvider>(),
        )),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'HabitGo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('Initializing user...');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final recommendationsProvider = Provider.of<RecommendationsProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    
    try {
      await userProvider.initializeUser();
      debugPrint('User initialized: \\${userProvider.isInitialized}');
    } catch (e, stack) {
      debugPrint('USER INIT ERROR: $e');
      debugPrint(stack.toString());
    }
    
    if (userProvider.isInitialized) {
      try {
        debugPrint('Loading recommendations...');
        await recommendationsProvider.loadRecommendations();
        debugPrint('Recommendations loaded');
      } catch (e, stack) {
        debugPrint('RECOMMENDATIONS LOAD ERROR: $e');
        debugPrint(stack.toString());
      }
    }

    // Connect providers
    levelProvider.setUserProvider(userProvider);
    levelProvider.setAchievementProvider(achievementProvider);
    habitProvider.setLevelProvider(levelProvider);
    habitProvider.setCategoryProvider(categoryProvider);
    habitProvider.setAchievementProvider(achievementProvider);
    categoryProvider.setHabitProvider(habitProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return userProvider.isInitialized
            ? const HomeScreen()
            : const WelcomeScreen();
      },
    );
  }
}
