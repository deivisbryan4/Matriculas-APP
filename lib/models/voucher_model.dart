enum VoucherType {
  bancoNacion,
  pagalo,
  unaj,
  desconocido,
}

class VoucherData {
  String tipo;           // BANCO_NACION | PAGALO | UNAJ
  String nroOperacion;
  String nroDocumento;
  String nombreCliente;
  String fechaPago;
  double monto;
  String concepto;
  String rawText;
  double confianza;
  DateTime escaneadoEn;
  String estado;         // PENDIENTE | VALIDADO | RECHAZADO

  VoucherData({
    required this.tipo,
    required this.nroOperacion,
    required this.nroDocumento,
    required this.nombreCliente,
    required this.fechaPago,
    required this.monto,
    required this.concepto,
    required this.rawText,
    required this.confianza,
    required this.escaneadoEn,
    this.estado = 'PENDIENTE',
  });

  VoucherType get typeEnum {
    switch (tipo) {
      case 'BANCO_NACION':
        return VoucherType.bancoNacion;
      case 'PAGALO':
        return VoucherType.pagalo;
      case 'UNAJ':
        return VoucherType.unaj;
      default:
        return VoucherType.desconocido;
    }
  }

  VoucherData copyWith({
    String? tipo,
    String? nroOperacion,
    String? nroDocumento,
    String? nombreCliente,
    String? fechaPago,
    double? monto,
    String? concepto,
    String? rawText,
    double? confianza,
    DateTime? escaneadoEn,
    String? estado,
  }) {
    return VoucherData(
      tipo: tipo ?? this.tipo,
      nroOperacion: nroOperacion ?? this.nroOperacion,
      nroDocumento: nroDocumento ?? this.nroDocumento,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      fechaPago: fechaPago ?? this.fechaPago,
      monto: monto ?? this.monto,
      concepto: concepto ?? this.concepto,
      rawText: rawText ?? this.rawText,
      confianza: confianza ?? this.confianza,
      escaneadoEn: escaneadoEn ?? this.escaneadoEn,
      estado: estado ?? this.estado,
    );
  }
}
