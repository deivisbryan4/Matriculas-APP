import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'providers.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
      ],
      child: const UnajMatriculaApp(),
    ),
  );
}

class UnajMatriculaApp extends StatelessWidget {
  const UnajMatriculaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNAJ Matrícula',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.currentUser == null) {
            return const LoginScreen();
          }
          return const DashboardScreen();
        },
      ),
    );
  }
}
