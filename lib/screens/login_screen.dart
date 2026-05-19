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
      backgroundColor: AppTheme.lightGrey,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.whitePuro,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.plomoBorde),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navyBlue.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, size: 64, color: AppTheme.mustardYellow),
                const SizedBox(height: 16),
                const Text(
                  'UNAJ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.navyBlue,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  'Sistema de Matrículas',
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 40),
                if (auth.recoveryStep == 0) _buildLoginForm(auth),
                if (auth.recoveryStep == 1) _buildEmailStep(auth),
                if (auth.recoveryStep == 2) _buildOtpStep(auth),
                if (auth.recoveryStep == 3) _buildNewPassStep(auth),
              ],
            ),
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
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: auth.isLoading
                ? null
                : () => auth.login(_emailController.text, _passController.text),
            child: auth.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('INGRESAR AL SISTEMA'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => auth.setRecoveryStep(1),
          child: const Text('¿Problemas con su contraseña?', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildEmailStep(AuthProvider auth) {
    return Column(
      children: [
        const Text('Recuperar Cuenta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.navyBlue)),
        const SizedBox(height: 12),
        const Text(
          'Enviaremos un código OTP a su correo institucional.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        const TextField(decoration: InputDecoration(labelText: 'Ingrese su correo')),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => auth.setRecoveryStep(2),
            child: const Text('ENVIAR CÓDIGO'),
          ),
        ),
        TextButton(
          onPressed: () => auth.setRecoveryStep(0),
          child: const Text('Regresar al login'),
        ),
      ],
    );
  }

  Widget _buildOtpStep(AuthProvider auth) {
    return Column(
      children: [
        const Text('Verificación OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.navyBlue)),
        const SizedBox(height: 12),
        const Text('Ingrese los 6 dígitos enviados.', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => SizedBox(
            width: 45,
            child: TextField(
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(counterText: '', contentPadding: EdgeInsets.zero),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => auth.setRecoveryStep(3),
            child: const Text('VERIFICAR CÓDIGO'),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPassStep(AuthProvider auth) {
    return Column(
      children: [
        const Text('Nueva Contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.navyBlue)),
        const SizedBox(height: 24),
        const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Nueva Contraseña')),
        const SizedBox(height: 16),
        const TextField(obscureText: true, decoration: InputDecoration(labelText: 'Confirmar Contraseña')),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => auth.setRecoveryStep(0),
            child: const Text('ESTABLECER CONTRASEÑA'),
          ),
        ),
      ],
    );
  }
}
