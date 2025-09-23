import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ler QR Code'),
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          // Garante que a câmera vai sempre tentar ler QR codes
          detectionSpeed: DetectionSpeed.normal,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            // Pega o valor do primeiro QR code lido
            final String? url = barcodes.first.rawValue;
            if (url != null) {
              // Retorna a URL para a tela anterior
              Navigator.pop(context, url);
            }
          }
        },
      ),
    );
  }
}