// Este é o seu arquivo password_screen.dart
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:webdeliverylegal/screen/config_screen.dart'; // Importe a tela de configurações

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  @override
  Widget build(BuildContext context) {
    // Adicione um Scaffold aqui para fornecer o Material
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digite a Senha'),
      ),
      body: Center(
        child: _buildPinPut(),
      ),
    );
  }

  Widget _buildPinPut() {
    final String defaultPin = "1234";

    return Pinput(
      onCompleted: (pin) {
        if (pin == defaultPin) {
          // A senha está correta, navegue para a tela de configurações
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConfigScreen()),
          );
        } else {
          // Senha incorreta, você pode exibir uma mensagem para o usuário
          print('Senha incorreta!');
        }
      },
    );
  }
}