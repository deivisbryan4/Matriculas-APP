import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models.dart';
import '../responsive_layout.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.mustardYellow,
          unselectedLabelColor: AppTheme.greyText,
          indicatorColor: AppTheme.mustardYellow,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Por semestre'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSummary(context, isMobile),
              const Center(child: Text('Historial detallado por semestre')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKPIs(isMobile),
          const SizedBox(height: 32),
          Text(
            'Último Semestre (2025-I)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.whiteText,
            ),
          ),
          const SizedBox(height: 16),
          _buildHistoryContent(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildKPIs(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 3.5 : 1.3,
          children: [
            _buildHeaderCard('Promedio acumulado', '13.4', Icons.auto_graph),
            _buildHeaderCard(
              'Créditos aprobados',
              '87',
              Icons.check_circle_outline,
            ),
            _buildHeaderCard(
              'Cursos desaprobados',
              '3',
              Icons.warning_amber_rounded,
              color: AppTheme.roseRed,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCard(
    String label,
    String val,
    IconData icon, {
    Color color = AppTheme.mustardYellow,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    val,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent(BuildContext context, bool isMobile) {
    final records = [
      AcademicRecord(
        courseCode: 'MAT201',
        courseName: 'Álgebra Lineal',
        credits: 4,
        grade: 14.0,
        attempts: 1,
        status: 'APROBADO',
        semester: '2025-I',
      ),
      AcademicRecord(
        courseCode: 'INF202',
        courseName: 'Cálculo II',
        credits: 4,
        grade: 12.0,
        attempts: 2,
        status: 'APROBADO',
        semester: '2025-I',
      ),
      AcademicRecord(
        courseCode: 'CIE201',
        courseName: 'Física I',
        credits: 4,
        grade: 9.0,
        attempts: 2,
        status: 'DESAPROBADO',
        semester: '2025-I',
      ),
      AcademicRecord(
        courseCode: 'MAT202',
        courseName: 'Programación II',
        credits: 3,
        grade: 15.0,
        attempts: 1,
        status: 'APROBADO',
        semester: '2025-I',
      ),
    ];

    if (isMobile) {
      return Column(
        children: records
            .map(
              (r) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.courseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${r.courseCode} · ${r.credits} cr.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.greyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildGradeBadge(r.grade),
                          const SizedBox(height: 8),
                          _buildApprovalBadge(r.isApproved),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
    }

    return Card(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowHeight: 60,
          columns: const [
            DataColumn(
              label: Text(
                'Curso',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greyText,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Créditos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greyText,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Nota',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greyText,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Veces',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greyText,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Estado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.greyText,
                ),
              ),
            ),
          ],
          rows: records
              .map(
                (r) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        r.courseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Center(child: Text(r.credits.toString()))),
                    DataCell(Center(child: _buildGradeBadge(r.grade))),
                    DataCell(Center(child: Text(r.attempts.toString()))),
                    DataCell(_buildApprovalBadge(r.isApproved)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGradeBadge(double grade) {
    Color color = grade >= 11 ? AppTheme.emeraldGreen : AppTheme.roseRed;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          grade.toStringAsFixed(0).padLeft(2, '0'),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalBadge(bool approved) {
    Color color = approved ? AppTheme.emeraldGreen : AppTheme.roseRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        approved ? 'Aprobado' : 'Desaprobado',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }
}
