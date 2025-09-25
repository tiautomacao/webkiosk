import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController _controller;
  bool _isProcessing = false; // Evita múltiplos pops se detectar vários barcodes

  @override
  void initState() {
    super.initState();
    print('QrScannerScreen: initState chamado - Inicializando controller');
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    print('QrScannerScreen: dispose chamado - Disposando controller');
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? url = barcodes.first.rawValue;
      if (url != null) {
        print('QrScannerScreen: QR detectado - URL: $url. Parando controller e popping tela');
        await _controller.stop(); // Pare a câmera antes de pop para evitar erros
        await Future.delayed(const Duration(milliseconds: 300)); // Delay pequeno para estabilizar
        if (mounted) {
          Navigator.of(context).pop(url);
        }
      }
    }
    _isProcessing = false;
  }

  @override
  Widget build(BuildContext context) {
    print('QrScannerScreen: build chamado');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler QR Code'),
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: _handleDetection,
      ),
    );
  }
}