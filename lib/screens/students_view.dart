import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class StudentsView extends StatelessWidget {
  const StudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      children: [
        _buildFilters(context, isMobile),
        Expanded(child: _buildContent(context, isMobile)),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, bool isMobile) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, DNI o código...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                _buildImportButton(context),
                const SizedBox(width: 16),
                _buildNewStudentButton(context),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildImportButton(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildNewStudentButton(context)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['csv', 'xlsx', 'xls'],
        );
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Procesando archivo: ${result.files.single.name}'),
              backgroundColor: AppTheme.emeraldGreen,
            ),
          );
          // Aquí iría la lógica de parseo y auth.addStudent masivo
        }
      },
      icon: const Icon(Icons.upload_file, size: 18),
      label: const Text('Importar CSV'),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF334155)),
    );
  }

  Widget _buildNewStudentButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, size: 18),
      label: const Text('Nuevo Alumno'),
      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyBlue),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    final system = Provider.of<SystemProvider>(context);
    
    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: system.students.length,
        itemBuilder: (context, index) {
          final s = system.students[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Cód: ${s.code} · ${s.career}', style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
                  const SizedBox(height: 8),
                  _buildStatusBadge(s.status),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: AppTheme.greyText),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowHeight: 60,
            columns: const [
              DataColumn(label: Text('CÓDIGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.greyText))),
              DataColumn(label: Text('ESTUDIANTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.greyText))),
              DataColumn(label: Text('CARRERA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.greyText))),
              DataColumn(label: Text('CRÉDITOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.greyText))),
              DataColumn(label: Text('ESTADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.greyText))),
              DataColumn(label: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.greyText))),
            ],
            rows: system.students.map((s) => DataRow(
              cells: [
                DataCell(Text(s.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.mustardYellow))),
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('DNI ${s.dni}', style: const TextStyle(color: AppTheme.greyText, fontSize: 11)),
                  ],
                )),
                DataCell(Text(s.career)),
                DataCell(Center(child: Text(s.approvedCredits.toString()))),
                DataCell(_buildStatusBadge(s.status)),
                DataCell(Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.roseRed), onPressed: () {}),
                  ],
                )),
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StudentStatus status) {
    Color color;
    String text;
    switch (status) {
      case StudentStatus.regular: color = AppTheme.emeraldGreen; text = 'Activo'; break;
      case StudentStatus.observado: color = AppTheme.amberOrange; text = 'Observado'; break;
      case StudentStatus.inhabilitado: color = AppTheme.roseRed; text = 'Inhabilitado'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
