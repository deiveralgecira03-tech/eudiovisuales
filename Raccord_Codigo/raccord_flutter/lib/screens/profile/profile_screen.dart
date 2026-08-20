import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/permissions.dart';
import '../../core/session.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AppUser> _future;
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _direccion = TextEditingController();
  final _msisdn = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AppUser> _load() async {
    final session = context.read<AuthSession>();
    final user = await UserService(session.api).get(session.user?.idUser ?? 0);
    _nombre.text = user.nombre;
    _apellido.text = user.apellido;
    _direccion.text = user.direccion ?? '';
    _msisdn.text = user.msisdn ?? '';
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Mi Perfil',
      showBack: true,
      body: FutureBuilder<AppUser>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) {
            return ErrorView(message: 'No se pudo cargar tu perfil.', onRetry: () => setState(() => _future = _load()));
          }
          final user = snap.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.azulProfundo,
                        child: Text(
                          user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                            Text(user.mail, style: const TextStyle(color: AppColors.grisMedio)),
                            const SizedBox(height: 4),
                            StatusPill(label: Roles.label(user.idRol), color: AppColors.moradoTech),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  AppTextField(label: 'Nombre', controller: _nombre),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Apellido', controller: _apellido),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Celular', controller: _msisdn, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  AppTextField(label: 'Dirección', controller: _direccion),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(session),
                    child: _saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Guardar cambios'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(AuthSession session) async {
    setState(() => _saving = true);
    try {
      await UserService(session.api).updatePartial(session.user?.idUser ?? 0, {
        'nombre': _nombre.text.trim(),
        'apellido': _apellido.text.trim(),
        'direccion': _direccion.text.trim(),
        'msisdn': _msisdn.text.trim(),
      });
      await session.updateUserNames(_nombre.text.trim(), _apellido.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
