import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models.dart';
import '../providers.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _searchController = TextEditingController();
  String _selectedSchool = '0701 - Ingenieria de Software y Sistemas';
  String _careerFilter = 'Todas las carreras';
  UserRole _newRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Administrativa UNAJ'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: auth.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.mustardYellow,
          tabs: const [
            Tab(text: 'Control', icon: Icon(Icons.dashboard_outlined)),
            Tab(text: 'Padron', icon: Icon(Icons.people_outline)),
            Tab(text: 'Reportes', icon: Icon(Icons.bar_chart_outlined)),
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

  Widget _buildControlPanel(AuthProvider auth) {
    final enrollment = context.watch<EnrollmentProvider>();
    final enrolled = auth.students
        .where(
          (student) => student.enrollmentStatus == EnrollmentStatus.enrolled,
        )
        .length;
    final pending = auth.students.length - enrolled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpi(
                'Estudiantes',
                '${auth.students.length}',
                Icons.groups_outlined,
                AppTheme.navyBlue,
              ),
              _buildKpi(
                'Matriculados',
                '$enrolled',
                Icons.check_circle_outline,
                AppTheme.emeraldGreen,
              ),
              _buildKpi(
                'Pendientes',
                '$pending',
                Icons.pending_actions_outlined,
                AppTheme.amberOrange,
              ),
              _buildKpi(
                'Constancias',
                '${enrollment.records.length}',
                Icons.description_outlined,
                AppTheme.navyBlue,
              ),
            ],
          ),
          const SizedBox(height: 34),
          const Text(
            'Alta de cuentas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 680;
                    final fields = [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombres completos',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'DNI / codigo',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo institucional',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                    ];
                    if (narrow) {
                      return Column(
                        children: fields
                            .map(
                              (field) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: field,
                              ),
                            )
                            .toList(),
                      );
                    }
                    return Row(
                      children: fields
                          .map(
                            (field) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: field,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSchool,
                  decoration: const InputDecoration(
                    labelText: 'Escuela profesional',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                  items: context
                      .read<EnrollmentProvider>()
                      .escuelasProfesionales
                      .map(
                        (school) => DropdownMenuItem(
                          value: school,
                          child: Text(school, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(
                    () => _selectedSchool = value ?? _selectedSchool,
                  ),
                ),
                if (auth.currentUser!.role == UserRole.adminMaster) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _newRole,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.student,
                        child: Text('Estudiante'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.adminSecondary,
                        child: Text('Administrador secundario'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _newRole = value ?? UserRole.student),
                  ),
                ],
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _createStudent(auth),
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Registrar cuenta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpi(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentPadron(AuthProvider auth) {
    final students = auth.searchStudents(_searchController.text, _careerFilter);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre, codigo o correo',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 270,
                child: DropdownButtonFormField<String>(
                  initialValue: _careerFilter,
                  items:
                      [
                            'Todas las carreras',
                            ...context
                                .read<EnrollmentProvider>()
                                .escuelasProfesionales,
                          ]
                          .map(
                            (career) => DropdownMenuItem(
                              value: career,
                              child: Text(
                                career,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(
                    () => _careerFilter = value ?? 'Todas las carreras',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Codigo')),
                      DataColumn(label: Text('Nombres')),
                      DataColumn(label: Text('Carrera')),
                      DataColumn(label: Text('Estado')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: students.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              student.code,
                              style: const TextStyle(
                                color: AppTheme.navyBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(Text(student.name)),
                          DataCell(Text(student.career)),
                          DataCell(
                            _StatusChip(status: student.enrollmentStatus),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Ver detalle',
                                  onPressed: () => _showStudentDetail(student),
                                  icon: const Icon(
                                    Icons.visibility_outlined,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () =>
                                      auth.deleteStudent(student.id),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppTheme.roseRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(AuthProvider auth) {
    final enrollment = context.watch<EnrollmentProvider>();
    final schools = enrollment.escuelasProfesionales;
    final maxCount = auth.students.isEmpty ? 1 : auth.students.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matricula por escuela profesional',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.navyBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          ...schools.map((school) {
            final count = auth.students
                .where(
                  (student) =>
                      school.toLowerCase().contains(
                        student.career.toLowerCase(),
                      ) ||
                      student.career.toLowerCase().contains(
                        school.substring(7).split(' ').first.toLowerCase(),
                      ),
                )
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          school,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: count / maxCount,
                    minHeight: 9,
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.navyBlue,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.navyBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.backup_outlined,
                  color: AppTheme.mustardYellow,
                  size: 36,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Respaldo academico',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Exportacion simulada de padron, pagos y constancias.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Reporte CSV generado en modo demostracion.',
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.navyBlue,
                  ),
                  icon: const Icon(Icons.table_view_outlined),
                  label: Text('${enrollment.records.length} registros'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createStudent(AuthProvider auth) {
    final name = _nameController.text.trim().toUpperCase();
    final code = _codeController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    if (name.isEmpty || code.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa nombre, codigo y correo.')),
      );
      return;
    }
    auth.addStudent(
      User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        code: code,
        career: _selectedSchool.substring(7),
        role: _newRole,
      ),
    );
    _nameController.clear();
    _codeController.clear();
    _emailController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta registrada correctamente.')),
    );
  }

  void _showStudentDetail(User student) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Codigo: ${student.code}'),
            Text('Correo: ${student.email}'),
            Text('Carrera: ${student.career}'),
            Text(
              'Voucher: ${student.paymentFileName.isEmpty ? 'Pendiente' : student.paymentFileName}',
            ),
            Text(
              'Operacion: ${student.paymentOperation.isEmpty ? 'Pendiente' : student.paymentOperation}',
            ),
            Text(
              'Constancia: ${student.enrollmentCode.isEmpty ? 'Sin generar' : student.enrollmentCode}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EnrollmentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      EnrollmentStatus.pendingPayment => ('Pago pendiente', AppTheme.roseRed),
      EnrollmentStatus.selectingCourses => (
        'Seleccionando',
        AppTheme.amberOrange,
      ),
      EnrollmentStatus.enrolled => ('Matriculado', AppTheme.emeraldGreen),
    };
    return Chip(
      label: Text(
        config.$1,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
      backgroundColor: config.$2.withValues(alpha: 0.15),
      side: BorderSide(color: config.$2.withValues(alpha: 0.25)),
    );
  }
}
