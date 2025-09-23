// Seu arquivo kiosk_screen.dart

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
  late Future<WebViewController> _controllerFuture;
  // A URL salva será inicializada como null, para indicar que ainda não foi carregada.
  String? _savedUrl;

  @override
  void initState() {
    super.initState();
    _controllerFuture = _loadUrlAndInitializeWebView();
  }

  Future<WebViewController> _loadUrlAndInitializeWebView() async {
    final prefs = await SharedPreferences.getInstance();
    String? urlFromPrefs = prefs.getString('kiosk_url');

    // Atualiza a variável de estado com a URL carregada
    setState(() {
      _savedUrl = urlFromPrefs;
    });

    String urlToLoad = (urlFromPrefs != null && urlFromPrefs.isNotEmpty)
        ? urlFromPrefs
        : 'https://www.tiautomacaocomercial.com.br/';

    // Adiciona o esquema http/https se estiver faltando
    if (!urlToLoad.startsWith('http://') && !urlToLoad.startsWith('https://')) {
      urlToLoad = 'https://$urlToLoad';
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageFinished: (String url) {
            print('Página carregada com sucesso: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Erro ao carregar a página: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(urlToLoad));

    return controller;
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
      _controllerFuture = _loadUrlAndInitializeWebView();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Adicione esta condição para exibir a tela de carregamento inicial
    if (_savedUrl == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            _controllerFuture = _loadUrlAndInitializeWebView();
          });
        },
        child: FutureBuilder<WebViewController>(
          future: _controllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return WebViewWidget(controller: snapshot.data!);
            } else if (snapshot.hasError) {
              return const Center(child: Text('Erro ao inicializar o WebView'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
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