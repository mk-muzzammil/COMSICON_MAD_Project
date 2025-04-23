import 'package:comsicon/firebase_options.dart';
import 'package:comsicon/pages/authenticationPage.dart';
import 'package:comsicon/pages/courseDetails.dart';
import 'package:comsicon/pages/homePage.dart';
import 'package:comsicon/pages/loginPage.dart';
import 'package:comsicon/pages/profileSetupPage.dart';
import 'package:comsicon/pages/signupPage.dart';
import 'package:comsicon/pages/starterPage.dart';
import 'package:comsicon/pages/studentDashboard.dart';
import 'package:comsicon/pages/tutorDashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import your pages here
import 'package:comsicon/pages/splashScreen.dart';
// Add your other page imports as needed, for example:
// import 'package:comsicon/pages/homePage.dart';
// import 'package:comsicon/pages/authPage.dart';
// etc.

// Import your theme files (you'll need to create these)
import 'package:comsicon/theme/app_theme.dart' show lightTheme, darkTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If you need notifications, you can initialize them here
  // Similar to your previous project with AwesomeNotifications

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Tracks whether the app should be in dark mode or light mode
  bool isDarkMode =
      true; // Default: Dark. Set to false if you want Light by default

  /// Method that toggles the theme; called from SettingsScreen
  void toggleTheme(bool enableDark) {
    setState(() {
      isDarkMode = enableDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Comsicon',

      // Provide both light and dark themes
      theme: lightTheme,
      darkTheme: darkTheme,

      // Dynamically pick which theme to use
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // Define initial route
      initialRoute: '/splash',

      // Define all routes
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/starterPage': (context) => const edTech(), // Your starter page
        '/auth': (context) => AuthenticationPage(),
        '/signUp': (context) => const SignUpScreen(), // Your signup page
        '/login': (context) => const LoginScreen(), // Your login page
        '/profileSetup':
            (context) => const ProfileSetupScreen(), // Your profile setup page
        // Add all your other routes here, for example:
        '/home': (context) => HomePage(),
        '/tutorDashboard': (context) => TutorDashboard(),
        '/studentDashboard': (context) => StudentDashboard(),
        // '/login': (context) => LoginPage(),
        // '/signup': (context) => SignupPage(),
        // '/settings': (context) => SettingsPage(
        //   isDarkMode: isDarkMode,
        //   onDarkModeToggled: toggleTheme,
        // ),
        // Add more routes as needed
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/courseDetails') {
          // Extract the courseId from arguments
          final String courseId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(courseId: courseId),
          );
        }
        return null;
      },
    );
  }
}
