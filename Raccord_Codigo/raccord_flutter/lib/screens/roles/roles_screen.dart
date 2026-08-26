import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/permissions.dart';
import '../../core/session.dart';
import '../../models/catalog.dart';
import '../../models/user.dart';
import '../../services/department_service.dart';
import '../../services/role_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/bulk_upload_button.dart';
import '../../widgets/state_views.dart';
import '../../core/bulk_import.dart';

/// Mockup 16: Roles del Equipo + Invitar persona (+ Carga masiva).
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  late Future<List<AppUser>> _future;
  List<Department> _departamentos = [];
  List<RoleModel> _roles = [];

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
      // si fallan los catálogos, el diálogo de invitar/carga masiva
      // simplemente queda sin opciones hasta que se reintente.
    }
  }

  void _reload() => setState(() => _future = _load());

  bool _esPendiente(AppUser u) => (u.estado ?? '').toLowerCase() == 'pendiente';
  bool _esSuspendido(AppUser u) => (u.estado ?? '').toLowerCase() == 'suspendido';

  /// Decide si la sesión actual puede suspender/reactivar a [target]:
  /// Administrador y Director sobre todo el proyecto; Jefe de
  /// Departamento SOLO sobre gente de su propio departamento; nadie
  /// puede tocarse a sí mismo; y nadie sin `delete_admin_users` puede
  /// tocar a un Administrador. Esto es solo para decidir qué mostrar —
  /// el backend vuelve a validar todo esto igual.
  bool _puedeGestionarEstado(AuthSession session, AppUser target) {
    if (!session.can('manage_team_status')) return false;
    final me = session.user;
    if (me == null || target.idUser == me.idUser) return false;
    if (target.idRol == Roles.administrador && !session.can('delete_admin_users')) return false;
    if (me.idRol == Roles.jefeDepartamento) {
      return me.idDepartamento != null && me.idDepartamento == target.idDepartamento;
    }
    return true;
  }

  Future<void> _toggleEstado(AppUser user) async {
    final suspender = !_esSuspendido(user);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(suspender ? '¿Suspender a ${user.nombreCompleto}?' : '¿Reactivar a ${user.nombreCompleto}?'),
        content: Text(
          suspender
              ? 'No podrá volver a iniciar sesión en este proyecto hasta que lo reactives. '
                  'Toda la información que ya haya subido (escenas, fotos, desglose, etc.) se conserva intacta.'
              : 'Podrá volver a iniciar sesión en este proyecto normalmente.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              suspender ? 'Suspender' : 'Reactivar',
              style: TextStyle(color: suspender ? AppColors.error : AppColors.success),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final session = context.read<AuthSession>();
    try {
      await UserService(session.api).setEstado(user.idUser, suspender ? 'suspendido' : 'activo');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(suspender ? 'Usuario suspendido' : 'Usuario reactivado')),
        );
      }
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final canInvite = session.can('invite_users');

    return AppScaffold(
      title: 'Roles del Equipo',
      showBack: true,
      actions: [
        if (canInvite)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BulkUploadButton(
              onRows: _bulkInvite,
              onDone: _reload,
            ),
          ),
        if (canInvite)
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

          final pendientes = users.where(_esPendiente).length;
          final suspendidos = users.where(_esSuspendido).length;
          final activos = users.length - pendientes - suspendidos;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Gestiona los departamentos y roles de cada integrante del proyecto.',
                        style: TextStyle(color: AppColors.grisMedio),
                      ),
                    ),
                    _CounterPill(icon: Icons.group_outlined, label: '$activos activos', color: AppColors.success),
                    const SizedBox(width: 8),
                    _CounterPill(icon: Icons.schedule_outlined, label: '$pendientes pendientes', color: AppColors.warning),
                    if (suspendidos > 0) ...[
                      const SizedBox(width: 8),
                      _CounterPill(icon: Icons.block_outlined, label: '$suspendidos suspendidos', color: AppColors.error),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _TableHeader(),
                const SizedBox(height: 4),
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
                      itemBuilder: (context, i) => _UserRow(
                        user: users[i],
                        departamentoNombre: _departamentoNombre(users[i].idDepartamento),
                        canManageEstado: _puedeGestionarEstado(session, users[i]),
                        onToggleEstado: () => _toggleEstado(users[i]),
                      ),
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

  String? _departamentoNombre(String? idDepartamento) {
    if (idDepartamento == null || idDepartamento.isEmpty) return null;
    for (final d in _departamentos) {
      if (d.idDepartamento == idDepartamento) return d.nombre;
    }
    return idDepartamento;
  }

  Future<void> _openInviteDialog(BuildContext context) async {
    final session = context.read<AuthSession>();
    final invited = await showDialog<bool>(
      context: context,
      builder: (_) => _InviteDialog(
        projectId: session.projectId ?? '',
        idClient: session.user?.idClient ?? '',
        departamentos: _departamentos,
        roles: _roles,
      ),
    );
    if (invited == true) _reload();
  }

  // ==========================================
  // CARGA MASIVA
  // ==========================================
  // Mismas columnas que el formulario "Invitar persona": nombre
  // completo, correo electrónico, área/departamento (por nombre) y rol
  // (por nombre). Se resuelven nombres -> id acá mismo antes de llamar
  // al backend (que ya espera id_departamento/id_rol).
  Future<List<BulkRowResult>> _bulkInvite(List<Map<String, String>> rows) async {
    final session = context.read<AuthSession>();
    final results = <BulkRowResult>[];
    final pendientes = <_PendingInvite>[];

    var fila = 1;
    for (final row in rows) {
      fila++;
      final nombreCompleto = _pick(row, ['nombre completo', 'nombre_completo', 'nombre']);
      final correo = _pick(row, ['correo electrónico', 'correo electronico', 'correo', 'email', 'mail']);
      final areaTexto = _pick(row, ['área/departamento', 'area/departamento', 'área', 'area', 'departamento']);
      final rolTexto = _pick(row, ['rol']);

      if (nombreCompleto == null || nombreCompleto.isEmpty || correo == null || correo.isEmpty || areaTexto == null || areaTexto.isEmpty || rolTexto == null || rolTexto.isEmpty) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'Faltan columnas requeridas (nombre completo, correo, área, rol)'));
        continue;
      }

      final depto = _findDepartamento(areaTexto);
      if (depto == null) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'El área/departamento "$areaTexto" no existe'));
        continue;
      }

      final rol = _findRol(rolTexto);
      if (rol == null) {
        results.add(BulkRowResult(fila: fila, ok: false, detalle: 'El rol "$rolTexto" no existe'));
        continue;
      }

      pendientes.add(_PendingInvite(
        fila: fila,
        correo: correo.trim().toLowerCase(),
        item: InviteItem(nombreCompleto: nombreCompleto, mail: correo, idDepartamento: depto.idDepartamento, idRol: rol.idRol),
      ));
    }

    if (pendientes.isEmpty) return results;

    try {
      final resp = await RoleService(session.api).invite(
        invitados: pendientes.map((p) => p.item).toList(),
        idProject: session.projectId ?? '',
        idClient: session.user?.idClient ?? '',
      );

      final creados = (resp['usuarios_creados'] as List? ?? []).map((e) => (e as Map)['mail'].toString().toLowerCase()).toSet();
      final errores = <String, String>{
        for (final e in (resp['errores'] as List? ?? []))
          (e as Map)['mail'].toString().toLowerCase(): e['error'].toString(),
      };

      for (final p in pendientes) {
        if (creados.contains(p.correo)) {
          results.add(BulkRowResult(fila: p.fila, ok: true, detalle: 'Invitado correctamente'));
        } else {
          results.add(BulkRowResult(fila: p.fila, ok: false, detalle: errores[p.correo] ?? 'No se pudo invitar'));
        }
      }
    } on ApiException catch (e) {
      for (final p in pendientes) {
        results.add(BulkRowResult(fila: p.fila, ok: false, detalle: e.message));
      }
    }

    return results;
  }

  String? _pick(Map<String, String> row, List<String> posiblesLlaves) {
    for (final key in posiblesLlaves) {
      final value = row[key];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Department? _findDepartamento(String texto) {
    for (final d in _departamentos) {
      if (d.nombre.toLowerCase() == texto.toLowerCase() || d.idDepartamento == texto) return d;
    }
    return null;
  }

  RoleModel? _findRol(String texto) {
    for (final r in _roles) {
      if (r.nombre.toLowerCase() == texto.toLowerCase() || r.idRol.toString() == texto) return r;
    }
    return null;
  }
}

class _PendingInvite {
  final int fila;
  final String correo;
  final InviteItem item;
  _PendingInvite({required this.fila, required this.correo, required this.item});
}

class _CounterPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CounterPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: AppColors.grisMedio, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('NOMBRE COMPLETO', style: style)),
          Expanded(flex: 2, child: Text('ÁREA / DEPARTAMENTO', style: style)),
          Expanded(flex: 2, child: Text('ROL', style: style)),
          Expanded(flex: 1, child: Text('ESTADO', style: style)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final AppUser user;
  final String? departamentoNombre;
  final bool canManageEstado;
  final VoidCallback? onToggleEstado;
  const _UserRow({
    required this.user,
    required this.departamentoNombre,
    this.canManageEstado = false,
    this.onToggleEstado,
  });

  @override
  Widget build(BuildContext context) {
    final estado = (user.estado ?? '').toLowerCase();
    final pendiente = estado == 'pendiente';
    final suspendido = estado == 'suspendido';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
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
          ),
          Expanded(flex: 2, child: Text(departamentoNombre ?? '—', overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(Roles.label(user.idRol), overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 1,
            child: StatusPill(
              label: suspendido ? 'Suspendido' : (pendiente ? 'Pendiente' : 'Activo'),
              color: suspendido ? AppColors.error : (pendiente ? AppColors.warning : AppColors.success),
            ),
          ),
          if (canManageEstado)
            IconButton(
              icon: Icon(suspendido ? Icons.play_circle_outline : Icons.block_outlined, size: 20, color: suspendido ? AppColors.success : AppColors.error),
              tooltip: suspendido ? 'Reactivar' : 'Suspender',
              onPressed: onToggleEstado,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InviteDialog extends StatefulWidget {
  final String projectId;
  final String idClient;
  final List<Department> departamentos;
  final List<RoleModel> roles;

  const _InviteDialog({
    required this.projectId,
    required this.idClient,
    required this.departamentos,
    required this.roles,
  });

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _nombreCompleto = TextEditingController();
  final _correo = TextEditingController();
  String? _idDepartamento;
  int? _idRol;
  bool _loading = false;

  @override
  void dispose() {
    _nombreCompleto.dispose();
    _correo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.moradoTech, AppColors.azulProfundo]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NUEVA INVITACIÓN', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                        SizedBox(height: 4),
                        Text('Invitar al equipo', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: AppTextField(label: 'Nombre completo', hint: 'Nombre y apellidos', controller: _nombreCompleto)),
                      const SizedBox(width: 16),
                      Expanded(child: AppTextField(label: 'Correo electrónico', hint: 'correo@dominio.com', controller: _correo, keyboardType: TextInputType.emailAddress)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'Área / Departamento',
                          value: _idDepartamento,
                          hint: 'Selecciona área',
                          items: widget.departamentos.map((d) => d.idDepartamento).toList(),
                          labelBuilder: (id) => widget.departamentos.firstWhere((d) => d.idDepartamento == id).nombre,
                          onChanged: (v) => setState(() => _idDepartamento = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppDropdown<int>(
                          label: 'Rol',
                          value: _idRol,
                          hint: 'Selecciona rol',
                          items: widget.roles.map((r) => r.idRol).toList(),
                          labelBuilder: (id) => widget.roles.firstWhere((r) => r.idRol == id).nombre,
                          onChanged: (v) => setState(() => _idRol = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _loading ? null : _submit,
                        icon: _loading
                            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send_outlined, size: 16),
                        label: const Text('Enviar invitación'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.moradoTech),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final nombreCompleto = _nombreCompleto.text.trim();
    final correo = _correo.text.trim();

    if (nombreCompleto.isEmpty || correo.isEmpty || _idDepartamento == null || _idRol == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa nombre, correo, área y rol')));
      return;
    }

    setState(() => _loading = true);
    final session = context.read<AuthSession>();

    try {
      await RoleService(session.api).invite(
        invitados: [InviteItem(nombreCompleto: nombreCompleto, mail: correo, idDepartamento: _idDepartamento!, idRol: _idRol!)],
        idProject: widget.projectId,
        idClient: widget.idClient,
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
