import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';

/// Flujo de recuperación: pedir correo -> código + nueva contraseña.
/// (No hay mockup específico en el set entregado; se replica el flujo
/// ya construido en el frontend React: /users/recover-password y
/// /users/reset-password.)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _mailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar acceso')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const AppIsotipo(size: 72),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _codeSent ? _resetForm() : _requestForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 8),
        const Text(
          'Ingresa tu correo y te enviaremos un código para restablecerla.',
          style: TextStyle(color: AppColors.grisMedio),
        ),
        const SizedBox(height: 20),
        AppTextField(label: 'Correo electrónico', hint: 'tucorreo@productora.com', controller: _mailCtrl, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _sendCode,
          child: _loading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Enviar código'),
        ),
      ],
    );
  }

  Widget _resetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Restablecer contraseña', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 8),
        Text('Revisa el código enviado a ${_mailCtrl.text}', style: const TextStyle(color: AppColors.grisMedio)),
        const SizedBox(height: 20),
        AppTextField(label: 'Código', hint: '000000', controller: _codeCtrl, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        AppTextField(label: 'Nueva contraseña', hint: 'Crea una nueva contraseña', controller: _passCtrl, obscureText: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _reset,
          child: _loading
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Restablecer'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: () => setState(() => _codeSent = false), child: const Text('Usar otro correo')),
      ],
    );
  }

  Future<void> _sendCode() async {
    if (_mailCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final auth = AuthService(context.read<AuthSession>().api);

    try {
      await auth.recoverPassword(_mailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _codeSent = true);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    setState(() => _loading = true);
    final auth = AuthService(context.read<AuthSession>().api);

    try {
      await auth.resetPassword(_mailCtrl.text.trim(), _codeCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada. Ya puedes iniciar sesión.')));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
