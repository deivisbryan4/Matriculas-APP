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
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.role == UserRole.student) _buildStudentDashboard(context, user, isMobile)
          else _buildAdminDashboard(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildStudentDashboard(BuildContext context, User user, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner de Matrícula
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2B6B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2D3E8C)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.mustardYellow, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.assignment, color: AppTheme.navyBlue, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Matrícula abierta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Cierra el 28 Feb 2025', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(horizontal: 20)),
                child: const Text('Ir ahora', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Grid de KPIs
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildSmallStatCard('Créditos', '87', 'de 220', Icons.book_outlined, AppTheme.navyBlue),
            _buildSmallStatCard('Promedio', '13.4', 'Estado: Regular', Icons.workspace_premium_outlined, AppTheme.mustardYellow),
            _buildSmallStatCard('Aprobados', '22', 'de 40 cursos', Icons.check_circle_outline, Colors.grey),
            _buildSmallStatCard('Pago', 'Validado', 'S/. 350.00', Icons.credit_card, AppTheme.emeraldGreen),
          ],
        ),
        const SizedBox(height: 24),

        // Avance Académico
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Avance académico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildProgressBar('Créditos', 87, 220, AppTheme.navyBlue),
                const SizedBox(height: 16),
                _buildProgressBar('Cursos aprobados', 22, 40, AppTheme.mustardYellow),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Accesos rápidos (Mobile only)
        if (isMobile) ...[
          const Text('Accesos rápidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildQuickAccess(Icons.assignment_outlined, 'Mi matrícula', const Color(0xFF1E3A8A)),
              _buildQuickAccess(Icons.book_outlined, 'Mis cursos', const Color(0xFF92400E)),
              _buildQuickAccess(Icons.trending_up_outlined, 'Historial', const Color(0xFF065F46)),
              _buildQuickAccess(Icons.credit_card_outlined, 'Pagos', const Color(0xFF991B1B)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAdminDashboard(BuildContext context, bool isMobile) {
    return const Center(child: Text('Dashboard Administrativo'));
  }

  Widget _buildSmallStatCard(String title, String value, String sub, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.5), size: 20),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: (value == 'Validado' ? AppTheme.emeraldGreen : Colors.white))),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
            Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.greyText)),
            Text('$current / $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.greyText)),
        ],
      ),
    );
  }
}
