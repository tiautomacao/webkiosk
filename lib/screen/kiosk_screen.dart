import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Importe a sua tela de senha
import 'package:webdeliverylegal/screen/password_screen.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  // Variável para controlar o estado do Future
  late Future<WebViewController> _controllerFuture;

  @override
  void initState() {
    super.initState();
    // Inicializa o Future no initState
    _controllerFuture = _loadUrlAndInitializeWebView();
  }

  // Função para carregar a URL e inicializar o WebView
  Future<WebViewController> _loadUrlAndInitializeWebView() async {
    final prefs = await SharedPreferences.getInstance();
    final String savedUrl = prefs.getString('kiosk_url') ?? 'https://www.google.com';

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
      ..loadRequest(Uri.parse(savedUrl));
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onLongPress: () {
          print('Toque longo detectado! Abrindo tela de senha...');
          // Navega para a tela de senha e usa o .then()
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PasswordScreen()),
          ).then((_) {
            // Este bloco será executado quando a PasswordScreen for fechada.
            setState(() {
              // Re-inicializa o Future para recarregar a URL
              _controllerFuture = _loadUrlAndInitializeWebView();
            });
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
    );
  }
}