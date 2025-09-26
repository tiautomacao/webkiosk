
import 'package:flutter_kiosk_mode/flutter_kiosk_mode.dart';
//import 'package:kiosk/kiosk.dart';
//import 'package:kiosk_mode/kiosk_mode.dart';

class KioskService {
  final _flutterKioskMode = FlutterKioskMode.instance();
  Future<void> entrarModoKiosk() async{
    try {
      await _flutterKioskMode.start();

    }catch(error){
      print('Erro ao entrar no modo Kiosk: $error');
    }
  }
}