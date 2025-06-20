import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:habitgo/providers/habit_provider.dart';
import 'package:habitgo/providers/user_provider.dart';
import 'package:habitgo/providers/level_provider.dart';
import 'package:habitgo/providers/achievement_provider.dart';
import 'package:habitgo/providers/category_provider.dart';
import 'package:habitgo/providers/recommendations_provider.dart';
import 'package:habitgo/screens/welcome_screen.dart';
import 'package:habitgo/screens/home_screen.dart';
import 'package:habitgo/screens/splash_screen.dart';

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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LevelProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationsProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProxyProvider3<UserProvider, LevelProvider, HabitProvider, AchievementProvider>(
          create: (context) => AchievementProvider(
            Provider.of<UserProvider>(context, listen: false),
            Provider.of<HabitProvider>(context, listen: false),
          ),
          update: (_, userProvider, levelProvider, habitProvider, previous) {
            final provider = previous ?? AchievementProvider(userProvider, habitProvider);
            levelProvider.setAchievementProvider(provider);
            habitProvider.setLevelProvider(levelProvider);
            habitProvider.setAchievementProvider(provider);
            return provider;
          },
        ),
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
    debugPrint('Initializing app...');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final recommendationsProvider = Provider.of<RecommendationsProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final levelProvider = Provider.of<LevelProvider>(context, listen: false);
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
    
    try {
      debugPrint('Initializing user...');
      await userProvider.initializeUser();
      debugPrint('User initialized: ${userProvider.isInitialized}');
      
      if (userProvider.isInitialized) {
        debugPrint('Loading recommendations...');
        await recommendationsProvider.loadRecommendations();
        debugPrint('Recommendations loaded');
        
        debugPrint('Connecting providers...');
        habitProvider.setCategoryProvider(categoryProvider);
        categoryProvider.setHabitProvider(habitProvider);
        habitProvider.setLevelProvider(levelProvider);
        habitProvider.setAchievementProvider(achievementProvider);
        levelProvider.setUserProvider(userProvider);
        levelProvider.setAchievementProvider(achievementProvider);
        debugPrint('Providers connected');
      }
    } catch (e, stack) {
      debugPrint('APP INIT ERROR: $e');
      debugPrint(stack.toString());
    }
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
        
        if (!userProvider.isInitialized || userProvider.user?.name == null) {
          return const WelcomeScreen();
        }
        
        return const HomeScreen();
      },
    );
  }
}
