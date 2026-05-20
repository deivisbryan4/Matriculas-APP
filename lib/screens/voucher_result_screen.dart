import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../models/voucher_model.dart';
import '../providers.dart';

class VoucherResultScreen extends StatefulWidget {
  final VoucherData voucherData;
  final String imagePath;

  const VoucherResultScreen({
    super.key,
    required this.voucherData,
    required this.imagePath,
  });

  @override
  State<VoucherResultScreen> createState() => _VoucherResultScreenState();
}

class _VoucherResultScreenState extends State<VoucherResultScreen> {
  late VoucherData _currentData;
  
  // Controllers for editable fields
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentData = widget.voucherData;
    _initializeControllers();
  }

  void _initializeControllers() {
    // Shared fields
    _controllers['nro_operacion'] = TextEditingController(text: _currentData.nroOperacion);
    _controllers['nro_documento'] = TextEditingController(text: _currentData.nroDocumento);
    _controllers['nombre_cliente'] = TextEditingController(text: _currentData.nombreCliente);
    _controllers['fecha_pago'] = TextEditingController(text: _currentData.fechaPago);
    _controllers['monto'] = TextEditingController(text: _currentData.monto.toStringAsFixed(2));
    _controllers['concepto'] = TextEditingController(text: _currentData.concepto);
    
    // Type specific fields mapped to extra fields
    final type = _currentData.typeEnum;
    
    if (type == VoucherType.bancoNacion) {
      _controllers['sede'] = TextEditingController(
        text: _currentData.rawText.contains('Sede') 
            ? _currentData.rawText.split('Sede').last.split('\n').first.replaceAll(':', '').trim()
            : 'SEDE CENTRAL',
      );
    } else if (type == VoucherType.pagalo) {
      _controllers['entidad'] = TextEditingController(
        text: _currentData.rawText.contains('ENTIDAD')
            ? _currentData.rawText.split('ENTIDAD').last.split('\n').first.replaceAll(':', '').trim()
            : 'BANCO DE LA NACION',
      );
      _controllers['tasa_tributo'] = TextEditingController(
        text: _currentData.rawText.contains('TASA/TRIBUTO')
            ? _currentData.rawText.split('TASA/TRIBUTO').last.split('\n').first.replaceAll(':', '').trim()
            : '09970 - Notif. judicial',
      );
      _controllers['secuencia_pago'] = TextEditingController(
        text: _currentData.rawText.contains('Secuencia de pago')
            ? RegExp(r'\b\d{6}-\d\b').firstMatch(_currentData.rawText)?.group(0) ?? '037126-1'
            : '037126-1',
      );
    } else if (type == VoucherType.unaj) {
      _controllers['caja'] = TextEditingController(
        text: _currentData.rawText.contains('CAJA')
            ? _currentData.rawText.split('CAJA').last.split('\n').first.replaceAll(':', '').trim()
            : 'CAJA 01',
      );
      _controllers['condicion'] = TextEditingController(
        text: _currentData.rawText.contains('CONDICION')
            ? _currentData.rawText.split('CONDICION').last.split('\n').first.replaceAll(':', '').trim()
            : 'REGULAR',
      );
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Get color palette dynamically according to the voucher type
  Color _getBannerColor() {
    switch (_currentData.typeEnum) {
      case VoucherType.bancoNacion:
        return const Color(0xFF1B2B6B); // Deep Navy
      case VoucherType.pagalo:
        return const Color(0xFFE27C22); // Orange/Amber
      case VoucherType.unaj:
        return const Color(0xFF14B8A6); // Teal/Emerald
      default:
        return const Color(0xFF64748B); // Slate Grey
    }
  }

  String _getBannerTitle() {
    switch (_currentData.typeEnum) {
      case VoucherType.bancoNacion:
        return "Banco de la Nación — Recaudación educativa";
      case VoucherType.pagalo:
        return "Págalo.pe — Constancia de Pago de Tasas";
      case VoucherType.unaj:
        return "Boleta UNAJ — Recibo de ingresos";
      default:
        return "Comprobante Desconocido";
    }
  }

  IconData _getBannerIcon() {
    switch (_currentData.typeEnum) {
      case VoucherType.bancoNacion:
        return Icons.account_balance;
      case VoucherType.pagalo:
        return Icons.phone_android;
      case VoucherType.unaj:
        return Icons.school;
      default:
        return Icons.help_outline;
    }
  }

  Color _getConfidenceColor(double score) {
    if (score >= 85) return AppTheme.emeraldGreen;
    if (score >= 60) return AppTheme.amberOrange;
    return AppTheme.roseRed;
  }

  Future<void> _confirmAndSave() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final system = Provider.of<SystemProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final studentId = auth.currentUser?.id ?? '';
    final parsedMonto = double.tryParse(_controllers['monto']!.text) ?? _currentData.monto;
    final opNumber = _controllers['nro_operacion']!.text;

    try {
      // Execute upload to storage + insertion to Supabase database
      final success = await system.submitOcrPayment(
        studentId: studentId,
        semestreId: 1, // Defaulting to Semestre 2025-II (ID 1)
        monto: parsedMonto,
        numeroOperacion: opNumber,
        localImagePath: widget.imagePath,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (success) {
        // Advance step if we are in enrollment process
        system.setEnrollmentStep(2);
        
        // Show premium success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppTheme.plomoBorde),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.emeraldGreen,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "¡Pago Confirmado!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Tu voucher ha sido escaneado y subido con éxito. El estado se ha establecido como 'PENDIENTE' para auditoría manual de caja.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Pop dialog
                        Navigator.pop(context);
                        // Pop results screen
                        Navigator.pop(context);
                        // Pop camera scanner screen to return to payments / enrollment view
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.mustardYellow,
                        foregroundColor: AppTheme.navyBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Continuar Matrícula",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(system.errorMessage ?? "Ocurrió un error al registrar el pago."),
            backgroundColor: AppTheme.roseRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error inesperado: $e"),
            backgroundColor: AppTheme.roseRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(_currentData.confianza);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Datos extraídos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Revisión de comprobante · OCR",
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          // Simulated Step Status Tab
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.emeraldGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.check, color: AppTheme.emeraldGreen, size: 12),
                SizedBox(width: 4),
                Text(
                  "Confirmar",
                  style: TextStyle(
                    color: AppTheme.emeraldGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. BANNER DETECTADO
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: _getBannerColor().withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getBannerColor().withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getBannerColor().withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getBannerIcon(),
                                      color: _getBannerColor(),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Tipo de voucher detectado",
                                          style: TextStyle(
                                            color: _getBannerColor(),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _getBannerTitle(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // CONFIDENCE METRIC CHIP
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: confidenceColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: confidenceColor.withOpacity(0.25)),
                                    ),
                                    child: Text(
                                      "${_currentData.confianza.toStringAsFixed(0)}% conf.",
                                      style: TextStyle(
                                        color: confidenceColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // 2. LIST OF EDITABLE FIELDS
                            const Text(
                              "CAMPOS EXTRAÍDOS POR OCR (TOCA PARA EDITAR)",
                              style: TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Card(
                              color: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: AppTheme.plomoBorde),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: _buildEditableFieldsList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // 3. IMAGE PREVIEW THUMBNAIL
                            const Text(
                              "COMPROBANTE ORIGINAL",
                              style: TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  border: Border.all(color: AppTheme.plomoBorde),
                                ),
                                child: Image.file(
                                  File(widget.imagePath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 100), // Spacing for bottom floating actions
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 4. FLOATING ACTION PANEL AT THE BOTTOM
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActions(confidenceColor),
            ),

            // 5. LOADING SHADOW WHILE SAVING
            if (_isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.mustardYellow,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Subiendo comprobante a Supabase Storage...",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEditableFieldsList() {
    final type = _currentData.typeEnum;
    final List<Widget> list = [];

    // Fields are generated reactively depending on the type of voucher
    if (type == VoucherType.bancoNacion) {
      list.add(_buildTextFieldItem('nombre_cliente', Icons.person_outline, 'Nombre Cliente'));
      list.add(_buildTextFieldItem('n_documento', Icons.assignment_outlined, 'N. Documento'));
      list.add(_buildTextFieldItem('n_operacion', Icons.tag, 'N. Operación', isNumber: true, tag: 'alto'));
      list.add(_buildTextFieldItem('fecha_pago', Icons.calendar_today_outlined, 'Fecha de pago'));
      list.add(_buildTextFieldItem('monto', Icons.attach_money, 'Importe (S/.)', isNumber: true));
      list.add(_buildTextFieldItem('concepto', Icons.local_offer_outlined, 'Concepto'));
      list.add(_buildTextFieldItem('sede', Icons.place_outlined, 'Sede'));
    } else if (type == VoucherType.pagalo) {
      list.add(_buildTextFieldItem('nro_ticket', Icons.airplane_ticket_outlined, 'Nro. Ticket', isNumber: true, tag: 'alto'));
      list.add(_buildTextFieldItem('nro_documento', Icons.assignment_outlined, 'DNI', isNumber: true));
      list.add(_buildTextFieldItem('fecha_pago', Icons.calendar_today_outlined, 'Fecha'));
      list.add(_buildTextFieldItem('monto', Icons.attach_money, 'Importe total (S/)', isNumber: true));
      list.add(_buildTextFieldItem('tasa_tributo', Icons.receipt_long_outlined, 'Tasa/Tributo'));
      list.add(_buildTextFieldItem('entidad', Icons.account_balance, 'Entidad'));
      list.add(_buildTextFieldItem('secuencia_pago', Icons.tag, 'Secuencia'));
    } else if (type == VoucherType.unaj) {
      list.add(_buildTextFieldItem('nro_operacion', Icons.receipt_outlined, 'Nro. Recibo', tag: 'alto'));
      list.add(_buildTextFieldItem('nro_documento', Icons.badge_outlined, 'Código estudiante', isNumber: true));
      list.add(_buildTextFieldItem('nombre_cliente', Icons.person_outline, 'Cliente'));
      list.add(_buildTextFieldItem('fecha_pago', Icons.calendar_today_outlined, 'Fecha depósito'));
      list.add(_buildTextFieldItem('concepto', Icons.local_offer_outlined, 'Concepto'));
      list.add(_buildTextFieldItem('monto', Icons.attach_money, 'Monto (S/.)', isNumber: true));
      list.add(_buildTextFieldItem('caja', Icons.point_of_sale_outlined, 'Caja'));
      list.add(_buildTextFieldItem('condicion', Icons.info_outline, 'Estado', tag: 'CANCELADO'));
    } else {
      // Default / Desconocido list
      list.add(_buildTextFieldItem('nombre_cliente', Icons.person_outline, 'Cliente'));
      list.add(_buildTextFieldItem('nro_operacion', Icons.tag, 'N. Operación'));
      list.add(_buildTextFieldItem('monto', Icons.attach_money, 'Monto', isNumber: true));
    }

    return list;
  }

  Widget _buildTextFieldItem(
    String key,
    IconData icon,
    String label, {
    bool isNumber = false,
    String? tag,
  }) {
    final controller = _controllers[key];
    if (controller == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.greyText, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.greyText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tag == 'CANCELADO'
                        ? AppTheme.emeraldGreen.withOpacity(0.12)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: tag == 'CANCELADO'
                          ? AppTheme.emeraldGreen.withOpacity(0.3)
                          : AppTheme.plomoBorde,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tag == 'CANCELADO'
                          ? AppTheme.emeraldGreen
                          : AppTheme.mustardYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.plomoBorde),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.mustardYellow),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.roseRed),
              ),
              errorStyle: const TextStyle(fontSize: 10),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El campo es requerido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(Color confidenceColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(top: BorderSide(color: AppTheme.plomoBorde)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // CONFIDENCE LEVEL PROGRESS BAR
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppTheme.greyText, size: 16),
              const SizedBox(width: 8),
              const Text(
                "Confianza OCR",
                style: TextStyle(
                  color: AppTheme.greyText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "${_currentData.confianza.toStringAsFixed(0)}%",
                style: TextStyle(
                  color: confidenceColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _currentData.confianza / 100.0,
              child: Container(
                decoration: BoxDecoration(
                  color: confidenceColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // BUTTONS: Reescanear & Confirmar pago
          Row(
            children: [
              // Reescanear
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: _isSaving
                      ? null
                      : () {
                          // Go back to the camera screen
                          Navigator.pop(context);
                        },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    "Reescanear",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.plomoBorde),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Confirmar pago
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _confirmAndSave,
                  icon: const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.navyBlue),
                  label: const Text(
                    "Confirmar pago",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.navyBlue,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mustardYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
