import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webdeliverylegal/screen/password_screen.dart';
import 'package:webdeliverylegal/screen/qr_scanner_screen.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  WebViewController? _controller;
  String? _savedUrl;
  bool _isWebViewReady = false;

  @override
  void initState() {
    super.initState();
    print('KioskScreen: initState chamado');
    _loadUrlAndInitializeWebView();
  }

  Future<void> _loadUrlAndInitializeWebView() async {
    print('KioskScreen: _loadUrlAndInitializeWebView chamado');
    final prefs = await SharedPreferences.getInstance();
    String? urlFromPrefs = prefs.getString('kiosk_url');

    String urlToLoad = (urlFromPrefs != null && urlFromPrefs.isNotEmpty)
        ? urlFromPrefs
        : 'https://www.tiautomacaocomercial.com.br/';

    if (!urlToLoad.startsWith('http://') && !urlToLoad.startsWith('https://')) {
      urlToLoad = 'https://$urlToLoad';
    }

    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..clearCache() // Adicionado para evitar cache da URL antiga
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              print('KioskScreen: Carregando página: $progress%');
            },
            onPageFinished: (String url) {
              print('KioskScreen: Página carregada com sucesso: $url');
              if (mounted) {
                setState(() {
                  _isWebViewReady = true;
                  _savedUrl = urlFromPrefs;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('KioskScreen: Erro ao carregar a página: ${error.description}');
              if (mounted) {
                setState(() {
                  _isWebViewReady = true;
                  _savedUrl = urlFromPrefs;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(urlToLoad));
    } catch (e) {
      print('KioskScreen: Erro ao inicializar WebView: $e');
      if (mounted) {
        setState(() {
          _isWebViewReady = true;
          _savedUrl = urlFromPrefs;
        });
      }
    }
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

    if (mounted) {
      setState(() {
        _isWebViewReady = false;
        _controller = null; // Força reconstrução com novo controller
      });
      await _loadUrlAndInitializeWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('KioskScreen: build chamado');
    if (!_isWebViewReady || _controller == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

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
            await _saveUrlAndReload(result); // Usa o result da ConfigScreen
          } else {
            setState(() {
              _isWebViewReady = false;
              _loadUrlAndInitializeWebView(); // Recarrega com a URL atual de prefs
            });
          }
        },
        child: WebViewWidget(controller: _controller!),
      ),
      floatingActionButton: (_savedUrl == null || _savedUrl!.isEmpty)
          ? FloatingActionButton(
              onPressed: _scanQrCode,
              child: const Icon(Icons.qr_code_scanner),
            )
          : null,
    );
  }
}