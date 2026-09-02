import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/bulk_import.dart';
import '../../core/invite_helpers.dart';
import '../../core/session.dart';
import '../../models/catalog.dart';
import '../../models/user.dart';
import '../../services/department_service.dart';
import '../../services/role_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bulk_upload_button.dart';
import '../../widgets/invite_person_dialog.dart';
import '../../widgets/state_views.dart';

/// Crew List: directorio de TODAS las personas que YA TIENEN CUENTA en
/// la plataforma para este proyecto — pedido explícito del usuario
/// (2026-09-01): "los datos se tomarán de los registros o personas que
/// ya están registradas en la plataforma", con Nombre, Apellidos,
/// Departamento, Celular, Mail y si está activa o no.
///
/// Antes esta pantalla mostraba un directorio de texto libre aparte
/// (`CrewMember`, personal sin cuenta de acceso) — se reemplazó por
/// completo por la lista real de usuarios del proyecto
/// (`GET /users/project/{id}`, el mismo endpoint que ya usa "Roles del
/// Equipo"), reusando también su mismo mecanismo de invitar/cargar
/// masivo (`InvitePersonDialog` + `bulkInvitePeople`) en vez de
/// duplicarlo. Se diferencia de "Roles del Equipo" en que aquí el
/// foco es el directorio de contacto (nombre, apellidos, celular,
/// correo), no la gestión de roles/suspensión — eso sigue viviendo
/// solo en Roles del Equipo.
///
/// Quién puede agregar/cargar masivo: Administrador (1001), Director
/// (1002) y Jefe de Departamento (1003) — el permiso `invite_users` ya
/// es exactamente ese conjunto de roles, así que se reusa tal cual.
class CrewListScreen extends StatefulWidget {
  const CrewListScreen({super.key});

  @override
  State<CrewListScreen> createState() => _CrewListScreenState();
}

class _CrewListScreenState extends State<CrewListScreen> {
  late Future<List<AppUser>> _future;
  List<Department> _departamentos = [];
  List<RoleModel> _roles = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadCatalogos();
  }

  Future<List<AppUser>> _load() {
    final session = context.read<AuthSession>();
    return UserService(session.api).byProject(session.projectId ?? '');
  }

  Future<void> _loadCatalogos() async {
    final session = context.read<AuthSession>();
    try {
      final departamentos = await DepartmentService(session.api).all();
      final roles = await RoleService(session.api).all();
      if (mounted) {
        setState(() {
          _departamentos = departamentos;
          _roles = roles;
        });
      }
    } catch (_) {
      // si fallan los catálogos, el diálogo de agregar/carga masiva
      // simplemente queda sin opciones hasta que se reintente.
    }
  }

  void _reload() => setState(() => _future = _load());

  String? _departamentoNombre(String? idDepartamento) {
    if (idDepartamento == null || idDepartamento.isEmpty) return null;
    for (final d in _departamentos) {
      if (d.idDepartamento == idDepartamento) return d.nombre;
    }
    return idDepartamento;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final canManage = session.can('invite_users');

    return AppScaffold(
      title: 'Crew List',
      showBack: true,
      actions: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BulkUploadButton(onRows: _bulkInvite, onDone: _reload),
          ),
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _openInviteDialog(context),
              icon: const Icon(Icons.person_add_alt_outlined, size: 18),
              label: const Text('Agregar Persona'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.moradoTech),
            ),
          ),
      ],
      body: FutureBuilder<List<AppUser>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudo cargar el crew list.', onRetry: _reload);

          final all = snap.data ?? [];
          final filtered = _query.isEmpty
              ? all
              : all.where((u) {
                  final campos = '${u.nombre} ${u.apellido} ${_departamentoNombre(u.idDepartamento) ?? ''} ${u.msisdn ?? ''} ${u.mail}'.toLowerCase();
                  return campos.contains(_query.toLowerCase());
                }).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar por nombre, apellidos, departamento, celular o correo...',
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyView(
                          message: all.isEmpty ? 'Todavía no hay personas registradas en la plataforma.' : 'Sin resultados.',
                          icon: all.isEmpty ? Icons.badge_outlined : Icons.search_off,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // Misma regla que Roles del Equipo: por debajo
                            // de 640px la tabla de 6 columnas queda
                            // ilegible, se reemplaza por tarjetas apiladas.
                            final wide = constraints.maxWidth > 640;
                            if (wide) {
                              return Column(
                                children: [
                                  const _CrewTableHeader(),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: ListView.separated(
                                        itemCount: filtered.length,
                                        separatorBuilder: (_, __) => const Divider(height: 1),
                                        itemBuilder: (context, i) => _CrewUserRow(
                                          user: filtered[i],
                                          departamentoNombre: _departamentoNombre(filtered[i].idDepartamento),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, i) => _CrewUserCard(
                                user: filtered[i],
                                departamentoNombre: _departamentoNombre(filtered[i].idDepartamento),
                              ),
                            );
                          },
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
      builder: (_) => InvitePersonDialog(
        projectId: session.projectId ?? '',
        idClient: session.user?.idClient ?? '',
        departamentos: _departamentos,
        roles: _roles,
      ),
    );
    if (invited == true) _reload();
  }

  // Carga masiva: misma lógica compartida con Roles del Equipo (ver
  // core/invite_helpers.dart) — agregar a alguien acá SIEMPRE crea una
  // cuenta real con rol, exactamente igual que "Invitar persona" en
  // Roles del Equipo.
  Future<List<BulkRowResult>> _bulkInvite(List<Map<String, String>> rows) {
    final session = context.read<AuthSession>();
    return bulkInvitePeople(
      api: session.api,
      idProject: session.projectId ?? '',
      idClient: session.user?.idClient ?? '',
      departamentos: _departamentos,
      roles: _roles,
      rows: rows,
    );
  }
}

