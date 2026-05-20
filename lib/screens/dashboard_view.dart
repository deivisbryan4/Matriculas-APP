import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser!;
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.role == UserRole.student)
            _buildStudentDashboard(context, user, isMobile)
          else
            _buildAdminDashboard(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildStudentDashboard(
    BuildContext context,
    User user,
    bool isMobile,
  ) {
    final system = Provider.of<SystemProvider>(context);
    final studentVouchers = system.vouchers.where((v) => v.studentDni == user.dni || v.studentCode == user.studentCode).toList();
    studentVouchers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latestVoucher = studentVouchers.isNotEmpty ? studentVouchers.first : null;

    final String paymentStatusText;
    final Color paymentStatusColor;
    if (latestVoucher == null) {
      paymentStatusText = 'Sin Registro';
      paymentStatusColor = Colors.grey;
    } else {
      switch (latestVoucher.statusStr.toUpperCase()) {
        case 'VALIDADO':
          paymentStatusText = 'Validado';
          paymentStatusColor = AppTheme.emeraldGreen;
          break;
        case 'RECHAZADO':
          paymentStatusText = 'Rechazado';
          paymentStatusColor = AppTheme.roseRed;
          break;
        default:
          paymentStatusText = 'Pendiente';
          paymentStatusColor = AppTheme.mustardYellow;
      }
    }

    final String paymentAmountText = latestVoucher != null
        ? 'S/. ${latestVoucher.amount.toStringAsFixed(2)}'
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner de Matrícula
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2B6B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D3E8C)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mustardYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: AppTheme.navyBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matrícula abierta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 15 : 18,
                      ),
                    ),
                    Text(
                      'Cierra el 28 Feb',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(60, 36),
                ),
                child: const Text('Ir ahora', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Grid de KPIs
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 1.3 : 1.4,
          children: [
            _buildSmallStatCard(
              'Créditos',
              '${user.approvedCredits}',
              'de ${user.totalCredits}',
              Icons.book_outlined,
              AppTheme.navyBlue,
              isMobile,
            ),
            _buildSmallStatCard(
              'Promedio',
              user.gpa.toStringAsFixed(1),
              _statusLabel(user.status),
              Icons.workspace_premium_outlined,
              AppTheme.mustardYellow,
              isMobile,
            ),
            _buildSmallStatCard(
              'Aprobados',
              '${user.approvedCourses}',
              'de ${user.totalCourses}',
              Icons.check_circle_outline,
              Colors.grey,
              isMobile,
            ),
            _buildSmallStatCard(
              'Pago',
              paymentStatusText,
              paymentAmountText,
              Icons.credit_card,
              paymentStatusColor,
              isMobile,
              valueColor: paymentStatusColor,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Avance Académico
        Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avance académico',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildProgressBar(
                  'Créditos',
                  user.approvedCredits,
                  user.totalCredits,
                  AppTheme.navyBlue,
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  'Cursos aprobados',
                  user.approvedCourses,
                  user.totalCourses,
                  AppTheme.mustardYellow,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Accesos rápidos (Mobile only)
        if (isMobile) ...[
          const Text(
            'Accesos rápidos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildQuickAccess(
                Icons.assignment_outlined,
                'Mi matrícula',
                const Color(0xFF1E3A8A),
              ),
              _buildQuickAccess(
                Icons.book_outlined,
                'Mis cursos',
                const Color(0xFF92400E),
              ),
              _buildQuickAccess(
                Icons.trending_up_outlined,
                'Historial',
                const Color(0xFF065F46),
              ),
              _buildQuickAccess(
                Icons.credit_card_outlined,
                'Pagos',
                const Color(0xFF991B1B),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAdminDashboard(BuildContext context, bool isMobile) {
    return const Center(child: Text('Dashboard Administrativo'));
  }

  Widget _buildSmallStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
    bool isMobile, {
    Color? valueColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.6), size: 18),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w900,
                color: valueColor ?? Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int total, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
            ),
            Text(
              '$current / $total',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: current / total,
          backgroundColor: const Color(0xFF2D2D2D),
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D2D)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.whiteText,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(StudentStatus status) {
    return switch (status) {
      StudentStatus.regular => 'Regular',
      StudentStatus.observado => 'Observado',
      StudentStatus.inhabilitado => 'Inhabilitado',
    };
  }
}
