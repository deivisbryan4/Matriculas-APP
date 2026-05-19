import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildDetailsGrid(user),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Cambiar contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.mustardYellow,
              child: Text(
                user.name.split(' ').map((e) => e[0]).take(2).join(''),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(user.email, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.emeraldGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Regular', style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              children: [
                _buildDetailItem('Código', user.code),
                _buildDetailItem('DNI', user.dni),
              ],
            ),
            const Divider(height: 48, color: AppTheme.plomoBorde),
            Row(
              children: [
                _buildDetailItem('Carrera', user.career),
                _buildDetailItem('Facultad', user.faculty),
              ],
            ),
            const Divider(height: 48, color: AppTheme.plomoBorde),
            Row(
              children: [
                _buildDetailItem('Ciclo actual', '5to ciclo'),
                _buildDetailItem('Año ingreso', user.entryYear.toString()),
              ],
            ),
            const Divider(height: 48, color: AppTheme.plomoBorde),
            Row(
              children: [
                _buildDetailItem('Celular', user.phone ?? 'No registrado'),
                _buildDetailItem('Sede', user.sede),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
