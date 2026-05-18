import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import '../models.dart';
import 'enrollment_screen.dart';
import 'admin_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser!;

    if (user.role == UserRole.student) {
      return const EnrollmentScreen();
    } else {
      return const AdminDashboard();
    }
  }
}
