import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTIÓN ADMINISTRATIVA UNAJ'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.mustardYellow,
          tabs: const [
            Tab(text: 'Panel de Control', icon: Icon(Icons.dashboard)),
            Tab(text: 'Padrón Estudiantil', icon: Icon(Icons.people)),
            Tab(text: 'Analítica y Reportes', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildControlPanel(auth),
          _buildStudentPadron(auth),
          _buildAnalytics(auth),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: PANEL DE CONTROL ---
  Widget _buildControlPanel(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildKPI('Población Estudiantil', '12,450', Icons.groups, AppTheme.navyBlue),
              const SizedBox(width: 16),
              _buildKPI('Matriculados 2024-I', '8,120', Icons.check_circle, AppTheme.emeraldGreen),
              const SizedBox(width: 16),
              _buildKPI('Monto Recaudado', 'S/ 450,230', Icons.wallet, AppTheme.navyBlue),
            ],
          ),
          const SizedBox(height: 48),
          const Text('ALTA DE NUEVAS CUENTAS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Nombres Completos'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(decoration: const InputDecoration(labelText: 'DNI / Código'))),
                  ],
                ),
                const SizedBox(height: 16),
                const TextField(decoration: InputDecoration(labelText: 'Escuela Profesional')),
                const SizedBox(height: 24),
                if (auth.currentUser!.role == UserRole.adminMaster)
                  DropdownButtonFormField<UserRole>(
                    decoration: const InputDecoration(labelText: 'Rol Jerárquico'),
                    items: const [
                      DropdownMenuItem(value: UserRole.student, child: Text('Estudiante')),
                      DropdownMenuItem(value: UserRole.adminSecondary, child: Text('Administrador Secundario')),
                    ],
                    onChanged: (v) {},
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Asignar Escuela Profesional'),
                  items: Provider.of<EnrollmentProvider>(context, listen: false).escuelasProfesionales
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 11)))).toList(),
                  onChanged: (v) {},
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.mustardYellow, foregroundColor: AppTheme.navyBlue),
                  child: const Text('EJECUTAR ALTA DE CUENTA', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPI(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  // --- PESTAÑA 2: PADRÓN ---
  Widget _buildStudentPadron(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Buscar por Nombre o Código...', prefixIcon: Icon(Icons.search)))),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: 'Todas las Carreras',
                items: [
                  'Todas las Carreras',
                  '0101 - Ingeniería Textil',
                  '0201 - Ingeniería Ambiental',
                  '0301 - Energías Renovables',
                  '0401 - Industrias Alimentarias',
                  '0501 - Gestión Pública',
                  '0601 - Ingeniería Industrial',
                  '0701 - Ingeniería de Software',
                  '0801 - Ingeniería Mecatrónica',
                  '0901 - Administración',
                  '1001 - Economía'
                ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID/CÓDIGO')),
                    DataColumn(label: Text('NOMBRES')),
                    DataColumn(label: Text('CARRERA')),
                    DataColumn(label: Text('ESTADO')),
                    DataColumn(label: Text('ACCIONES')),
                  ],
                  rows: auth.students.map((s) => DataRow(cells: [
                    DataCell(Text(s.code, style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold))),
                    DataCell(Text(s.name)),
                    DataCell(Text(s.career)),
                    DataCell(Chip(label: const Text('Regular', style: TextStyle(fontSize: 10)), backgroundColor: AppTheme.emeraldGreen.withOpacity(0.2))),
                    DataCell(Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: AppTheme.navyBlue), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, color: AppTheme.roseRed), onPressed: () {}),
                      ],
                    )),
                  ])).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PESTAÑA 3: ANALÍTICA ---
  Widget _buildAnalytics(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('MATRÍCULA POR CARRERA (%)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...[
            '0101 Textil', '0201 Ambiental', '0301 Energías', '0401 Alimentarias', 
            '0501 Gestión', '0601 Industrial', '0701 Software', '0801 Mecatrónica', 
            '0901 Administración', '1001 Economía'
          ].map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: 0.8, backgroundColor: Colors.grey.shade200, color: AppTheme.navyBlue, minHeight: 10),
              ],
            ),
          )),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BACKUP MAESTRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Última copia: Hace 2 horas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: const Text('DESCARGAR CSV TOTAL')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.table_view),
            label: const Text('EXPORTAR EXCEL DE PAGOS'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, minimumSize: const Size(double.infinity, 60)),
          ),
        ],
      ),
    );
  }
}
