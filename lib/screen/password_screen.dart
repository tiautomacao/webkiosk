import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:webdeliverylegal/screen/config_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digite a Senha'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Senha de Administrador',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildPinPut(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinPut() {
    const String defaultPin = "1234";

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Pinput(
      controller: _pinController,
      obscureText: true,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(color: Colors.blue, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          //color: Colors.lightGreen.withOpacity(0.2),
        ),
      ),
      onCompleted: (pin) async {
        if (pin == defaultPin) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConfigScreen()),
          );
          _pinController.clear();
        } else {
          _pinController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Senha incorreta!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}