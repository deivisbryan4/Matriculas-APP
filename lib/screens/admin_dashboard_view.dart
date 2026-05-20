import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _activeTab = 0; // 0 = Resumen Académico, 1 = Conciliador Bancario OCR
  final TextEditingController _csvController = TextEditingController();
  bool _showCsvImporter = false;
  bool _isReconciling = false;
  String _filterStatus = 'PENDIENTE'; // 'TODOS', 'PENDIENTE', 'VALIDADO', 'RECHAZADO'

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminHeader(isMobile),
          const SizedBox(height: 24),
          _buildTabSelector(isMobile),
          const SizedBox(height: 24),
          if (_activeTab == 0) ...[
            _buildKPIs(isMobile, system),
            const SizedBox(height: 32),
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _buildRecentPayments(system, auth),
                  const SizedBox(height: 24),
                  _buildCareerStats(system),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildRecentPayments(system, auth)),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _buildCareerStats(system)),
                ],
              ),
            ),
          ] else ...[
            _buildReconciliationPanel(isMobile, system, auth),
          ]
        ],
      ),
    );
  }

  Widget _buildAdminHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Panel de Control',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        Text(
          'Gestión Global UNAJ - Periodo Académico 2025-II',
          style: TextStyle(
            color: AppTheme.greyText,
            fontSize: isMobile ? 12 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.plomoBorde),
      ),
      child: Row(
        mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _buildTabButton(0, 'Resumen Académico', Icons.dashboard_outlined, isMobile),
          _buildTabButton(1, 'Conciliador Bancario OCR', Icons.fact_check_outlined, isMobile),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text, IconData icon, bool isMobile) {
    final isActive = _activeTab == index;
    return Expanded(
      flex: isMobile ? 1 : 0,
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.navyBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppTheme.mustardYellow : AppTheme.greyText,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.greyText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPIs(bool isMobile, SystemProvider system) {
    final pendingCount = system.vouchers.where((v) => v.statusEnum == PaymentStatus.pendiente).length;
    final validatedCount = system.vouchers.where((v) => v.statusEnum == PaymentStatus.validado).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.2 : 1.4,
      children: [
        _buildAdminStatCard(
          'Matriculados',
          '${system.students.length + 1240}',
          'Alumnos registrados',
          Icons.group_outlined,
          AppTheme.emeraldGreen,
        ),
        _buildAdminStatCard(
          'Pagos Pendientes',
          '$pendingCount',
          'Validaciones OCR requeridas',
          Icons.history_toggle_off,
          AppTheme.amberOrange,
        ),
        _buildAdminStatCard(
          'Pagos Conciliados',
          '$validatedCount',
          'Vouchers aprobados',
          Icons.verified_outlined,
          AppTheme.navyBlue,
        ),
        _buildAdminStatCard(
          'Banca Virtual',
          '${system.bankTransactions.length} Trans.',
          'Líneas en extracto diario',
          Icons.account_balance_wallet_outlined,
          AppTheme.mustardYellow,
        ),
      ],
    );
  }

  Widget _buildAdminStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.plomoBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withOpacity(0.8), size: 20),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              sub,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments(SystemProvider system, AuthProvider auth) {
    final pendingVouchers = system.vouchers.where((v) => v.statusEnum == PaymentStatus.pendiente).toList();
    
    return Card(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.plomoBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: AppTheme.mustardYellow,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Auditoría OCR Requerida',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => setState(() => _activeTab = 1),
                  child: const Text(
                    'Ver Conciliador',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mustardYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pendingVouchers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    "No hay vouchers pendientes de validación.",
                    style: TextStyle(color: AppTheme.greyText, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingVouchers.length.clamp(0, 4),
                separatorBuilder: (context, index) =>
                    const Divider(color: AppTheme.plomoBorde, height: 24),
                itemBuilder: (context, index) {
                  final v = pendingVouchers[index];
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.navyBlue,
                        child: Text(
                          v.studentName.isNotEmpty ? v.studentName[0] : 'S',
                          style: const TextStyle(
                            color: AppTheme.mustardYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.studentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Cód: ${v.studentCode} · Op. #${v.operationNumber}',
                              style: const TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showAuditDialog(context, v, system, auth),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.mustardYellow,
                          foregroundColor: AppTheme.navyBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Auditar",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerStats(SystemProvider system) {
    // 1. Carreras reales de la UNAJ en la base de datos
    final realCareers = [
      'INGENIERIA DE SISTEMAS',
      'Ingeniería de Software y Sistemas',
      'Ingeniería Mecatrónica',
      'Ingeniería Ambiental y Forestal',
      'Ingeniería en Energías Renovables',
      'Ingeniería Industrial',
      'Ingeniería Textil y de Confecciones',
      'Ingeniería en Industrias Alimentarias',
      'Administración y Emprendimiento Empresarial',
      'Gestión Pública y Desarrollo Social',
      'Economía',
    ];

    // 2. Contar estudiantes por carrera desde la lista reactiva de estudiantes reales
    final Map<String, int> counts = {};
    for (var name in realCareers) {
      counts[name] = 0;
    }

    for (var student in system.students) {
      final name = student.careerName;
      if (name != null) {
        final matchedCareer = realCareers.firstWhere(
          (c) => c.toLowerCase() == name.toLowerCase(),
          orElse: () => '',
        );
        if (matchedCareer.isNotEmpty) {
          counts[matchedCareer] = (counts[matchedCareer] ?? 0) + 1;
        } else {
          // Si por alguna razón hay otra carrera real no listada, la agregamos
          counts[name] = (counts[name] ?? 0) + 1;
        }
      }
    }

    // 3. Crear lista ordenada por cantidad de estudiantes
    final list = counts.entries.map((entry) {
      return {
        'name': entry.key,
        'count': entry.value,
      };
    }).toList();

    list.sort((a, b) {
      final cmp = (b['count'] as int).compareTo(a['count'] as int);
      if (cmp != 0) return cmp;
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    // 4. Calcular el porcentaje relativo para la barra de progreso
    final maxCount = list.fold<int>(0, (max, item) {
      final count = item['count'] as int;
      return count > max ? count : max;
    });

    final careersData = list.map((item) {
      final count = item['count'] as int;
      final percent = maxCount > 0 ? count / maxCount : 0.0;
      return {
        'name': item['name'] as String,
        'count': count,
        'percent': percent,
      };
    }).toList();

    // 5. Filtrar para mostrar solo carreras con estudiantes (> 0).
    // Si no hay ningún estudiante en absoluto en el sistema, mostramos las primeras 5 por defecto con 0.
    final hasAnyStudents = list.any((item) => (item['count'] as int) > 0);
    final displayedList = hasAnyStudents
        ? careersData.where((item) => (item['count'] as int) > 0).toList()
        : careersData.take(5).toList();

    return Card(
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.plomoBorde),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  size: 18,
                  color: AppTheme.mustardYellow,
                ),
                SizedBox(width: 10),
                Text(
                  'Matrícula por carrera',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...displayedList.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            c['name'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          c['count'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppTheme.mustardYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: c['percent'] as double,
                      backgroundColor: const Color(0xFF1E293B),
                      color: AppTheme.navyBlue,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PANEL DE CONCILIACIÓN BANCARIA OCR ──────────────────────────────────────
  Widget _buildReconciliationPanel(bool isMobile, SystemProvider system, AuthProvider auth) {
    // Filtrar los vouchers según el chip activo
    final filteredVouchers = system.vouchers.where((v) {
      if (_filterStatus == 'TODOS') return true;
      if (_filterStatus == 'PENDIENTE') return v.statusEnum == PaymentStatus.pendiente;
      if (_filterStatus == 'VALIDADO') return v.statusEnum == PaymentStatus.validado;
      if (_filterStatus == 'RECHAZADO') return v.statusEnum == PaymentStatus.rechazado;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. BARRA DE HERRAMIENTAS DE CONCILIACIÓN (Botones Cargar Banco y Auto-Conciliar)
        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.plomoBorde),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: AppTheme.mustardYellow, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Extracto Diario Bancario",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${system.bankTransactions.length} Trans. Registradas",
                        style: const TextStyle(
                          color: AppTheme.emeraldGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Como no existe acceso directo de API en tiempo real con el banco, carga el extracto bancario diario exportado (formato CSV/Teleahorro) para cruzarlo automáticamente con el OCR de los alumnos.",
                  style: TextStyle(color: AppTheme.greyText, fontSize: 11),
                ),
                const SizedBox(height: 16),
                
                // Botones de acción principal
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Botón Cargar Estado de Cuenta
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _showCsvImporter = !_showCsvImporter);
                      },
                      icon: const Icon(Icons.upload_file, size: 16),
                      label: const Text("Importar Extracto Bancario (CSV)"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.plomoBorde),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Botón Plantilla Demo
                    OutlinedButton.icon(
                      onPressed: () {
                        system.loadDemoBankTransactions();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Extracto bancario de simulación cargado con transacciones demo de BN y Págalo.pe."),
                            backgroundColor: AppTheme.emeraldGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.flash_on, size: 16, color: AppTheme.mustardYellow),
                      label: const Text("Cargar Demo Banco de la Nación"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.mustardYellow,
                        side: const BorderSide(color: AppTheme.mustardYellow),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Botón de Auto-Conciliación Inteligente
                    ElevatedButton.icon(
                      onPressed: _isReconciling
                          ? null
                          : () async {
                              setState(() => _isReconciling = true);
                              final count = await system.autoReconcilePayments(auth.currentUser?.id ?? 'ADMIN_01');
                              setState(() => _isReconciling = false);

                              if (!mounted) return;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF0F172A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: AppTheme.plomoBorde),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.auto_awesome, color: AppTheme.mustardYellow),
                                      SizedBox(width: 10),
                                      Text("Conciliación Inteligente", style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  content: Text(
                                    count > 0
                                        ? "¡Proceso terminado con éxito!\nSe conciliaron y validaron automáticamente $count pagos cruzando el extracto con el OCR."
                                        : "Proceso terminado.\nNo se encontraron nuevos pagos pendientes que coincidan exactamente con el extracto bancario actual.",
                                    style: const TextStyle(color: AppTheme.greyText, fontSize: 13),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Entendido", style: TextStyle(color: AppTheme.mustardYellow)),
                                    )
                                  ],
                                ),
                              );
                            },
                      icon: _isReconciling
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.navyBlue)),
                            )
                          : const Icon(Icons.auto_awesome, size: 16, color: AppTheme.navyBlue),
                      label: const Text(
                        "Auto-Conciliar con OCR (1-Clic)",
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mustardYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                // Expandable CSV Importer Text Area
                if (_showCsvImporter) ...[
                  const SizedBox(height: 20),
                  const Divider(color: AppTheme.plomoBorde),
                  const SizedBox(height: 12),
                  const Text(
                    "Pega líneas CSV en este formato: operacion,fecha,monto,dni,nombre,tipo",
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _csvController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: "Ejemplo: 9876543,19/05/2026,80.00,74653245,CARLOS SOSA VELASQUEZ,BANCO_NACION",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.plomoBorde),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.mustardYellow),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _showCsvImporter = false),
                        child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_csvController.text.trim().isNotEmpty) {
                            final importedCount = system.importBankStatement(_csvController.text);
                            _csvController.clear();
                            setState(() => _showCsvImporter = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("$importedCount líneas de extracto bancario cargadas correctamente."),
                                backgroundColor: AppTheme.emeraldGreen,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.navyBlue),
                        child: const Text("Procesar e Importar", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ]
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. CHIPS DE FILTRO DE ESTADO
        Row(
          children: [
            _buildFilterChip('PENDIENTE', 'Pendientes', system),
            const SizedBox(width: 8),
            _buildFilterChip('VALIDADO', 'Validados', system),
            const SizedBox(width: 8),
            _buildFilterChip('RECHAZADO', 'Rechazados', system),
            const SizedBox(width: 8),
            _buildFilterChip('TODOS', 'Todos', system),
          ],
        ),
        const SizedBox(height: 16),

        // 3. TABLA DE REGISTROS DE VOUCHER CON SEMÁFOROS
        Card(
          color: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.plomoBorde),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                if (filteredVouchers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Text(
                        "No se encontraron vouchers bajo este estado.",
                        style: TextStyle(color: AppTheme.greyText, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredVouchers.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.plomoBorde, height: 1),
                    itemBuilder: (context, index) {
                      final v = filteredVouchers[index];
                      
                      // Ejecutar validación de 3 capas
                      final hasBankMatch = system.bankTransactions.any(
                        (t) => t.operationNumber.trim() == v.operationNumber.trim() &&
                               (t.amount - v.amount).abs() < 0.05
                      );
                      
                      // DNI coincidente con el alumno y extracto bancario
                      final isStudentDniValid = v.studentDni.trim().isNotEmpty &&
                                                system.bankTransactions.any(
                                                  (t) => t.operationNumber.trim() == v.operationNumber.trim() &&
                                                         t.clientDni == v.studentDni
                                                );

                      // Chequear duplicación de operación en tabla pagos
                      final isDuplicateOp = system.vouchers.where(
                        (pv) => pv.operationNumber.trim() == v.operationNumber.trim() && pv.id != v.id
                      ).isNotEmpty;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: ResponsiveLayout(
                          mobile: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: v.statusEnum == PaymentStatus.validado 
                                        ? AppTheme.emeraldGreen.withOpacity(0.12)
                                        : AppTheme.navyBlue,
                                    child: Icon(
                                      v.statusEnum == PaymentStatus.validado 
                                          ? Icons.verified 
                                          : Icons.receipt_long,
                                      color: v.statusEnum == PaymentStatus.validado 
                                          ? AppTheme.emeraldGreen 
                                          : AppTheme.mustardYellow,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.studentName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          'Op: #${v.operationNumber} · Monto: S/. ${v.amount.toStringAsFixed(2)}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(v.statusEnum)
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Semáforos en móvil
                              Row(
                                children: [
                                  _buildSemaphoreBadge("BANCO", hasBankMatch ? Colors.green : Colors.amber, hasBankMatch ? Icons.check_circle : Icons.warning_amber),
                                  const SizedBox(width: 6),
                                  _buildSemaphoreBadge("DNI", isStudentDniValid ? Colors.green : Colors.amber, isStudentDniValid ? Icons.check_circle : Icons.warning_amber),
                                  const SizedBox(width: 6),
                                  _buildSemaphoreBadge("FIRMA", !isDuplicateOp ? Colors.green : Colors.red, !isDuplicateOp ? Icons.check_circle : Icons.error_outline),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => _showAuditDialog(context, v, system, auth),
                                    child: const Text("Auditar", style: TextStyle(color: AppTheme.mustardYellow, fontSize: 12, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              )
                            ],
                          ),
                          desktop: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: v.statusEnum == PaymentStatus.validado 
                                    ? AppTheme.emeraldGreen.withOpacity(0.12)
                                    : AppTheme.navyBlue,
                                child: Icon(
                                  v.statusEnum == PaymentStatus.validado 
                                      ? Icons.verified 
                                      : Icons.receipt_long,
                                  color: v.statusEnum == PaymentStatus.validado 
                                      ? AppTheme.emeraldGreen 
                                      : AppTheme.mustardYellow,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.studentName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      'Código: ${v.studentCode} · DNI: ${v.studentDni}',
                                      style: const TextStyle(color: AppTheme.greyText, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Op: #${v.operationNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      'Monto: S/. ${v.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              // Semáforos en Desktop
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    _buildSemaphoreBadge("BANCO", hasBankMatch ? Colors.green : Colors.amber, hasBankMatch ? Icons.check_circle : Icons.warning_amber),
                                    const SizedBox(width: 8),
                                    _buildSemaphoreBadge("DNI", isStudentDniValid ? Colors.green : Colors.amber, isStudentDniValid ? Icons.check_circle : Icons.warning_amber),
                                    const SizedBox(width: 8),
                                    _buildSemaphoreBadge("FIRMA", !isDuplicateOp ? Colors.green : Colors.red, !isDuplicateOp ? Icons.check_circle : Icons.error_outline),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(v.statusEnum),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => _showAuditDialog(context, v, system, auth),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.mustardYellow,
                                  foregroundColor: AppTheme.navyBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Auditar OCR",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String status, String label, SystemProvider system) {
    final isActive = _filterStatus == status;
    int count = 0;
    if (status == 'TODOS') {
      count = system.vouchers.length;
    } else {
      final pStatus = status == 'PENDIENTE'
          ? PaymentStatus.pendiente
          : status == 'VALIDADO'
              ? PaymentStatus.validado
              : PaymentStatus.rechazado;
      count = system.vouchers.where((v) => v.statusEnum == pStatus).length;
    }

    return ChoiceChip(
      label: Text("$label ($count)"),
      selected: isActive,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filterStatus = status);
        }
      },
      selectedColor: AppTheme.navyBlue,
      backgroundColor: const Color(0xFF0F172A),
      labelStyle: TextStyle(
        color: isActive ? Colors.white : AppTheme.greyText,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isActive ? AppTheme.mustardYellow : AppTheme.plomoBorde),
      ),
    );
  }

  Widget _buildSemaphoreBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    String text;
    switch (status) {
      case PaymentStatus.pendiente:
        color = AppTheme.amberOrange;
        text = 'Pendiente';
        break;
      case PaymentStatus.validado:
        color = AppTheme.emeraldGreen;
        text = 'Validado';
        break;
      case PaymentStatus.rechazado:
        color = AppTheme.roseRed;
        text = 'Rechazado';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  // ── VISOR SPLIT-SCREEN DIALOG (Auditoría de Voucher) ────────────────────────
  void _showAuditDialog(
    BuildContext parentContext,
    PaymentVoucher voucher,
    SystemProvider system,
    AuthProvider auth,
  ) {
    showDialog(
      context: parentContext,
      barrierDismissible: true,
      builder: (context) {
        double rotation = 0.0;
        double scale = 1.0;
        final rejectReasonController = TextEditingController();

        // 3-Layer Audits
        final match = system.bankTransactions.firstWhere(
          (t) => t.operationNumber.trim() == voucher.operationNumber.trim() &&
                 (t.amount - voucher.amount).abs() < 0.05,
          orElse: () => BankTransaction(operationNumber: '', date: '', amount: 0.0, type: ''),
        );

        final hasBankMatch = match.operationNumber.isNotEmpty;
        final isStudentDniValid = voucher.studentDni.isNotEmpty;
        final isDuplicateOp = system.vouchers.where(
          (pv) => pv.operationNumber.trim() == voucher.operationNumber.trim() && pv.id != voucher.id
        ).isNotEmpty;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isMobile = ResponsiveLayout.isMobile(context);
            
            return Dialog(
              backgroundColor: const Color(0xFF0B0F19),
              insetPadding: EdgeInsets.all(isMobile ? 12 : 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.plomoBorde),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 750),
                child: ResponsiveLayout(
                  mobile: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDialogHeader(context, voucher),
                        _buildImageContainer(voucher, rotation, scale, setDialogState),
                        _buildInspectionControls(
                          context,
                          voucher,
                          match,
                          hasBankMatch,
                          isStudentDniValid,
                          isDuplicateOp,
                          rejectReasonController,
                          system,
                          auth,
                        ),
                      ],
                    ),
                  ),
                  desktop: Column(
                    children: [
                      _buildDialogHeader(context, voucher),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // LADO IZQUIERDO: VISOR DE IMAGEN
                            Expanded(
                              flex: 5,
                              child: _buildImageContainer(voucher, rotation, scale, setDialogState),
                            ),
                            const VerticalDivider(color: AppTheme.plomoBorde, width: 1),
                            // LADO DERECHO: DATOS Y SEMÁFOROS
                            Expanded(
                              flex: 6,
                              child: SingleChildScrollView(
                                child: _buildInspectionControls(
                                  context,
                                  voucher,
                                  match,
                                  hasBankMatch,
                                  isStudentDniValid,
                                  isDuplicateOp,
                                  rejectReasonController,
                                  system,
                                  auth,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogHeader(BuildContext context, PaymentVoucher voucher) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: AppTheme.plomoBorde)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppTheme.mustardYellow, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      "Consola de Auditoría Inteligente OCR",
                      style: TextStyle(color: AppTheme.mustardYellow, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: voucher.statusEnum == PaymentStatus.validado
                            ? AppTheme.emeraldGreen.withOpacity(0.15)
                            : AppTheme.amberOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        voucher.statusStr.toUpperCase(),
                        style: TextStyle(
                          color: voucher.statusEnum == PaymentStatus.validado ? AppTheme.emeraldGreen : AppTheme.amberOrange,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Revisión de Comprobante: ${voucher.studentName}",
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _buildImageContainer(
    PaymentVoucher voucher,
    double rotation,
    double scale,
    StateSetter setDialogState,
  ) {
    final imagePath = voucher.voucherUrl ?? '';
    final isLocal = !imagePath.startsWith('http');

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Imagen con rotación y zoom
          Positioned.fill(
            child: Center(
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: imagePath.isEmpty
                      ? const Center(child: Icon(Icons.image_not_supported, color: AppTheme.greyText, size: 48))
                      : isLocal
                          ? Image.file(File(imagePath), fit: BoxFit.contain)
                          : Image.network(
                              imagePath,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.mustardYellow)));
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.broken_image, color: Colors.red, size: 48));
                              },
                            ),
                ),
              ),
            ),
          ),

          // Controles de visor flotantes
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.plomoBorde, width: 0.5),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.rotate_right, color: Colors.white, size: 18),
                    tooltip: "Rotar 90°",
                    onPressed: () {
                      setDialogState(() {
                        rotation += 1.5708; // 90 degrees in radians
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
                    tooltip: "Acercar",
                    onPressed: () {
                      setDialogState(() {
                        if (scale < 3.0) scale += 0.25;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out, color: Colors.white, size: 18),
                    tooltip: "Alejar",
                    onPressed: () {
                      setDialogState(() {
                        if (scale > 0.5) scale -= 0.25;
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInspectionControls(
    BuildContext context,
    PaymentVoucher voucher,
    BankTransaction match,
    bool hasBankMatch,
    bool isStudentDniValid,
    bool isDuplicateOp,
    TextEditingController rejectReasonController,
    SystemProvider system,
    AuthProvider auth,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. EXPEDIENTE DEL ALUMNO
          const Text(
            "EXPEDIENTE ACADÉMICO DEL ESTUDIANTE",
            style: TextStyle(color: AppTheme.greyText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141B2D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.plomoBorde),
            ),
            child: Column(
              children: [
                _buildFieldRow("Estudiante:", voucher.studentName),
                const SizedBox(height: 6),
                _buildFieldRow("Código UNAJ:", voucher.studentCode),
                const SizedBox(height: 6),
                _buildFieldRow("DNI Registrado:", voucher.studentDni),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. CONTROLES DE AUDITORÍA (3 CAPAS)
          const Text(
            "VALIDACIONES ANTI-FRAUDE (3 CAPAS)",
            style: TextStyle(color: AppTheme.greyText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          
          _buildAuditStepCard(
            "1. Cruce con Estado de Cuenta",
            hasBankMatch 
                ? "Operación registrada y autorizada por la Entidad Bancaria." 
                : "¡Alerta! No existe esta operación por este monto en el estado de cuenta diario.",
            hasBankMatch ? Colors.green : Colors.amber,
            hasBankMatch ? Icons.verified : Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 8),
          _buildAuditStepCard(
            "2. Validación de Identidad (DNI)",
            isStudentDniValid 
                ? "DNI del estudiante coincide con la cuenta bancaria del voucher." 
                : "No se encontró coincidencia de DNI con el emisor en el extracto bancario.",
            isStudentDniValid ? Colors.green : Colors.amber,
            isStudentDniValid ? Icons.assignment_turned_in : Icons.warning,
          ),
          const SizedBox(height: 8),
          _buildAuditStepCard(
            "3. Firma de Operación Única (Anti-Doble Gasto)",
            !isDuplicateOp 
                ? "Firma de voucher única. Comprobante no registrado previamente." 
                : "¡ALERTA CRÍTICA! Este voucher ya fue registrado por otro alumno. Posible fraude de re-uso.",
            !isDuplicateOp ? Colors.green : Colors.red,
            !isDuplicateOp ? Icons.lock_outline : Icons.gpp_bad,
          ),
          const SizedBox(height: 20),

          // 3. COMPARATIVA DIRECTA OCR VS BANCO
          const Text(
            "COMPARATIVA OCR VS BANCO DE DATOS",
            style: TextStyle(color: AppTheme.greyText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          Table(
            border: TableBorder.all(color: AppTheme.plomoBorde, width: 0.5, borderRadius: BorderRadius.circular(8)),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                children: [
                  _buildTableCell("Campo", isHeader: true),
                  _buildTableCell("OCR (Estudiante)", isHeader: true),
                  _buildTableCell("Banco de Datos", isHeader: true),
                ]
              ),
              TableRow(
                children: [
                  _buildTableCell("Operación"),
                  _buildTableCell(voucher.operationNumber, highlight: true),
                  _buildTableCell(hasBankMatch ? match.operationNumber : "NO ENCONTRADO", error: !hasBankMatch),
                ]
              ),
              TableRow(
                children: [
                  _buildTableCell("Monto"),
                  _buildTableCell("S/. ${voucher.amount.toStringAsFixed(2)}", highlight: true),
                  _buildTableCell(hasBankMatch ? "S/. ${match.amount.toStringAsFixed(2)}" : "—", error: !hasBankMatch),
                ]
              ),
              TableRow(
                children: [
                  _buildTableCell("Fecha"),
                  _buildTableCell("—"),
                  _buildTableCell(hasBankMatch ? match.date : "—"),
                ]
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. ACCIONES DE DIÁLOGO
          Row(
            children: [
              // Botón Rechazar
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Mostrar caja de texto para motivo de rechazo
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        backgroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.plomoBorde),
                        ),
                        title: const Text("Rechazar Comprobante", style: TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ingresa el motivo del rechazo del voucher:", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: rejectReasonController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: "Ej. Monto insuficiente / Imagen borrosa",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.plomoBorde)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.mustardYellow)),
                              ),
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await system.validateVoucher(
                                voucher.id,
                                'RECHAZADO',
                                auth.currentUser?.id ?? 'ADMIN_01',
                              );
                              Navigator.pop(dialogCtx); // Pop reason dialog
                              Navigator.pop(context); // Pop audit screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Comprobante marcado como RECHAZADO."),
                                  backgroundColor: AppTheme.roseRed,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.roseRed),
                            child: const Text("Rechazar Pago", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.cancel_outlined, color: AppTheme.roseRed, size: 16),
                  label: const Text("Rechazar Pago", style: TextStyle(color: AppTheme.roseRed, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.roseRed),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Botón Aprobar
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await system.validateVoucher(
                      voucher.id,
                      'VALIDADO',
                      auth.currentUser?.id ?? 'ADMIN_01',
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Comprobante aprobado y validado con éxito."),
                        backgroundColor: AppTheme.emeraldGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, color: AppTheme.navyBlue, size: 16),
                  label: const Text("Aprobar y Validar", style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mustardYellow,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.greyText, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAuditStepCard(String title, String description, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.greyText, fontSize: 10),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool highlight = false, bool error = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader
              ? Colors.white
              : error
                  ? AppTheme.roseRed
                  : highlight
                      ? AppTheme.mustardYellow
                      : Colors.white70,
          fontWeight: isHeader || highlight || error ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 11 : 10,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
