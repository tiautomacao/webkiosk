import 'package:flutter/material.dart';
import 'package:webdeliverylegal/services/kiosk_service.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final KioskService _kioskService = KioskService();
    _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {

        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          print('Página carregada com sucesso: $url');
        },
        onHttpError: (HttpResponseError){},
        onWebResourceError: (WebResourceError error){
                print('''
        Erro ao carregar a página:
          Código do Erro: ${error.errorCode}
          Descrição: ${error.description}
          URL: ${error.url}
      ''');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (!request.url.startsWith('https://webcabofrio-rj.dvstore.com.br')){
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://qrcode.dvstore.com.br/qrcode/eyJwcmVmaXgiOiJxcmNvZGUiLCJjb2RlIjoiaUVpSzRZdERmTUR2Vk5lTjY1dnJxUDltIiwiY29tcGFueV9pZCI6IjJjMzY0MjVmLTc5MTMtNDE2My04MzY2LTViZTE1MDM2MWI0YiJ9'));
    _kioskService.entrarModoKiosk();
    }
    //


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}