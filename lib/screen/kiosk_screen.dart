import 'package:flutter/material.dart';
import 'package:flutter_kiosk_mode/flutter_kiosk_mode.dart';
//import 'package:kiosk/kiosk.dart';
//import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Novo pacote
import 'package:permission_handler/permission_handler.dart'; // Para permissões
import 'package:webdeliverylegal/screen/password_screen.dart';
import 'package:webdeliverylegal/screen/qr_scanner_screen.dart';
import 'package:flutter/services.dart';
import 'package:webdeliverylegal/services/kiosk_service.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  InAppWebViewController? _webViewController;
  String? _savedUrl; // URL salva das prefs
  bool _isWebViewReady = false;
  final _flutterKioskMode = FlutterKioskMode.instance();

  @override
  void initState() {
    super.initState();
    print('KioskScreen: initState chamado');
    _requestCameraPermission();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky, // Modo imersivo: esconde barras e mantém escondido
    );
     _flutterKioskMode.start();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      print('KioskScreen: Permissão de câmera solicitada - Status: $status');
    }
    if (status.isGranted) {
      print('KioskScreen: Permissão de câmera concedida - Carregando WebView');
      _loadUrlAndInitializeWebView();
    } else {
      print('KioskScreen: Permissão de câmera negada - Câmera não funcionará no WebView');
      _loadUrlAndInitializeWebView(); // Continua sem permissão
      if (status.isPermanentlyDenied) {
        await openAppSettings(); // Abre configurações para o usuário conceder manualmente
      }
    }
  }

  Future<void> _loadUrlAndInitializeWebView() async {
    print('KioskScreen: _loadUrlAndInitializeWebView chamado');
    final prefs = await SharedPreferences.getInstance();
    _savedUrl = prefs.getString('kiosk_url'); // Carrega a URL salva das prefs

    String urlToLoad = (_savedUrl != null && _savedUrl!.isNotEmpty)
        ? _savedUrl!
        : 'https://www.tiautomacaocomercial.com.br/';

    if (!urlToLoad.startsWith('http://') && !urlToLoad.startsWith('https://')) {
      urlToLoad = 'https://$urlToLoad';
    }

    await _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(urlToLoad)),
    );
  }

  void _scanQrCode() async {
    print('KioskScreen: _scanQrCode chamado');
    final String? url = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (url != null && url.isNotEmpty) {
      print('KioskScreen: URL escaneada: $url');
      await _saveUrlAndReload(url);
    }
  }

  Future<void> _saveUrlAndReload(String url) async {
    print('KioskScreen: _saveUrlAndReload chamado com URL: $url');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kiosk_url', url);
    _savedUrl = url; // Atualiza a variável local

    if (mounted) {
      await _loadUrlAndInitializeWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('KioskScreen: build chamado');
    return Scaffold(
      body: GestureDetector(
        onLongPress: () async {
          print('KioskScreen: Toque longo detectado! Abrindo tela de senha...');
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordScreen()),
          );
          print('KioskScreen: Retornou da PasswordScreen com result: $result');
          if (result is String && result.isNotEmpty) {
            await _saveUrlAndReload(result);
          }
        },
        child: InAppWebView(
          initialUrlRequest: null, // Não define inicial aqui; carrega em _loadUrlAndInitializeWebView
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            clearCache: true,
            supportMultipleWindows: false,
            mediaPlaybackRequiresUserGesture: false, // Permite câmera sem clique
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
            print('KioskScreen: WebView criado');
            _loadUrlAndInitializeWebView(); // Carrega a URL inicial
          },
          onLoadStart: (controller, url) {
            print('KioskScreen: Iniciando carregamento: $url');
          },
          onLoadStop: (controller, url) {
            print('KioskScreen: Carregamento concluído: $url');
            if (mounted) {
              setState(() {
                _isWebViewReady = true;
              });
            }
          },
          onLoadError: (controller, url, code, message) {
            print('KioskScreen: Erro ao carregar: $message (Código: $code)');
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            print('KioskScreen: Solicitação de permissão do site: $resources');
            // Concede permissão para câmera e microfone
            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          },
        ),
      ),
      floatingActionButton: (_savedUrl == null || _savedUrl!.isEmpty) // Corrige a lógica do botão
          ? FloatingActionButton(
              backgroundColor: Colors.white60,
              onPressed: _scanQrCode,
              child: const Icon(Icons.qr_code_scanner, color: Color(0xFF0061fe)),
            )
          : null,
    );
  }
}