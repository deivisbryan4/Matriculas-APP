import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../app_theme.dart';
import '../providers.dart';
import '../models.dart';
import '../responsive_layout.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final system = Provider.of<SystemProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser!;
    final isMobile = ResponsiveLayout.isMobile(context);

    if (user.role == UserRole.student) {
      return _buildStudentPayments(system, isMobile);
    }
    return _buildAdminPayments(system, isMobile);
  }

  Widget _buildStudentPayments(SystemProvider system, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentForm(system, isMobile),
          const SizedBox(height: 32),
          const Text('Historial de pagos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPaymentsList(system, isMobile),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(SystemProvider system, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildFormItem('Concepto', 'Matrícula 2025-II'),
                _buildFormItem('Monto', 'S/. 350.00'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFormItem('Banco', 'Banco de la Nación'),
                _buildFormItem('Fecha límite', '25 Feb 2025'),
              ],
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
                if (result != null) {
                  system.updateUploadedVoucher(result.files.single.name);
                }
              },
              child: Container(
                height: 140,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: system.uploadedVoucher != null ? () {} : null,
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Enviar comprobante'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormItem(String label, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.greyText, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(SystemProvider system, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 1,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.picture_as_pdf, color: AppTheme.roseRed, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Matrícula 2025-I', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('15 Mar 2025 · S/. 350.00', style: TextStyle(color: AppTheme.greyText, fontSize: 11)),
                    ],
                  ),
                ),
                _buildStatusBadge(PaymentStatus.validado),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdminPayments(SystemProvider system, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        children: [
          TextField(decoration: InputDecoration(hintText: 'Buscar pago...', prefixIcon: const Icon(Icons.search))),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: system.vouchers.length,
              itemBuilder: (context, index) {
                final v = system.vouchers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, color: AppTheme.mustardYellow),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Op. #${v.operationNumber}', style: const TextStyle(color: AppTheme.greyText, fontSize: 11)),
                                ],
                              ),
                            ),
                            Text('S/ ${v.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                        if (v.status == PaymentStatus.pendiente) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: OutlinedButton(onPressed: () => system.validateVoucher(v.id, PaymentStatus.validado), child: const Text('Validar', style: TextStyle(fontSize: 12)))),
                              const SizedBox(width: 12),
                              Expanded(child: OutlinedButton(onPressed: () => system.validateVoucher(v.id, PaymentStatus.rechazado), child: const Text('Rechazar', style: TextStyle(fontSize: 12, color: AppTheme.roseRed)))),
                            ],
                          ),
                        ] else
                          Padding(padding: const EdgeInsets.only(top: 12), child: _buildStatusBadge(v.status)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color = status == PaymentStatus.validado ? AppTheme.emeraldGreen : (status == PaymentStatus.rechazado ? AppTheme.roseRed : AppTheme.amberOrange);
    String text = status == PaymentStatus.validado ? 'Validado' : (status == PaymentStatus.rechazado ? 'Rechazado' : 'Pendiente');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}
