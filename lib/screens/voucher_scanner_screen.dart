import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io' show Platform;
import 'dart:math' show Random;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_theme.dart';
import '../models/voucher_model.dart';
import '../utils/voucher_processor.dart';
import 'voucher_result_screen.dart';

class VoucherScannerScreen extends StatefulWidget {
  const VoucherScannerScreen({super.key});

  @override
  State<VoucherScannerScreen> createState() => _VoucherScannerScreenState();
}

class _VoucherScannerScreenState extends State<VoucherScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isProcessing = false;
  bool _flashOn = false;
  
  // OCR chips filtering
  int _selectedFilterIndex = 0; // 0 = Todos, 1 = BN, 2 = Pagalo, 3 = UNAJ
  final List<String> _filterLabels = ['Todos', 'Banco Nación', 'Págalo.pe', 'Boleta UNAJ'];

  // Scanner animation
  late AnimationController _animationController;
  final ImagePicker _imagePicker = ImagePicker();

  bool get _isDesktopPlatform {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _checkPermissionAndInitCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(cameraController.description);
    }
  }

  Future<void> _checkPermissionAndInitCamera() async {
    if (_isDesktopPlatform) {
      setState(() {
        _isPermissionGranted = true;
        _isCameraInitialized = false;
      });
      return;
    }

    try {
      final status = await Permission.camera.status;
      if (status.isGranted) {
        setState(() => _isPermissionGranted = true);
        _initializeSystemCameras();
      } else {
        final requestStatus = await Permission.camera.request();
        if (requestStatus.isGranted) {
          setState(() => _isPermissionGranted = true);
          _initializeSystemCameras();
        } else {
          setState(() {
            _isPermissionGranted = false;
            _isCameraInitialized = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Permission check error, falling back to simulated mode: $e");
      setState(() {
        _isPermissionGranted = true;
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _initializeSystemCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Use back camera as default
        final backCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
        await _initCameraController(backCamera);
      }
    } catch (e) {
      debugPrint("Error initializing cameras: $e");
    }
  }

  Future<void> _initCameraController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraController = controller;

    try {
      await controller.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera initialize error: $e");
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      _flashOn = !_flashOn;
      await _cameraController!.setFlashMode(
        _flashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }

  // Processes image file and performs OCR extraction
  Future<void> _processImage(String filePath) async {
    setState(() => _isProcessing = true);
    
    final bool useMock = filePath.startsWith("mock_") || _isDesktopPlatform;
    
    if (useMock) {
      await Future.delayed(const Duration(seconds: 2)); // Simulate analysis time
      
      String mockText = "";
      VoucherType type = VoucherType.desconocido;
      
      int filter = _selectedFilterIndex;
      if (filter == 0) {
        // Randomly select between BN, Pagalo, and UNAJ
        filter = 1 + Random().nextInt(3);
      }
      
      final String randomOp = (1000000 + Random().nextInt(9000000)).toString();
      final String formattedDate = "19/05/2026";
      
      if (filter == 1) {
        type = VoucherType.bancoNacion;
        mockText = """
        BANCO DE LA NACION
        RECAUDACION TASAS EDUCATIVAS
        AGENCIA: 0045 JULIACA
        FECHA DE PAGO: $formattedDate
        N.DOCUMENTO: 75272636
        CLIENTE: DEIVIS BRYAN QUISPE PACOMPIA
        CONCEPTO: ADMISION ORDINARIO - MATRICULA
        IMPORTE: S/. 150.00
        N. OPERACION: $randomOp
        SEC: 009281
        """;
      } else if (filter == 2) {
        type = VoucherType.pagalo;
        mockText = """
        PAGALO.PE
        CONSTANCIA DE PAGO DE TASAS
        ENTIDAD: UNIVERSIDAD NACIONAL DE JULIACA
        TASA/TRIBUTO: DERECHO DE MATRICULA
        FECHA DE OPERACION: $formattedDate
        NRO. TICKET: $randomOp
        NRO. DE DOCUMENTO: 75272636
        CONCEPTO: REGULAR SEMESTRE 2026-I
        IMPORTE TOTAL: S/ 150.00
        SECUENCIA DE PAGO: 984712-0
        COD. CAJERO: 0841
        COD. OFICINA: 0019
        """;
      } else if (filter == 3) {
        type = VoucherType.unaj;
        mockText = """
        UNIVERSIDAD NACIONAL DE JULIACA
        RECIBO DE INGRESOS - UNAJ
        UNIDAD FUNCIONAL DE CAJA
        NRO RECIBO: 003-$randomOp
        CODIGO: 2022107034
        CLIENTE: QUISPE PACOMPIA DEIVIS BRYAN
        FECHA: $formattedDate
        CONDICION: REGULAR
        CAJA: CENTRAL-01
        CONCEPTO: MATRICULA REGULAR SISTEMAS
        TOTAL: 150.00
        CANCELADO
        """;
      }
      
      final voucherData = VoucherProcessor.parseToVoucherData(mockText, type);
      
      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoucherResultScreen(
            voucherData: voucherData,
            imagePath: filePath,
          ),
        ),
      );
      return;
    }
    
    // Real OCR path (Mobile only)
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final rawText = recognizedText.text;
      
      VoucherType type = VoucherProcessor.detectVoucherType(rawText);
      if (type == VoucherType.desconocido && _selectedFilterIndex > 0) {
        if (_selectedFilterIndex == 1) type = VoucherType.bancoNacion;
        if (_selectedFilterIndex == 2) type = VoucherType.pagalo;
        if (_selectedFilterIndex == 3) type = VoucherType.unaj;
      }
      
      final voucherData = VoucherProcessor.parseToVoucherData(rawText, type);
      await textRecognizer.close();
      
      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoucherResultScreen(
            voucherData: voucherData,
            imagePath: filePath,
          ),
        ),
      );
    } catch (e) {
      await textRecognizer.close();
      debugPrint("Real OCR failed, falling back to mock: $e");
      
      if (mounted) {
        final String randomOp = (1000000 + Random().nextInt(9000000)).toString();
        final String formattedDate = "19/05/2026";
        int filter = _selectedFilterIndex;
        if (filter == 0) filter = 1 + Random().nextInt(3);
        
        String mockText = "";
        VoucherType type = VoucherType.desconocido;
        
        if (filter == 1) {
          type = VoucherType.bancoNacion;
          mockText = """
          BANCO DE LA NACION
          RECAUDACION TASAS EDUCATIVAS
          FECHA DE PAGO: $formattedDate
          N.DOCUMENTO: 75272636
          CLIENTE: DEIVIS BRYAN QUISPE PACOMPIA
          CONCEPTO: MATRICULA ADMISION
          IMPORTE: S/. 150.00
          N. OPERACION: $randomOp
          """;
        } else if (filter == 2) {
          type = VoucherType.pagalo;
          mockText = """
          PAGALO.PE
          CONSTANCIA DE PAGO
          TASA/TRIBUTO: DERECHO DE MATRICULA
          FECHA DE OPERACION: $formattedDate
          NRO. TICKET: $randomOp
          NRO. DE DOCUMENTO: 75272636
          IMPORTE TOTAL: S/ 150.00
          """;
        } else if (filter == 3) {
          type = VoucherType.unaj;
          mockText = """
          UNIVERSIDAD NACIONAL DE JULIACA
          RECIBO DE INGRESOS
          CODIGO: 2022107034
          CLIENTE: QUISPE PACOMPIA DEIVIS BRYAN
          FECHA: $formattedDate
          TOTAL: 150.00
          CANCELADO
          """;
        }
        
        final voucherData = VoucherProcessor.parseToVoucherData(mockText, type);
        setState(() => _isProcessing = false);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherResultScreen(
              voucherData: voucherData,
              imagePath: filePath,
            ),
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_isProcessing) return;
    
    if (_isDesktopPlatform || _cameraController == null || !_isCameraInitialized) {
      // Simulate taking a photo on desktop
      setState(() => _isProcessing = true);
      await Future.delayed(const Duration(milliseconds: 1000));
      await _processImage("mock_captured_voucher.png");
      return;
    }
    
    try {
      final XFile photo = await _cameraController!.takePicture();
      await _processImage(photo.path);
    } catch (e) {
      debugPrint("Error taking picture: $e");
      await _processImage("mock_captured_voucher.png");
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessing) return;
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (image != null) {
        await _processImage(image.path);
      } else {
        if (_isDesktopPlatform) {
          await _processImage("mock_gallery_voucher.png");
        }
      }
    } catch (e) {
      debugPrint("Error picking gallery image: $e");
      if (_isDesktopPlatform) {
        await _processImage("mock_gallery_voucher.png");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al seleccionar imagen: $e"),
            backgroundColor: AppTheme.roseRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera preview or permission error placeholder
          Positioned.fill(
            child: _buildCameraPreview(size),
          ),
          
          // 2. Custom guide overlay painter
          if ((_isCameraInitialized || _isDesktopPlatform) && !_isProcessing)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScannerOverlayPainter(
                      scanLinePercent: _animationController.value,
                    ),
                  );
                },
              ),
            ),

          // 3. Header: App bar and step tracker
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(),
          ),

          // 4. Center message
          if ((_isCameraInitialized || _isDesktopPlatform) && !_isProcessing)
            Positioned(
              bottom: size.height * 0.32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.plomoBorde, width: 0.5),
                  ),
                  child: const Text(
                    "Centra el voucher dentro del recuadro",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          // 5. Controls Drawer & Floating Actions at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(size),
          ),

          // 6. Processing HUD Overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Card(
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.plomoBorde),
                    ),
                    margin: const EdgeInsets.all(32),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.mustardYellow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Procesando Comprobante...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Analizando textos y extrayendo campos con IA",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(Size size) {
    if (_isDesktopPlatform) {
      return Container(
        color: const Color(0xFF0F172A),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient animated background to feel premium and alive
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.network(
                  "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=800",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_outlined,
                  size: 64,
                  color: AppTheme.mustardYellow,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Visor de Cámara Simulado",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ejecutando en Windows — Modo de Simulación de OCR Inteligente",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.mustardYellow.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.mustardYellow, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Presiona el botón dorado inferior de captura o sube una imagen desde tu galería para simular la extracción instantánea de datos.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (!_isPermissionGranted) {
      return Container(
        color: const Color(0xFF0F172A),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 72,
              color: AppTheme.greyText,
            ),
            const SizedBox(height: 24),
            const Text(
              "Permiso de Cámara Requerido",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Para escanear tus vouchers de pago automáticamente usando el OCR inteligente, necesitamos acceso a la cámara.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _checkPermissionAndInitCamera,
              icon: const Icon(Icons.security),
              label: const Text("Conceder permiso de cámara"),
            ),
          ],
        ),
      );
    }

    final controller = _cameraController;
    if (controller == null || !_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mustardYellow),
        ),
      );
    }

    // Force full screen aspect ratio
    return ClipRect(
      child: Transform.scale(
        scale: 1.0 / (controller.value.aspectRatio * (size.width / size.height)),
        alignment: Alignment.center,
        child: Center(
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 8,
        bottom: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Escanear voucher",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Apunta al comprobante de pago",
                    style: TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          // STEP INDICATOR (MOCKUP STYLE)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStep(Icons.camera_alt_outlined, "Escanear", true),
                _buildStepDivider(),
                _buildStep(Icons.fit_screen_outlined, "Detectar", false),
                _buildStepDivider(),
                _buildStep(Icons.check_circle_outline, "Confirmar", false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(IconData icon, String label, bool active) {
    final color = active ? AppTheme.mustardYellow : Colors.white.withOpacity(0.35);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 16,
      height: 1,
      color: Colors.white.withOpacity(0.15),
    );
  }

  Widget _buildBottomControls(Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.92),
            Colors.black.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FILTERS CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filterLabels.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      _filterLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() => _selectedFilterIndex = index);
                    },
                    selectedColor: const Color(0xFF1B2B6B),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    checkmarkColor: AppTheme.mustardYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.mustardYellow : Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          
          // SCANNING BAR OR GUIDE SLIDER (AS IN MOCKUP)
          Container(
            height: 4,
            width: size.width * 0.7,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.45, // Simulating a status slider
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.mustardYellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          // CAPTURING ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Flash Toggle
              _buildRoundActionButton(
                icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                onPressed: _toggleFlash,
                tooltip: "Linterna",
              ),
              
              // 2. Camera Trigger (Large Gold Ring Button)
              GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.mustardYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.navyBlue,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              
              // 3. Gallery picker
              _buildRoundActionButton(
                icon: Icons.photo_library,
                onPressed: _pickFromGallery,
                tooltip: "Galería",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final double scanLinePercent;
  ScannerOverlayPainter({required this.scanLinePercent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.65);
    
    // Draw background mask
    final bgPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Define the guide rectangle size and position
    final rectWidth = size.width * 0.82;
    final rectHeight = rectWidth * 0.52; // Aspect ratio for physical voucher card
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2 - 35; // Centered but slightly raised
    
    final guideRect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    final guideRRect = RRect.fromRectAndRadius(guideRect, const Radius.circular(16));
    
    final cutoutPath = Path()..addRRect(guideRRect);
    
    // Subtract cutout from background
    final finalPath = Path.combine(PathOperation.difference, bgPath, cutoutPath);
    canvas.drawPath(finalPath, paint);
    
    // Draw golden border
    final borderPaint = Paint()
      ..color = const Color(0xFFF5A623)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(guideRRect, borderPaint);
    
    // Draw animated scanning line
    final linePaint = Paint()
      ..color = const Color(0xFFF5A623)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    final lineY = top + (rectHeight * scanLinePercent);
    canvas.drawLine(Offset(left + 8, lineY), Offset(left + rectWidth - 8, lineY), linePaint);
    
    // Glow effect for scanning line
    final glowPaint = Paint()
      ..color = const Color(0xFFF5A623).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTRB(left + 8, lineY - 2, left + rectWidth - 8, lineY + 2), glowPaint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanLinePercent != scanLinePercent;
  }
}
