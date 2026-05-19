import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class EnrollmentView extends StatelessWidget {
  const EnrollmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Column(
      children: [
        _buildStepper(system, isMobile),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            child: Column(
              children: [
                if (system.enrollmentStep == 1) _buildPaymentStep(system, isMobile),
                if (system.enrollmentStep == 2) _buildCourseSelectionStep(system, isMobile),
                if (system.enrollmentStep == 3) _buildConfirmationStep(system, isMobile),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepper(SystemProvider system, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: const Color(0xFF0F172A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem(1, 'Pago', system.enrollmentStep == 1, system.enrollmentStep > 1, isMobile),
          _buildStepDivider(system.enrollmentStep > 1, isMobile),
          _buildStepItem(2, 'Cursos', system.enrollmentStep == 2, system.enrollmentStep > 2, isMobile),
          _buildStepDivider(system.enrollmentStep > 2, isMobile),
          _buildStepItem(3, 'Confirmar', system.enrollmentStep == 3, false, isMobile),
        ],
      ),
    );
  }

  Widget _buildStepItem(int num, String label, bool active, bool completed, bool isMobile) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: completed ? AppTheme.navyBlue : (active ? AppTheme.mustardYellow : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: completed ? AppTheme.navyBlue : (active ? AppTheme.mustardYellow : Colors.grey)),
          ),
          child: Center(
            child: completed 
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text(num.toString(), style: TextStyle(color: active ? AppTheme.navyBlue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: (active || completed) ? Colors.white : Colors.grey, fontSize: 12)),
        ],
      ],
    );
  }

  Widget _buildStepDivider(bool active, bool isMobile) {
    return Container(
      width: isMobile ? 30 : 60,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: active ? AppTheme.navyBlue : AppTheme.plomoBorde,
    );
  }

  Widget _buildPaymentStep(SystemProvider system, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: Column(
              children: [
                const Text('Registrar pago', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _buildPaymentInfoRow('Concepto', 'Matrícula 2025-II', 'Monto', 'S/. 350.00'),
                const SizedBox(height: 24),
                _buildPaymentInfoRow('Banco', 'Banco de la Nación', 'Fecha límite', '25 Feb 2025'),
                const SizedBox(height: 32),
                InkWell(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
                    if (result != null) {
                      system.updateUploadedVoucher(result.files.single.name);
                    }
                  },
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.plomoBorde, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 32, color: AppTheme.greyText),
                        const SizedBox(height: 12),
                        Text(system.uploadedVoucher ?? 'Adjuntar voucher de pago', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.greyText, fontSize: 13)),
                        const Text('JPG, PNG o PDF · Máx. 5MB', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const TextField(decoration: InputDecoration(labelText: 'Nº de operación', hintText: 'Ej: 1234567890')),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: system.uploadedVoucher != null ? () => system.setEnrollmentStep(2) : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar comprobante'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentInfoRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l1, style: const TextStyle(color: AppTheme.greyText, fontSize: 11)), Text(v1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))])),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l2, style: const TextStyle(color: AppTheme.greyText, fontSize: 11)), Text(v2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))])),
      ],
    );
  }

  Widget _buildCourseSelectionStep(SystemProvider system, bool isMobile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E3A8A).withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E3A8A))),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF60A5FA), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
                    children: [
                      const TextSpan(text: 'Estado: '),
                      const TextSpan(text: 'Regular', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' · Máximo '),
                      const TextSpan(text: '22 créditos', style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '. Seleccionados: '),
                      TextSpan(text: '${system.currentCredits} / 22', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seleccionar cursos — Ciclo 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...system.availableCourses.map((c) => _buildCourseItem(c, system)),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(onPressed: () => system.setEnrollmentStep(1), child: const Text('Atrás')),
                    const SizedBox(width: 16),
                    ElevatedButton(onPressed: system.selectedCourses.isEmpty ? null : () => system.setEnrollmentStep(3), child: const Text('Continuar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseItem(Course c, SystemProvider system) {
    final isSelected = system.selectedCourses.any((item) => item.id == c.id);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.plomoBorde))),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: c.isBlockedByPrereq ? null : (_) => system.toggleCourse(c),
            activeColor: AppTheme.mustardYellow,
            checkColor: AppTheme.navyBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: c.isBlockedByPrereq ? AppTheme.greyText : Colors.white)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${c.code} · Ciclo ${c.cycle}', style: const TextStyle(color: AppTheme.greyText, fontSize: 11)),
                    const SizedBox(width: 8),
                    _buildPrereqBadge(c),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
            child: Text('${c.credits} cr.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrereqBadge(Course c) {
    if (c.isBlockedByPrereq) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppTheme.roseRed.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text('Falta: ${c.prereq}', style: const TextStyle(color: AppTheme.roseRed, fontSize: 9, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: AppTheme.emeraldGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: const Text('Prerreq. OK', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildConfirmationStep(SystemProvider system, bool isMobile) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confirmar Matrícula', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildConfirmItem('Estudiante', 'Kevin Mamani Quispe'),
                          _buildConfirmItem('Código', '2021001'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildConfirmItem('Semestre', '2025-II'),
                          _buildConfirmItem('Total créditos', '${system.currentCredits} cr.'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Cursos seleccionados', style: TextStyle(fontSize: 13, color: AppTheme.greyText, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...system.selectedCourses.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(c.code, style: const TextStyle(color: AppTheme.greyText, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10)),
                        child: Text('${c.credits} cr.', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => system.setEnrollmentStep(2), child: const Text('Atrás', style: TextStyle(color: AppTheme.greyText))),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24)),
                      child: const Text('Confirmar matrícula'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.greyText, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mustardYellow)),
      ],
    );
  }
}
