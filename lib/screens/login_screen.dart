import 'dart:async';
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
  final _recoveryEmailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Variables para la recuperación de contraseña premium
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  final _otpFocusNode = FocusNode();
  int _resendCountdown = 0;
  Timer? _resendTimer;

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        _resendTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _recoveryEmailController.dispose();
    _otpController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    _otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width >= 840;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), AppTheme.background],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(child: _buildBrandPanel()),
                        const SizedBox(width: 24),
                        SizedBox(width: 420, child: _buildAccessCard(auth)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildBrandPanel(compact: true),
                        const SizedBox(height: 18),
                        _buildAccessCard(auth),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel({bool compact = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 22 : 34),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.mustardYellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppTheme.navyBlue,
              size: 34,
            ),
          ),
          SizedBox(height: compact ? 18 : 28),
          Text(
            'UNAJ',
            style: TextStyle(
              fontSize: compact ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sistema de Matriculas',
            style: TextStyle(
              color: AppTheme.mustardYellow,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Gestiona pagos, cursos, historial academico y perfil estudiantil desde una sola plataforma.',
            style: TextStyle(color: AppTheme.greyText, height: 1.5),
          ),
          if (!compact) ...[
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _FeaturePill(
                  icon: Icons.verified_user_outlined,
                  text: 'Acceso seguro',
                ),
                _FeaturePill(
                  icon: Icons.badge_outlined,
                  text: 'Padron sincronizado',
                ),
                _FeaturePill(
                  icon: Icons.cloud_done_outlined,
                  text: 'Supabase listo',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccessCard(AuthProvider auth) {
    return Card(
      color: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _cardTitle(auth.recoveryStep),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _cardSubtitle(auth.recoveryStep),
              style: const TextStyle(color: AppTheme.greyText, height: 1.4),
            ),
            if (auth.recoveryStep > 0) ...[
              const SizedBox(height: 16),
              _buildStepIndicator(auth.recoveryStep),
            ],
            if (auth.recoveryMessage != null) ...[
              const SizedBox(height: 14),
              _InfoBox(message: auth.recoveryMessage!),
            ],
            const SizedBox(height: 24),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (auth.recoveryStep) {
                  0 => _buildLoginForm(auth),
                  1 => _buildEmailStep(auth),
                  2 => _buildOtpStep(auth),
                  _ => _buildNewPassStep(auth),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cardTitle(int step) {
    return switch (step) {
      1 => 'Recuperar acceso',
      2 => 'Verificar código',
      3 => 'Nueva contraseña',
      _ => 'Ingresar al sistema',
    };
  }

  String _cardSubtitle(int step) {
    return switch (step) {
      1 => 'Enviaremos un enlace o código de recuperación a tu correo institucional.',
      2 => 'Ingresa el código enviado a tu bandeja para continuar.',
      3 => 'Establece tu nueva contraseña de acceso segura para Supabase.',
      _ => 'Usa tu correo institucional para ingresar al sistema.',
    };
  }

  Widget _buildStepIndicator(int currentStep) {
    final steps = [
      {'title': 'Correo', 'icon': Icons.email_outlined},
      {'title': 'Código', 'icon': Icons.pin_outlined},
      {'title': 'Cambio', 'icon': Icons.lock_reset_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(steps.length, (index) {
          final stepNum = index + 1; // 1, 2, 3
          final isActive = stepNum == currentStep;
          final isCompleted = stepNum < currentStep;
          final color = isCompleted
              ? AppTheme.emeraldGreen
              : (isActive ? AppTheme.mustardYellow : AppTheme.greyText);

          return Expanded(
            child: Row(
              children: [
                // Icono / Círculo del paso
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.emeraldGreen.withValues(alpha: 0.15)
                        : (isActive ? AppTheme.mustardYellow.withValues(alpha: 0.15) : Colors.transparent),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : (steps[index]['icon'] as IconData),
                    size: 13,
                    color: color,
                  ),
                ),
                const SizedBox(width: 6),
                // Texto del paso
                Text(
                  steps[index]['title'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: color,
                  ),
                ),
                if (index < steps.length - 1) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppTheme.emeraldGreen : AppTheme.plomoBorde,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider auth) {
    return Column(
      key: const ValueKey('login'),
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo institucional',
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () => auth.login(
                      _emailController.text,
                      _passController.text,
                      students: context.read<SystemProvider>().students,
                    ),
            icon: auth.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login),
            label: const Text('Ingresar'),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _recoveryEmailController.text = _emailController.text;
            auth.setRecoveryStep(1);
          },
          child: const Text('Olvidé mi contraseña'),
        ),
      ],
    );
  }

  Widget _buildEmailStep(AuthProvider auth) {
    return Column(
      key: const ValueKey('email'),
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.mustardYellow.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppTheme.mustardYellow,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _recoveryEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo institucional',
            prefixIcon: Icon(Icons.mark_email_read_outlined),
            helperText: 'Ingresa el correo con el que te registraste.',
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: auth.isLoading
                ? null
                : () async {
                    if (_recoveryEmailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, ingresa tu correo institucional.')),
                      );
                      return;
                    }
                    await auth.sendRecoveryCode(_recoveryEmailController.text);
                    _startResendCountdown();
                  },
            icon: auth.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_outlined),
            label: const Text('Enviar recuperación'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => auth.setRecoveryStep(0),
          child: const Text('Volver al login'),
        ),
      ],
    );
  }

  Widget _buildPremiumOtpInput(BuildContext context) {
    return GestureDetector(
      onTap: () => _otpFocusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.01,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: TextField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (val) {
                  setState(() {});
                },
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final hasChar = index < _otpController.text.length;
              final char = hasChar ? _otpController.text[index] : '';
              final isCurrent = index == _otpController.text.length;
              final isFocused = _otpFocusNode.hasFocus;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: hasChar 
                      ? AppTheme.navyBlue.withValues(alpha: 0.2) 
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent && isFocused
                        ? AppTheme.mustardYellow
                        : (hasChar ? AppTheme.navyBlue : AppTheme.plomoBorde),
                    width: isCurrent && isFocused ? 2 : 1,
                  ),
                  boxShadow: isCurrent && isFocused
                      ? [
                          BoxShadow(
                            color: AppTheme.mustardYellow.withValues(alpha: 0.25),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  char,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.mustardYellow,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(AuthProvider auth) {
    return Column(
      key: const ValueKey('otp'),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2D3E8C)),
          ),
          child: Column(
            children: [
              const Icon(Icons.mark_email_read_outlined,
                  color: Color(0xFF60A5FA), size: 40),
              const SizedBox(height: 12),
              const Text(
                '¡Correo enviado!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Revisa tu bandeja de entrada.\nHemos enviado un enlace y código a:\n${_recoveryEmailController.text.trim()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFFBFDBFE), fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildPremiumOtpInput(context),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (auth.isLoading || _otpController.text.length < 6)
                ? null
                : () => auth.verifyRecoveryOtp(_otpController.text),
            icon: auth.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.verified_user_outlined),
            label: const Text('Verificar Código'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿No recibiste el código? ',
              style: TextStyle(color: AppTheme.greyText, fontSize: 12),
            ),
            _resendCountdown > 0
                ? Text(
                    'Reenviar en ${_resendCountdown}s',
                    style: const TextStyle(
                      color: AppTheme.mustardYellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  )
                : TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            await auth.sendRecoveryCode(_recoveryEmailController.text);
                            _startResendCountdown();
                          },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Reenviar ahora',
                      style: TextStyle(
                        color: AppTheme.mustardYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => auth.setRecoveryStep(0),
          child: const Text('Volver al login'),
        ),
      ],
    );
  }

  Widget _buildCriteriaCheck(String label, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isMet ? AppTheme.emeraldGreen : AppTheme.greyText,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppTheme.whiteText : AppTheme.greyText,
              fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPassStep(AuthProvider auth) {
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    final isLengthOk = newPass.length >= 6;
    final hasNumber = RegExp(r'[0-9]').hasMatch(newPass);
    final matchesConfirm = newPass.isNotEmpty && newPass == confirmPass;
    final allCriteriaMet = isLengthOk && hasNumber && matchesConfirm;

    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _newPassController,
          obscureText: !_showNewPassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Nueva contraseña',
            prefixIcon: const Icon(Icons.lock_reset_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _showNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppTheme.greyText,
              ),
              onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPassController,
          obscureText: !_showConfirmPassword,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppTheme.greyText,
              ),
              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.plomoBorde),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Requisitos de seguridad:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mustardYellow,
                ),
              ),
              const SizedBox(height: 10),
              _buildCriteriaCheck('Mínimo 6 caracteres', isLengthOk),
              _buildCriteriaCheck('Contiene al menos un número', hasNumber),
              _buildCriteriaCheck('Las contraseñas coinciden', matchesConfirm),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (auth.isLoading || !allCriteriaMet)
                ? null
                : () => auth.changePassword(_newPassController.text),
            icon: auth.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Guardar contraseña'),
          ),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeaturePill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.mustardYellow),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String message;

  const _InfoBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.mustardYellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mustardYellow.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.mustardYellow),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
