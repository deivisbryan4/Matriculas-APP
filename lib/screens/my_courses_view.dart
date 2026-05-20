import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../responsive_layout.dart';

class MyCoursesView extends StatefulWidget {
  const MyCoursesView({super.key});

  @override
  State<MyCoursesView> createState() => _MyCoursesViewState();
}

class _MyCoursesViewState extends State<MyCoursesView>
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
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Cursos activos'),
            Tab(text: 'Horario'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCoursesList(context, isMobile),
              _buildSchedule(context, isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoursesList(BuildContext context, bool isMobile) {
    final system = Provider.of<SystemProvider>(context);

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: system.availableCourses.length,
        itemBuilder: (context, index) {
          final c = system.availableCourses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              c.code,
                              style: const TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildAttendanceBadge(c.attendance ?? 0.0),
                    ],
                  ),
                  const Divider(height: 32, color: AppTheme.plomoBorde),
                  Row(
                    children: [
                      _buildInfoIcon(Icons.person_outline, c.teacher ?? ''),
                      const SizedBox(width: 20),
                      _buildInfoIcon(Icons.access_time, c.schedule ?? ''),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoIcon(
                    Icons.layers_outlined,
                    '${c.credits} Créditos',
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowHeight: 60,
            dataRowMaxHeight: 80,
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
                  'Horario',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.greyText,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Docente',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.greyText,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Asistencia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.greyText,
                  ),
                ),
              ),
            ],
            rows: system.availableCourses
                .map(
                  (c) => DataRow(
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              c.code,
                              style: const TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Center(child: Text(c.credits.toString()))),
                      DataCell(Text(c.schedule ?? '')),
                      DataCell(Text(c.teacher ?? '')),
                      DataCell(_buildAttendanceBadge(c.attendance ?? 0.0)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.mustardYellow.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppTheme.whiteText),
        ),
      ],
    );
  }

  Widget _buildSchedule(BuildContext context, bool isMobile) {
    return const Center(child: Text('Calendario de Horario Institucional'));
  }

  Widget _buildAttendanceBadge(double val) {
    final percent = (val * 100).toInt();
    Color color = percent >= 80 ? AppTheme.emeraldGreen : AppTheme.amberOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
