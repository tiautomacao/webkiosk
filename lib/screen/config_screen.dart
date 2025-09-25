import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:flutter_autostart/flutter_autostart.dart';
import 'package:webdeliverylegal/screen/kiosk_screen.dart';
import 'package:webdeliverylegal/screen/qr_scanner_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late final _urlController = TextEditingController();
  bool _isLockedModeEnabled = false;
  bool _isFocusModeEnabled = false;
  final _autostart = FlutterAutostart();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50, // Torna o botão maior
              child: ElevatedButton.icon(
                onPressed: _scanQrCode,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Ler QR Code', 
                style: TextStyle(
                  color: Color(0xFF0061fe)
                )),
                style: ElevatedButton.styleFrom(
                  iconColor: Color(0xFF0061fe)
                  
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL da loja',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Modo Bloqueado'),
              value: _isLockedModeEnabled,
              activeColor: Color(0xFF0061fe),
              onChanged: (bool value) {
                setState(() {
                  _isLockedModeEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Modo Foco'),
              value: _isFocusModeEnabled,
              activeColor: Color(0xFF0061fe),
              onChanged: (bool value) {
                setState(() {
                  _isFocusModeEnabled = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _showConfirmDialog,
              child: const Text('Salvar Configurações', 
              style: TextStyle(
                color: Color(0xFF0061fe)
              ),),
            ),
          ],
        ),
      ),
    );
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('kiosk_url') ?? '';
    _urlController.text = url;
    setState(() {
      _isLockedModeEnabled = prefs.getBool('is_locked_mode_enabled') ?? false;
      _isFocusModeEnabled = prefs.getBool('is_focus_mode_enabled') ?? false;
    });
  }

  void _scanQrCode() async {
    final String? url = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (url != null && url.isNotEmpty) {
      setState(() {
        _urlController.text = url;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL do QR Code lida e adicionada!')),
      );
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Deseja salvar as configurações e reiniciar o aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSettingsAndExit();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _saveSettingsAndExit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kiosk_url', _urlController.text);
    await prefs.setBool('is_locked_mode_enabled', _isLockedModeEnabled);
    await prefs.setBool('is_focus_mode_enabled', _isFocusModeEnabled);
    print('Configurações salvas!');

    if (_isLockedModeEnabled) {
      await startKioskMode();
    } else {
      await stopKioskMode();
    }
    
    if (_isFocusModeEnabled) {
      _autostart.showAutoStartPermissionSettings();
    }
    
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}