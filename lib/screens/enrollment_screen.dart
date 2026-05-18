import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = Provider.of<EnrollmentProvider>(context);

    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        labelColor: AppTheme.navyBlue,
        indicatorColor: AppTheme.mustardYellow,
        tabs: const [
          Tab(text: 'Pago', icon: Icon(Icons.payments_outlined)),
          Tab(text: 'Matrícula', icon: Icon(Icons.grid_view)),
          Tab(text: 'Perfil', icon: Icon(Icons.person_outline)),
          Tab(text: 'Constancia', icon: Icon(Icons.check_circle_outline)),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildPaymentTab(enrollment),
          _buildCoursesTab(enrollment),
          _buildProfileTab(context),
          _buildSuccessTab(enrollment),
        ],
      ),
    );
  }

  // --- PESTAÑA 1: PAGO ---
  Widget _buildPaymentTab(EnrollmentProvider ep) {
    return Center(
      child: Container(
        width: 500,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ep.paymentFileName != null ? Icons.file_present : Icons.cloud_upload_outlined,
              size: 80,
              color: ep.paymentFileName != null ? AppTheme.emeraldGreen : AppTheme.navyBlue,
            ),
            const SizedBox(height: 24),
            const Text('VALIDACIÓN DE PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null) {
                  ep.setPaymentFile(result.files.single.name);
                }
              },
              child: Text(ep.paymentFileName ?? 'SELECCIONAR VOUCHER (PDF)'),
            ),
            if (ep.paymentFileName != null && !ep.paymentFileName!.endsWith('.pdf'))
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Error: El archivo debe ser .pdf', style: TextStyle(color: AppTheme.roseRed, fontSize: 12)),
              ),
            const SizedBox(height: 24),
            TextField(
              onChanged: ep.setOperationNumber,
              decoration: const InputDecoration(
                labelText: 'Número de Operación',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (ep.paymentFileName != null && ep.operationNumber.isNotEmpty) 
                  ? () { ep.validatePayment(); _tabController.animateTo(1); } 
                  : null,
                child: const Text('HABILITAR MALLA CURRICULAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- PESTAÑA 2: CURSOS ---
  Widget _buildCoursesTab(EnrollmentProvider ep) {
    if (!ep.isPaymentValidated) {
      return const Center(child: Text('Debe validar su pago primero', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: [
        // Selector de Ciclos
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [1, 2, 3].map((c) => InkWell(
              onTap: () => ep.setCycle(c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: ep.selectedCycle == c ? AppTheme.mustardYellow : Colors.transparent,
                    width: 4,
                  )),
                ),
                child: Text('CICLO $c', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ep.selectedCycle == c ? AppTheme.navyBlue : Colors.grey,
                )),
              ),
            )).toList(),
          ),
        ),
        // Contador Créditos
        Container(
          width: double.infinity,
          color: AppTheme.navyBlue,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CRÉDITOS SELECCIONADOS:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                '${ep.totalCredits} / 22 CR',
                style: TextStyle(
                  color: ep.isOverLimit ? AppTheme.roseRed : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Lista de Cards
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: ep.coursesByCycle.map((course) => _buildCourseCard(course, ep)).toList(),
          ),
        ),
        // Footer Accion
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: ep.totalCredits > 0 && !ep.isOverLimit ? () => _tabController.animateTo(3) : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, minimumSize: const Size(double.infinity, 50)),
            child: const Text('FINALIZAR Y GENERAR CONSTANCIA'),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Course course, EnrollmentProvider ep) {
    Color cardColor = Colors.white;
    String label = '';
    
    if (course.isMandatoryRetake) {
      cardColor = AppTheme.roseRed.withOpacity(0.05);
      label = 'ARRASTRE OBLIGATORIO';
    } else if (course.isBlockedByPrereq) {
      cardColor = Colors.grey.withOpacity(0.1);
      label = 'FALTA PRERREQUISITO: ${course.prereq}';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: course.isMandatoryRetake ? AppTheme.roseRed : Colors.grey.shade200),
      ),
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${course.credits} Créditos'),
            if (label.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course.isMandatoryRetake ? AppTheme.roseRed : AppTheme.amberOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        trailing: course.isBlockedByPrereq 
          ? const Icon(Icons.lock_outline, color: AppTheme.amberOrange)
          : InkWell(
              onTap: () => ep.toggleCourse(course),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: course.isSelected ? AppTheme.emeraldGreen : Colors.transparent,
                  border: Border.all(color: course.isSelected ? AppTheme.emeraldGreen : Colors.grey),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  course.isSelected ? Icons.check : Icons.chevron_right,
                  color: course.isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
      ),
    );
  }

  // --- PESTAÑA 3: PERFIL ---
  Widget _buildProfileTab(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: AppTheme.navyBlue, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            child: Row(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: AppTheme.mustardYellow, child: Icon(Icons.person, size: 50, color: AppTheme.navyBlue)),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Código: ${user.code} | ${user.career.toUpperCase()}', style: const TextStyle(color: AppTheme.mustardYellow, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Column(
              children: [
                const TextField(decoration: InputDecoration(labelText: 'Celular', prefixIcon: Icon(Icons.phone))),
                const SizedBox(height: 16),
                const TextField(decoration: InputDecoration(labelText: 'Correo Alternativo', prefixIcon: Icon(Icons.email))),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                const Text('CAMBIO DE CONTRASEÑA', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Contraseña Actual')),
                const SizedBox(height: 16),
                const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Nueva Contraseña')),
                const SizedBox(height: 32),
                ElevatedButton(onPressed: () {}, child: const Text('GUARDAR CAMBIOS')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PESTAÑA 4: ÉXITO ---
  Widget _buildSuccessTab(EnrollmentProvider ep) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 100, color: AppTheme.emeraldGreen),
          const SizedBox(height: 24),
          const Text('¡MATRÍCULA EXITOSA!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.navyBlue)),
          const Text('Periodo Académico 2024-I', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                const Text('Cursos Inscritos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...ep.selectedCourses.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(c.name, style: const TextStyle(fontSize: 12)), Text('${c.credits} CR')],
                  ),
                )),
                const Divider(),
                const Text('CÓDIGO DIGITAL: UNAJ-8849-X2', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('DESCARGAR CONSTANCIA OFICIAL'),
          ),
        ],
      ),
    );
  }
}