class _CrewTableHeader extends StatelessWidget {
  const _CrewTableHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.grisMedio, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('NOMBRE', style: style)),
          Expanded(flex: 2, child: Text('APELLIDOS', style: style)),
          Expanded(flex: 2, child: Text('DEPARTAMENTO', style: style)),
          Expanded(flex: 2, child: Text('CELULAR', style: style)),
          Expanded(flex: 3, child: Text('MAIL', style: style)),
          Expanded(flex: 1, child: Text('ACTIVO', style: style)),
        ],
      ),
    );
  }
}

class _CrewUserRow extends StatelessWidget {
  final AppUser user;
  final String? departamentoNombre;
  const _CrewUserRow({required this.user, required this.departamentoNombre});

  @override
  Widget build(BuildContext context) {
    final estado = (user.estado ?? '').toLowerCase();
    final pendiente = estado == 'pendiente';
    final suspendido = estado == 'suspendido';
    final activo = !pendiente && !suspendido;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.surfaceVariant,
                  child: Text(user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(user.nombre, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(user.apellido, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(departamentoNombre ?? '—', overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text((user.msisdn != null && user.msisdn!.isNotEmpty) ? user.msisdn! : '—', overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(user.mail, style: const TextStyle(color: AppColors.grisMedio), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 1,
            child: StatusPill(
              label: activo ? 'Activo' : (pendiente ? 'Pendiente' : 'Inactivo'),
              color: activo ? AppColors.success : (pendiente ? AppColors.warning : AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Versión en tarjeta de `_CrewUserRow` para pantallas angostas
/// (móvil): nombre+apellidos+correo apilados arriba, departamento/
/// celular/estado como chips que envuelven (`Wrap`) debajo.
class _CrewUserCard extends StatelessWidget {
  final AppUser user;
  final String? departamentoNombre;
  const _CrewUserCard({required this.user, required this.departamentoNombre});

  @override
  Widget build(BuildContext context) {
    final estado = (user.estado ?? '').toLowerCase();
    final pendiente = estado == 'pendiente';
    final suspendido = estado == 'suspendido';
    final activo = !pendiente && !suspendido;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceVariant,
                child: Text(user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                    Text(user.mail, style: const TextStyle(color: AppColors.grisMedio, fontSize: 12), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(icon: Icons.apartment_outlined, label: departamentoNombre ?? '—'),
              _InfoChip(icon: Icons.phone_outlined, label: (user.msisdn != null && user.msisdn!.isNotEmpty) ? user.msisdn! : '—'),
              StatusPill(
                label: activo ? 'Activo' : (pendiente ? 'Pendiente' : 'Inactivo'),
                color: activo ? AppColors.success : (pendiente ? AppColors.warning : AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grisMedio),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
