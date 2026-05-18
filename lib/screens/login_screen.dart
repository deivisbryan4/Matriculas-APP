import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, size: 60, color: AppTheme.mustardYellow),
              const SizedBox(height: 16),
              const Text(
                'UNAJ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.navyBlue,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Sistema de Matrícula',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 32),
              if (auth.recoveryStep == 0) _buildLoginForm(auth),
              if (auth.recoveryStep == 1) _buildEmailStep(auth),
              if (auth.recoveryStep == 2) _buildOtpStep(auth),
              if (auth.recoveryStep == 3) _buildNewPassStep(auth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider auth) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Correo Institucional',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => auth.login(_emailController.text, _passController.text),
            child: const Text('INGRESAR'),
          ),
        ),
        TextButton(
          onPressed: () => auth.setRecoveryStep(1),
          child: const Text('¿Olvidó su contraseña?', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildEmailStep(AuthProvider auth) {
    return Column(
      children: [
        const Text('Recuperar Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Ingrese su correo para enviar el código OTP.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        const SizedBox(height: 16),
        TextField(decoration: const InputDecoration(labelText: 'Correo')),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => auth.setRecoveryStep(2),
          child: const Text('CONTINUAR'),
        ),
        TextButton(onPressed: () => auth.setRecoveryStep(0), child: const Text('Volver')),
      ],
    );
  }

  Widget _buildOtpStep(AuthProvider auth) {
    return Column(
      children: [
        const Text('Verificación OTP', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => SizedBox(
            width: 35,
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              decoration: const InputDecoration(counterText: ''),
            ),
          )),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => auth.setRecoveryStep(3),
          child: const Text('VERIFICAR'),
        ),
      ],
    );
  }

  Widget _buildNewPassStep(AuthProvider auth) {
    return Column(
      children: [
        const Text('Nueva Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Nueva Clave')),
        const SizedBox(height: 16),
        TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar Clave')),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => auth.setRecoveryStep(0),
          child: const Text('RESTABLECER'),
        ),
      ],
    );
  }
}
