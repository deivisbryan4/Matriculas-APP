import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar curso...',
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.plomoBorde),
                ),
                child: DropdownButton<String>(
                  value: 'Todos los ciclos',
                  underline: const SizedBox(),
                  items:
                      [
                            'Todos los ciclos',
                            'Ciclo 1',
                            'Ciclo 2',
                            'Ciclo 3',
                            'Ciclo 4',
                            'Ciclo 5',
                          ]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo curso'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 60,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'CÓDIGO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'NOMBRE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CICLO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CRÉDITOS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'TIPO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'PREREQUISITO',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
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
                              Text(
                                c.code,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.mustardYellow,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(Center(child: Text(c.cycle.toString()))),
                            DataCell(Center(child: Text(c.credits.toString()))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (c.type.toUpperCase() == 'OBLIGATORIO'
                                              ? AppTheme.navyBlue
                                              : AppTheme.mustardYellow)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  c.type.isNotEmpty
                                      ? c.type[0].toUpperCase() +
                                          c.type.substring(1).toLowerCase()
                                      : '—',
                                  style: TextStyle(
                                    color: c.type.toUpperCase() == 'OBLIGATORIO'
                                        ? Colors.blue
                                        : AppTheme.mustardYellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                c.prereq ?? '—',
                                style: const TextStyle(
                                  color: AppTheme.greyText,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
