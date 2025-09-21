
import 'package:kiosk_mode/kiosk_mode.dart';

class KioskService {
  Future<void> entrarModoKiosk() async{
    try {
      await startKioskMode();

    }catch(error){
      print('Erro ao entrar no modo Kiosk: $error');
    }
  }
}