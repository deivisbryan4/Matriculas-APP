import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminHeader(isMobile),
          const SizedBox(height: 24),
          _buildKPIs(isMobile),
          const SizedBox(height: 32),
          ResponsiveLayout(
            mobile: Column(
              children: [
                _buildRecentPayments(system),
                const SizedBox(height: 24),
                _buildCareerStats(),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildRecentPayments(system)),
                const SizedBox(width: 32),
                Expanded(flex: 2, child: _buildCareerStats()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Panel de Control', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        Text('Gestión Global UNAJ - Periodo 2025-I', style: TextStyle(color: AppTheme.greyText, fontSize: isMobile ? 12 : 14)),
      ],
    );
  }

  Widget _buildKPIs(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.1 : 1.3,
      children: [
        _buildAdminStatCard('Matriculados', '1,248', '+12% vs sem. ant.', Icons.group_outlined, AppTheme.emeraldGreen),
        _buildAdminStatCard('Pagos Pend.', '87', 'Por validar', Icons.history_toggle_off, AppTheme.mustardYellow),
        _buildAdminStatCard('Prom. Créditos', '18.4', 'Semestre actual', Icons.analytics_outlined, AppTheme.navyBlue),
        _buildAdminStatCard('Inhabilitados', '34', 'Triple desaprob.', Icons.gpp_bad_outlined, AppTheme.roseRed),
      ],
    );
  }

  Widget _buildAdminStatCard(String title, String value, String sub, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.7), size: 22),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            Text(sub, style: TextStyle(color: color.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments(SystemProvider system) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 18, color: AppTheme.mustardYellow),
                    SizedBox(width: 10),
                    Text('Pagos recientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                TextButton(onPressed: () {}, child: const Text('Ver todos', style: TextStyle(fontSize: 12, color: AppTheme.mustardYellow))),
              ],
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const Divider(color: AppTheme.plomoBorde, height: 32),
              itemBuilder: (context, index) {
                final v = system.vouchers[index];
                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0F172A),
                      child: Text(v.studentName[0], style: const TextStyle(color: AppTheme.mustardYellow, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Cód: ${v.studentCode} · Op. #${v.operationNumber}', style: const TextStyle(color: AppTheme.greyText, fontSize: 11)),
                        ],
                      ),
                    ),
                    _buildStatusBadge(v.status),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    String text;
    switch (status) {
      case PaymentStatus.pendiente: color = AppTheme.amberOrange; text = 'Pendiente'; break;
      case PaymentStatus.validado: color = AppTheme.emeraldGreen; text = 'Validado'; break;
      case PaymentStatus.rechazado: color = AppTheme.roseRed; text = 'Rechazado'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildCareerStats() {
    final careers = [
      {'name': 'Ing. Sistemas', 'count': 342, 'percent': 0.85},
      {'name': 'Contabilidad', 'count': 289, 'percent': 0.72},
      {'name': 'Administ.', 'count': 261, 'percent': 0.65},
      {'name': 'Derecho', 'count': 221, 'percent': 0.55},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart_outlined, size: 18, color: AppTheme.mustardYellow),
                SizedBox(width: 10),
                Text('Matrícula por carrera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            ...careers.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(c['count'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.mustardYellow)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: c['percent'] as double,
                    backgroundColor: const Color(0xFF2D2D2D),
                    color: AppTheme.navyBlue,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
