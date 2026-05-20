import 'package:flutter/material.dart';
import '../app_theme.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            children: [
              _buildSimpleStat(
                '1,248',
                'Total matriculados',
                Icons.assignment_turned_in,
                AppTheme.navyBlue,
              ),
              const SizedBox(width: 16),
              _buildSimpleStat(
                '34',
                'Inhabilitados',
                Icons.error_outline,
                AppTheme.amberOrange,
              ),
              const SizedBox(width: 16),
              _buildSimpleStat(
                '12.8',
                'Nota promedio',
                Icons.grade,
                AppTheme.emeraldGreen,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Cursos con más desaprobados',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildChartBar('Física General', 312, 0.9),
                    _buildChartBar('Cálculo III', 260, 0.75),
                    _buildChartBar('Química General', 201, 0.6),
                    _buildChartBar('Estadística', 152, 0.45),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
    String val,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(height: 12),
              Text(
                val,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar(String name, int count, double percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.roseRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percent,
            minHeight: 12,
            backgroundColor: AppTheme.lightGrey,
            color: AppTheme.roseRed.withOpacity(0.7),
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }
}
