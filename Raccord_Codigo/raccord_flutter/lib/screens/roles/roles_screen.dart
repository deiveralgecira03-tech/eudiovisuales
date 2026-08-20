import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/catalog.dart';
import '../../models/user.dart';
import '../../services/role_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/state_views.dart';

/// Mockup 16: Roles del Equipo + Invitar persona.
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  late Future<List<AppUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AppUser>> _load() {
    final session = context.read<AuthSession>();
    return UserService(session.api).byProject(session.projectId ?? '');
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Roles del Equipo',
      showBack: true,
      actions: [
        if (session.can('invite_users'))
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openInviteDialog(context),
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Invitar persona'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.moradoTech),
            ),
          ),
      ],
      body: FutureBuilder<List<AppUser>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) {
            return ErrorView(message: 'No se pudo cargar el equipo del proyecto.', onRetry: _reload);
          }
          final users = snap.data ?? [];
          if (users.isEmpty) {
            return const EmptyView(message: 'Aún no hay personas vinculadas a este proyecto.', icon: Icons.group_outlined);
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Gestiona los departamentos y roles de cada integrante del proyecto.',
                        style: TextStyle(color: AppColors.grisMedio)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final u = users[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.surfaceVariant,
                            child: Text(u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?'),
                          ),
                          title: Text(u.nombreCompleto),
                          subtitle: Text(u.mail, style: const TextStyle(color: AppColors.grisMedio)),
                          trailing: StatusPill(
                            label: (u.estado ?? 'Activo'),
                            color: (u.estado?.toLowerCase() == 'pendiente') ? AppColors.warning : AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openInviteDialog(BuildContext context) async {
    final session = context.read<AuthSession>();
    final invited = await showDialog<bool>(
      context: context,
      builder: (_) => _InviteDialog(projectId: session.projectId ?? '', idClient: session.user?.idClient ?? 0),
    );
    if (invited == true) _reload();
  }
}

class _InviteDialog extends StatefulWidget {
  final String projectId;
  final int idClient;
  const _InviteDialog({required this.projectId, required this.idClient});

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _correosCtrl = TextEditingController();
  int? _idRol;
  bool _loading = false;
  List<RoleModel> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final session = context.read<AuthSession>();
    try {
      final roles = await RoleService(session.api).all();
      if (mounted) setState(() => _roles = roles);
    } catch (_) {
      // si /roles falla, se deja el selector vacío; el usuario puede reintentar
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invitar persona'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Correos (separados por coma)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _correosCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'persona1@correo.com, persona2@correo.com'),
            ),
            const SizedBox(height: 16),
            const Text('Rol', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _idRol,
              isExpanded: true,
              items: _roles.map((r) => DropdownMenuItem(value: r.idRol, child: Text(r.nombre))).toList(),
              onChanged: (v) => setState(() => _idRol = v),
              hint: const Text('Selecciona un rol'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Invitar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final correos = _correosCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (correos.isEmpty || _idRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa al menos un correo y un rol')));
      return;
    }

    setState(() => _loading = true);
    final session = context.read<AuthSession>();

    try {
      await RoleService(session.api).invite(
        correos: correos,
        idProject: widget.projectId,
        idClient: widget.idClient,
        idRol: _idRol!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
