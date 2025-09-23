import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late final _urlController = TextEditingController();

  bool _isLockedModeEnabled = false;
  bool _isFocusModeEnabled = false;

    @override
    void initState() {
      super.initState();
      _loadSettings();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: Padding(padding: 
      EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'URL da loja',
              border: OutlineInputBorder()
            ),
          ),
          SizedBox(height: 20),
          SwitchListTile(
            title: Text('Modo Bloqueado'),
            value: _isLockedModeEnabled,
            onChanged: (bool value){
              setState(() {
                _isLockedModeEnabled = value;
              
              });
            }
          ),
          SwitchListTile(
            title: Text('Modo Foco'),
            value: _isFocusModeEnabled,
            onChanged:(bool value){
              setState(() {
                _isFocusModeEnabled = value;
              }); 
            }
          ),
          ElevatedButton(
            onPressed: _saveSettings, // Chama a função para salvar
            child: Text('Salvar Configurações'),
          ),
        ],
        )
      )
    );
  }
  
  void _loadSettings() async {
        final prefs = await SharedPreferences.getInstance();
    
    // Carrega a URL e atualiza o controlador
    final url = prefs.getString('kiosk_url') ?? ''; // Usa '' se não houver URL
    _urlController.text = url;
    
    // Carrega o estado dos switches
    setState(() {
      _isLockedModeEnabled = prefs.getBool('is_locked_mode_enabled') ?? false;
      _isFocusModeEnabled = prefs.getBool('is_focus_mode_enabled') ?? false;
    });
  }


  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Salva a URL do controlador
    await prefs.setString('kiosk_url', _urlController.text);
    
    // Salva o estado dos switches
    await prefs.setBool('is_locked_mode_enabled', _isLockedModeEnabled);
    await prefs.setBool('is_focus_mode_enabled', _isFocusModeEnabled);
    print('Configurações salvas!');
  }

}