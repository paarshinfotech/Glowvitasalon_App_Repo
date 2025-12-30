import 'package:flutter/material.dart';
import 'package:glow_vita_salon/controller/auth_controller.dart';
import 'package:glow_vita_salon/routes/app_routes.dart';
import 'package:glow_vita_salon/view/home.dart';
import 'package:glow_vita_salon/view/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glow Vita Salon',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black87),
        )
      ),
      home: const AuthGate(), // Use a gateway to check auth status
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// A widget that decides which screen to show based on the login state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthController.isLoggedIn(),
      builder: (context, snapshot) {
        // While waiting for the future to complete, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If we have data, check if the user is logged in.
        if (snapshot.hasData && snapshot.data == true) {
          return const Home();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}


