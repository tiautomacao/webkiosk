// kiosk_screen.dart
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
    _loadUrlAndInitializeWebView();
  }

  Future<void> _loadUrlAndInitializeWebView() async {
    final prefs = await SharedPreferences.getInstance();
    String? urlFromPrefs = prefs.getString('kiosk_url');

    String urlToLoad = (urlFromPrefs != null && urlFromPrefs.isNotEmpty)
        ? urlFromPrefs
        : 'https://www.tiautomacaocomercial.com.br/';

    if (!urlToLoad.startsWith('http://') && !urlToLoad.startsWith('https://')) {
      urlToLoad = 'https://$urlToLoad';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageFinished: (String url) {
            print('Página carregada com sucesso: $url');
            if (mounted) {
              setState(() {
                _isWebViewReady = true;
                _savedUrl = urlFromPrefs;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('Erro ao carregar a página: ${error.description}');
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
  }

  void _scanQrCode() async {
    final String? url = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (url != null && url.isNotEmpty) {
      _saveUrlAndReload(url);
    }
  }

  void _saveUrlAndReload(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kiosk_url', url);

    setState(() {
      _isWebViewReady = false;
      _loadUrlAndInitializeWebView();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          print('Toque longo detectado! Abrindo tela de senha...');
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordScreen()),
          );
          setState(() {
            _isWebViewReady = false;
            _loadUrlAndInitializeWebView();
          });
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