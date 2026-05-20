import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';
import 'dashboard_view.dart';
import 'enrollment_view.dart';
import 'students_view.dart';
import 'history_view.dart';
import 'payments_view.dart';
import 'reports_view.dart';
import 'config_view.dart';
import 'my_courses_view.dart';
import 'profile_view.dart';
import 'admin_dashboard_view.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'label': 'Inicio', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
    {
      'label': 'Matrícula',
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment,
    },
    {'label': 'Cursos', 'icon': Icons.book_outlined, 'activeIcon': Icons.book},
    {
      'label': 'Historial',
      'icon': Icons.trending_up_outlined,
      'activeIcon': Icons.trending_up,
    },
    {
      'label': 'Pagos',
      'icon': Icons.credit_card_outlined,
      'activeIcon': Icons.credit_card,
    },
    {
      'label': 'Perfil',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
    },
  ];

  final List<Map<String, dynamic>> _adminMenu = [
    {
      'label': 'Inicio',
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
    },
    {
      'label': 'Estudiantes',
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
    },
    {
      'label': 'Cursos',
      'icon': Icons.layers_outlined,
      'activeIcon': Icons.layers,
    },
    {
      'label': 'Pagos',
      'icon': Icons.payments_outlined,
      'activeIcon': Icons.payments,
    },
    {
      'label': 'Reportes',
      'icon': Icons.bar_chart_outlined,
      'activeIcon': Icons.bar_chart,
    },
    {
      'label': 'Configuración',
      'icon': Icons.settings_outlined,
      'activeIcon': Icons.settings,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser!;
    final isStudent = user.role == UserRole.student;
    final menu = isStudent ? _menuItems : _adminMenu;

    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileShell(user, menu),
        desktop: _buildDesktopShell(user, menu),
      ),
    );
  }

  Widget _buildDesktopShell(User user, List<Map<String, dynamic>> menu) {
    return Row(
      children: [
        NavigationRail(
          extended: true,
          backgroundColor: const Color(0xFF0F172A),
          unselectedIconTheme: const IconThemeData(color: Color(0xFF64748B)),
          selectedIconTheme: const IconThemeData(color: AppTheme.mustardYellow),
          unselectedLabelTextStyle: const TextStyle(color: Color(0xFF64748B)),
          selectedLabelTextStyle: const TextStyle(
            color: AppTheme.mustardYellow,
            fontWeight: FontWeight.bold,
          ),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Icon(
                  Icons.school,
                  size: 40,
                  color: AppTheme.mustardYellow,
                ),
                const SizedBox(height: 12),
                const Text(
                  'UNAJ',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  user.role == UserRole.student
                      ? 'Portal Estudiante'
                      : 'Administrador',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          destinations: menu
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item['icon']),
                  selectedIcon: Icon(item['activeIcon']),
                  label: Text(item['label']),
                ),
              )
              .toList(),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white54),
                  onPressed: () => Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout(),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildTopBar(user),
              Expanded(child: _buildBody(menu[_selectedIndex]['label'], user)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileShell(User user, List<Map<String, dynamic>> menu) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.mustardYellow,
            child: Text(
              user.name[0],
              style: const TextStyle(
                color: AppTheme.navyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menu[_selectedIndex]['label'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Semestre 2025-II',
              style: TextStyle(fontSize: 11, color: AppTheme.greyText),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: _buildBody(menu[_selectedIndex]['label'], user),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: menu
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item['icon']),
                activeIcon: Icon(item['activeIcon']),
                label: item['label'],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTopBar(User user) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: const Color(0xFF1E1E1E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            user.role == UserRole.student
                ? 'Bienvenido, ${user.name.split(' ')[0]}'
                : 'Gestión Administrativa',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              const Icon(Icons.notifications_none),
              const SizedBox(width: 24),
              CircleAvatar(
                backgroundColor: AppTheme.mustardYellow,
                radius: 18,
                child: Text(
                  user.name[0],
                  style: const TextStyle(color: AppTheme.navyBlue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String label, User user) {
    switch (label) {
      case 'Inicio':
        return user.role != UserRole.student
            ? const AdminDashboardView()
            : const DashboardView();
      case 'Matrícula':
        return const EnrollmentView();
      case 'Mi Matrícula':
        return const EnrollmentView();
      case 'Cursos':
        return const MyCoursesView();
      case 'Mis Cursos':
        return const MyCoursesView();
      case 'Historial':
        return const HistoryView();
      case 'Historial Académico':
        return const HistoryView();
      case 'Pagos':
        return const PaymentsView();
      case 'Perfil':
        return const ProfileView();
      case 'Estudiantes':
        return const StudentsView();
      case 'Reportes':
        return const ReportsView();
      case 'Configuración':
        return const ConfigView();
      default:
        return const DashboardView();
    }
  }
}
