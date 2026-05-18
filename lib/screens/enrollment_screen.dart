import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models.dart';
import '../providers.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _altEmailController = TextEditingController();
  final _operationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _phoneController.text = user.phone;
      _altEmailController.text = user.altEmail;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _altEmailController.dispose();
    _operationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final enrollment = context.watch<EnrollmentProvider>();
    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Matricula ${EnrollmentProvider.academicPeriod}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                user.code,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () {
              enrollment.reset();
              auth.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.mustardYellow,
          tabs: const [
            Tab(text: 'Pago', icon: Icon(Icons.payments_outlined)),
            Tab(text: 'Cursos', icon: Icon(Icons.grid_view)),
            Tab(text: 'Perfil', icon: Icon(Icons.person_outline)),
            Tab(text: 'Constancia', icon: Icon(Icons.verified_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildPaymentTab(auth, enrollment),
          _buildCoursesTab(auth, enrollment),
          _buildProfileTab(auth),
          _buildConstancyTab(enrollment),
        ],
      ),
    );
  }

  Widget _buildPaymentTab(AuthProvider auth, EnrollmentProvider ep) {
    final user = auth.currentUser!;
    final statusText = user.enrollmentStatus == EnrollmentStatus.enrolled
        ? 'Matricula registrada'
        : ep.isPaymentValidated
        ? 'Pago validado'
        : 'Pendiente de validacion';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _StatusHeader(user: user, statusText: statusText),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      ep.paymentFileName != null
                          ? Icons.picture_as_pdf
                          : Icons.cloud_upload_outlined,
                      size: 72,
                      color: ep.paymentFileName != null
                          ? AppTheme.emeraldGreen
                          : AppTheme.navyBlue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Validacion de pago',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adjunta tu voucher PDF e ingresa el numero de operacion para habilitar la malla curricular.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                        if (result != null) {
                          ep.setPaymentFile(result.files.single.name);
                        }
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        ep.paymentFileName ?? 'Seleccionar voucher PDF',
                      ),
                    ),
                    if (ep.paymentFileName != null &&
                        !ep.paymentFileName!.toLowerCase().endsWith('.pdf'))
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'El archivo debe tener extension .pdf',
                          style: TextStyle(
                            color: AppTheme.roseRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _operationController,
                      keyboardType: TextInputType.number,
                      onChanged: ep.setOperationNumber,
                      decoration: const InputDecoration(
                        labelText: 'Numero de operacion',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        final validated = ep.validatePayment();
                        if (!validated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Revisa el PDF y usa un numero de operacion de al menos 5 digitos.',
                              ),
                            ),
                          );
                          return;
                        }
                        auth.applyPaymentToCurrentUser(
                          ep.paymentFileName!,
                          ep.operationNumber,
                        );
                        _tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Habilitar malla curricular'),
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

  Widget _buildCoursesTab(AuthProvider auth, EnrollmentProvider ep) {
    if (!ep.isPaymentValidated &&
        auth.currentUser!.enrollmentStatus == EnrollmentStatus.pendingPayment) {
      return const Center(child: Text('Primero debes validar tu pago.'));
    }

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [1, 2, 3].map((cycle) {
              final selected = ep.selectedCycle == cycle;
              return TextButton(
                onPressed: () => ep.setCycle(cycle),
                style: TextButton.styleFrom(
                  foregroundColor: selected
                      ? AppTheme.navyBlue
                      : Colors.grey.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                ),
                child: Text(
                  'CICLO $cycle',
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppTheme.navyBlue,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 8,
            children: [
              const Text(
                'Creditos seleccionados',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${ep.totalCredits} / ${EnrollmentProvider.maxCredits} CR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: ep.coursesByCycle
                .map((course) => _buildCourseCard(course, ep))
                .toList(),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: ep.canFinishEnrollment
                  ? () {
                      final record = ep.finishEnrollment(auth.currentUser!);
                      auth.markCurrentUserEnrolled(record.id);
                      _tabController.animateTo(3);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emeraldGreen,
                minimumSize: const Size(double.infinity, 52),
              ),
              icon: const Icon(Icons.assignment_turned_in_outlined),
              label: const Text('Finalizar y generar constancia'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Course course, EnrollmentProvider ep) {
    final blocked = course.isBlockedByPrereq;
    final mandatory = course.isMandatoryRetake;
    final borderColor = mandatory
        ? AppTheme.roseRed
        : blocked
        ? AppTheme.amberOrange
        : Colors.grey.shade300;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      color: blocked ? Colors.grey.shade100 : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: course.isSelected
              ? AppTheme.emeraldGreen
              : AppTheme.navyBlue.withValues(alpha: 0.1),
          foregroundColor: course.isSelected ? Colors.white : AppTheme.navyBlue,
          child: Text('${course.credits}'),
        ),
        title: Text(
          course.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.navyBlue,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _CourseChip(
                text: 'Seccion ${course.section}',
                icon: Icons.groups_outlined,
              ),
              _CourseChip(text: course.schedule, icon: Icons.schedule),
              _CourseChip(
                text: '${course.vacancies} vacantes',
                icon: Icons.event_seat_outlined,
              ),
              if (mandatory)
                const _CourseChip(
                  text: 'Arrastre obligatorio',
                  icon: Icons.priority_high,
                  color: AppTheme.roseRed,
                ),
              if (blocked)
                _CourseChip(
                  text: 'Prerequisito: ${course.prereq}',
                  icon: Icons.lock_outline,
                  color: AppTheme.amberOrange,
                ),
            ],
          ),
        ),
        trailing: blocked
            ? const Icon(Icons.lock_outline, color: AppTheme.amberOrange)
            : IconButton(
                tooltip: course.isSelected ? 'Quitar curso' : 'Agregar curso',
                onPressed: () => ep.toggleCourse(course),
                icon: Icon(
                  course.isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                color: course.isSelected ? AppTheme.emeraldGreen : Colors.grey,
              ),
      ),
    );
  }

  Widget _buildProfileTab(AuthProvider auth) {
    final user = auth.currentUser!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppTheme.navyBlue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.mustardYellow,
                      child: Icon(
                        Icons.person,
                        size: 42,
                        color: AppTheme.navyBlue,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${user.code} | ${user.career}',
                            style: const TextStyle(
                              color: AppTheme.mustardYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Celular',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _altEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo alternativo',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        auth.updateCurrentUserContact(
                          phone: _phoneController.text,
                          altEmail: _altEmailController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Perfil actualizado correctamente.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar cambios'),
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

  Widget _buildConstancyTab(EnrollmentProvider ep) {
    final record = ep.currentRecord;
    if (record == null) {
      return const Center(
        child: Text(
          'Completa la seleccion de cursos para generar tu constancia.',
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.verified,
                size: 72,
                color: AppTheme.emeraldGreen,
              ),
              const SizedBox(height: 16),
              const Text(
                'Matricula registrada',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
              Text(
                'Periodo academico ${record.period}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _ConstancyLine(label: 'Estudiante', value: record.studentName),
              _ConstancyLine(label: 'Codigo', value: record.studentCode),
              _ConstancyLine(label: 'Carrera', value: record.career),
              _ConstancyLine(label: 'Operacion', value: record.operationNumber),
              const Divider(height: 28),
              ...record.courses.map(
                (course) => _ConstancyLine(
                  label: course.id,
                  value: '${course.name} (${course.credits} CR)',
                ),
              ),
              const Divider(height: 28),
              _ConstancyLine(
                label: 'Total',
                value: '${record.totalCredits} creditos',
              ),
              const SizedBox(height: 18),
              SelectableText(
                record.id,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final User user;
  final String statusText;

  const _StatusHeader({required this.user, required this.statusText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.navyBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.school_outlined,
            color: AppTheme.mustardYellow,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user.career} | $statusText',
                  style: const TextStyle(
                    color: AppTheme.mustardYellow,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _CourseChip({
    required this.text,
    required this.icon,
    this.color = AppTheme.navyBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: 0.08),
      side: BorderSide(color: color.withValues(alpha: 0.16)),
    );
  }
}

class _ConstancyLine extends StatelessWidget {
  final String label;
  final String value;

  const _ConstancyLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
