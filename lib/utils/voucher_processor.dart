import 'dart:math';
import '../models/voucher_model.dart';

class VoucherProcessor {
  /// Detects the type of voucher based on presence of keywords.
  static VoucherType detectVoucherType(String rawText) {
    final text = rawText.toUpperCase();

    // Check Boleta UNAJ
    if (text.contains("UNIVERSIDAD NACIONAL DE JULIACA") ||
        text.contains("RECIBO DE INGRESOS") ||
        text.contains("UNIDAD FUNCIONAL DE CAJA") ||
        text.contains("UNAJ")) {
      return VoucherType.unaj;
    }

    // Check Págalo.pe
    if (text.contains("CONSTANCIA DE PAGO DE TASAS") ||
        text.contains("PAGALO.PE") ||
        text.contains("NRO. TICKET")) {
      return VoucherType.pagalo;
    }

    // Check Banco de la Nación
    if (text.contains("BANCO DE LA NACION") ||
        text.contains("RECAUDACION TASAS EDUCATIVAS") ||
        text.contains("ADMISION")) {
      return VoucherType.bancoNacion;
    }

    return VoucherType.desconocido;
  }

  /// Helper to clean raw text and split it into clean, non-empty lines.
  static List<String> preprocessText(String rawText) {
    return rawText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Helper to find a value that appears immediately after a specific keyword/label.
  /// Handles cases where the label and value are on the same line (separated by a colon, space, etc.)
  /// or where the value appears on the subsequent lines.
  static String findValueAfterLabel(List<String> lines, String label, {bool caseInsensitive = true}) {
    final searchLabel = caseInsensitive ? label.toUpperCase() : label;

    for (int i = 0; i < lines.length; i++) {
      final currentLine = caseInsensitive ? lines[i].toUpperCase() : lines[i];

      if (currentLine.contains(searchLabel)) {
        // Option 1: Value is on the same line after a colon ':'
        if (lines[i].contains(':')) {
          final parts = lines[i].split(':');
          if (parts.length > 1) {
            final possibleVal = parts.sublist(1).join(':').trim();
            if (possibleVal.isNotEmpty) return possibleVal;
          }
        }

        // Option 2: Value is on the same line after the label itself
        final labelIdx = currentLine.indexOf(searchLabel);
        final afterLabel = lines[i].substring(labelIdx + label.length).trim();
        // Clean leading symbols like colons, dashes, etc.
        final cleanAfterLabel = afterLabel.replaceAll(RegExp(r'^[:\s\-=\.]+|\s+$'), '').trim();
        if (cleanAfterLabel.isNotEmpty && cleanAfterLabel.length > 2) {
          return cleanAfterLabel;
        }

        // Option 3: Value is on the next line
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1].trim();
          if (nextLine.isNotEmpty) {
            // Make sure the next line is not another label
            if (!nextLine.contains(':') && nextLine.length > 1) {
              return nextLine;
            }
          }
        }
      }
    }
    return '';
  }

  /// Extracts structured fields from the raw text for a specific [VoucherType].
  static Map<String, String> extractFields(String rawText, VoucherType type) {
    final lines = preprocessText(rawText);
    final textUpper = rawText.toUpperCase();
    final Map<String, String> fields = {};

    switch (type) {
      case VoucherType.bancoNacion:
        // 1. Nombre Cliente
        fields['nombre_cliente'] = findValueAfterLabel(lines, 'Nombre Cliente');
        if (fields['nombre_cliente']!.isEmpty) {
          fields['nombre_cliente'] = findValueAfterLabel(lines, 'Cliente');
        }

        // 2. N. Documento (DNI/etc)
        fields['n_documento'] = findValueAfterLabel(lines, 'N.Documento');
        if (fields['n_documento']!.isEmpty) {
          fields['n_documento'] = findValueAfterLabel(lines, 'Documento');
        }
        // Apply numeric cleaning for document
        fields['n_documento'] = fields['n_documento']!.replaceAll(RegExp(r'\D'), '');

        // 3. N. Operación (7 digits at the start of a line or standing alone)
        final opRegex = RegExp(r'\b(\d{7})\b');
        final opMatches = opRegex.allMatches(rawText);
        if (opMatches.isNotEmpty) {
          fields['n_operacion'] = opMatches.first.group(1) ?? '';
        } else {
          fields['n_operacion'] = '';
        }

        // 4. Fecha de Pago (DD/MM/YYYY)
        final dateRegex = RegExp(r'\b(\d{2}/\d{2}/\d{4})\b');
        final dateMatch = dateRegex.firstMatch(rawText);
        if (dateMatch != null) {
          fields['fecha_pago'] = dateMatch.group(1) ?? '';
        } else {
          fields['fecha_pago'] = findValueAfterLabel(lines, 'Fecha de Pago');
        }

        // 5. Fecha Boleta (DDMMMYYYY e.g. 22ENE2014)
        final boletaRegex = RegExp(r'\b(\d{1,2}[A-Z]{3}\d{4})\b');
        final boletaMatch = boletaRegex.firstMatch(textUpper);
        if (boletaMatch != null) {
          fields['fecha_boleta'] = boletaMatch.group(1) ?? '';
        } else {
          fields['fecha_boleta'] = '';
        }

        // 6. Importe
        fields['importe'] = findValueAfterLabel(lines, 'Importe Total');
        if (fields['importe']!.isEmpty) {
          fields['importe'] = findValueAfterLabel(lines, 'Importe');
        }
        if (fields['importe']!.isEmpty) {
          // Fallback: look for "S/." followed by a number
          final sDotRegex = RegExp(r'S/\.\s*([\d\.,]+)');
          final sDotMatch = sDotRegex.firstMatch(rawText);
          if (sDotMatch != null) {
            fields['importe'] = sDotMatch.group(1) ?? '';
          }
        }
        // Clean currency signs, only keep digits, dots and commas
        fields['importe'] = fields['importe']!.replaceAll(RegExp(r'[^0-9\.,]'), '').trim();

        // 7. Concepto
        fields['concepto'] = findValueAfterLabel(lines, 'Concepto');

        // 8. Sede
        fields['sede'] = findValueAfterLabel(lines, 'Sede');
        break;

      case VoucherType.pagalo:
        // 1. Nro Ticket
        fields['nro_ticket'] = findValueAfterLabel(lines, 'NRO. TICKET');
        fields['nro_ticket'] = fields['nro_ticket']!.replaceAll(RegExp(r'\D'), '');

        // 2. Fecha Operación
        fields['fecha_operacion'] = findValueAfterLabel(lines, 'FECHA DE OPERACION');
        if (fields['fecha_operacion']!.isEmpty) {
          fields['fecha_operacion'] = findValueAfterLabel(lines, 'FECHA DE OPERACIÓN');
        }

        // 3. Entidad
        fields['entidad'] = findValueAfterLabel(lines, 'ENTIDAD');

        // 4. Tasa/Tributo
        fields['tasa_tributo'] = findValueAfterLabel(lines, 'TASA/TRIBUTO');

        // 5. Concepto
        fields['concepto'] = findValueAfterLabel(lines, 'CONCEPTO');

        // 6. Tipo Documento
        fields['tipo_documento'] = findValueAfterLabel(lines, 'TIPO DE DOCUMENTO');

        // 7. Nro Documento
        fields['nro_documento'] = findValueAfterLabel(lines, 'NRO. DE DOCUMENTO');
        fields['nro_documento'] = fields['nro_documento']!.replaceAll(RegExp(r'\D'), '');

        // 8. Importe Total
        fields['importe_total'] = findValueAfterLabel(lines, 'IMPORTE TOTAL');
        if (fields['importe_total']!.isEmpty) {
          final sSlashRegex = RegExp(r'S/\s*([\d\.,]+)');
          final sSlashMatch = sSlashRegex.firstMatch(rawText);
          if (sSlashMatch != null) {
            fields['importe_total'] = sSlashMatch.group(1) ?? '';
          }
        }
        fields['importe_total'] = fields['importe_total']!.replaceAll(RegExp(r'[^0-9\.,]'), '').trim();

        // 9. Secuencia Pago (XXXXXX-X)
        final seqRegex = RegExp(r'\b(\d{6}-\d)\b');
        final seqMatch = seqRegex.firstMatch(rawText);
        if (seqMatch != null) {
          fields['secuencia_pago'] = seqMatch.group(1) ?? '';
        } else {
          fields['secuencia_pago'] = findValueAfterLabel(lines, 'Secuencia de pago');
        }

        // 10. Cód. Cajero
        fields['cod_cajero'] = findValueAfterLabel(lines, 'Cód. Cajero');
        if (fields['cod_cajero']!.isEmpty) {
          fields['cod_cajero'] = findValueAfterLabel(lines, 'COD. CAJERO');
        }

        // 11. Cód. Oficina
        fields['cod_oficina'] = findValueAfterLabel(lines, 'Cód. Oficina');
        if (fields['cod_oficina']!.isEmpty) {
          fields['cod_oficina'] = findValueAfterLabel(lines, 'COD. OFICINA');
        }
        break;

      case VoucherType.unaj:
        // 1. Nro Recibo (XXX-XXXX)
        final reciboRegex = RegExp(r'\b(\d{3}-\d{4})\b');
        final reciboMatch = reciboRegex.firstMatch(rawText);
        if (reciboMatch != null) {
          fields['nro_recibo'] = reciboMatch.group(1) ?? '';
        } else {
          fields['nro_recibo'] = findValueAfterLabel(lines, 'RECIBO DE INGRESOS');
        }

        // 2. Código Estudiante (10 digits)
        final studRegex = RegExp(r'\b(\d{10})\b');
        final studMatches = studRegex.allMatches(rawText);
        if (studMatches.isNotEmpty) {
          fields['codigo_estudiante'] = studMatches.first.group(1) ?? '';
        } else {
          fields['codigo_estudiante'] = findValueAfterLabel(lines, 'CODIGO');
        }

        // 3. Nombre Cliente
        fields['nombre_cliente'] = findValueAfterLabel(lines, 'CLIENTE');

        // 4. Fecha Depósito
        fields['fecha_deposito'] = findValueAfterLabel(lines, 'FECHA DEPOSITO');
        if (fields['fecha_deposito']!.isEmpty) {
          fields['fecha_deposito'] = findValueAfterLabel(lines, 'FECHA');
        }

        // 5. Condición
        fields['condicion'] = findValueAfterLabel(lines, 'CONDICION');

        // 6. Caja
        fields['caja'] = findValueAfterLabel(lines, 'CAJA');

        // 7. Código Trámite
        fields['codigo_tramite'] = findValueAfterLabel(lines, 'CODIGO TRAMITE');
        if (fields['codigo_tramite']!.isEmpty) {
          fields['codigo_tramite'] = findValueAfterLabel(lines, 'CONCEPTO');
        }

        // 8. Concepto
        fields['concepto'] = findValueAfterLabel(lines, 'CONCEPTO');
        if (fields['concepto']!.isEmpty) {
          fields['concepto'] = findValueAfterLabel(lines, 'TRAMITE');
        }

        // 9. Monto
        fields['monto'] = findValueAfterLabel(lines, 'TOTAL');
        if (fields['monto']!.isEmpty) {
          fields['monto'] = findValueAfterLabel(lines, 'TOTAL A PAGAR');
        }
        if (fields['monto']!.isEmpty) {
          final totalRegex = RegExp(r'(?:TOTAL|S/\.)\s*([\d\.,]+)');
          final totalMatch = totalRegex.firstMatch(textUpper);
          if (totalMatch != null) {
            fields['monto'] = totalMatch.group(1) ?? '';
          }
        }
        fields['monto'] = fields['monto']!.replaceAll(RegExp(r'[^0-9\.,]'), '').trim();

        // 10. Estado (Detect CANCELADO)
        if (textUpper.contains('CANCELADO')) {
          fields['estado'] = 'CANCELADO';
        } else {
          fields['estado'] = 'PENDIENTE';
        }
        break;

      default:
        // Desconocido
        break;
    }

    return fields;
  }

  /// Calculates the confidence rate based on the percentage of expected fields successfully extracted.
  static double calculateConfidence(Map<String, String> extractedFields, VoucherType type) {
    if (type == VoucherType.desconocido || extractedFields.isEmpty) {
      return 0.0;
    }

    int expectedFields = 0;
    switch (type) {
      case VoucherType.bancoNacion:
        expectedFields = 8;
        break;
      case VoucherType.pagalo:
        expectedFields = 11;
        break;
      case VoucherType.unaj:
        expectedFields = 10;
        break;
      default:
        expectedFields = 1;
    }

    int foundFields = 0;
    extractedFields.forEach((key, value) {
      if (value.trim().isNotEmpty) {
        foundFields++;
      }
    });

    // Provide a baseline confidence of at least 30% if we matched keywords
    final basePercentage = (foundFields / expectedFields) * 100.0;
    return min(100.0, max(30.0, basePercentage));
  }

  /// Convert string format parsed values into structured [VoucherData]
  static VoucherData parseToVoucherData(String rawText, VoucherType type) {
    final fields = extractFields(rawText, type);
    final confidence = calculateConfidence(fields, type);

    String nroOp = '';
    String nroDoc = '';
    String client = '';
    String date = '';
    double amt = 0.0;
    String concept = '';
    String status = 'PENDIENTE';

    if (type == VoucherType.bancoNacion) {
      nroOp = fields['n_operacion'] ?? '';
      nroDoc = fields['n_documento'] ?? '';
      client = fields['nombre_cliente'] ?? '';
      date = fields['fecha_pago'] ?? '';
      amt = double.tryParse(fields['importe'] ?? '') ?? 0.0;
      concept = fields['concepto'] ?? '';
    } else if (type == VoucherType.pagalo) {
      nroOp = fields['nro_ticket'] ?? '';
      nroDoc = fields['nro_documento'] ?? '';
      client = ''; // Pagalo.pe usually has document number but sometimes student name isn't prominent
      date = fields['fecha_operacion'] ?? '';
      amt = double.tryParse(fields['importe_total'] ?? '') ?? 0.0;
      concept = fields['concepto'] ?? '';
    } else if (type == VoucherType.unaj) {
      nroOp = fields['nro_recibo'] ?? '';
      nroDoc = fields['codigo_estudiante'] ?? '';
      client = fields['nombre_cliente'] ?? '';
      date = fields['fecha_deposito'] ?? '';
      amt = double.tryParse(fields['monto'] ?? '') ?? 0.0;
      concept = fields['concepto'] ?? '';
      status = fields['estado'] ?? 'PENDIENTE';
    }

    String typeStr = 'DESCONOCIDO';
    if (type == VoucherType.bancoNacion) typeStr = 'BANCO_NACION';
    if (type == VoucherType.pagalo) typeStr = 'PAGALO';
    if (type == VoucherType.unaj) typeStr = 'UNAJ';

    return VoucherData(
      tipo: typeStr,
      nroOperacion: nroOp,
      nroDocumento: nroDoc,
      nombreCliente: client,
      fechaPago: date,
      monto: amt,
      concepto: concept,
      rawText: rawText,
      confianza: confidence,
      escaneadoEn: DateTime.now(),
      estado: status,
    );
  }
}
