import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/shooting_day.dart';
import '../../services/shooting_day_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';

/// Mockup 10: Plan de Rodaje (versión simplificada: lista de días de
/// rodaje con su ubicación y horario; el detalle escena-por-escena del
/// mockup vive en el módulo Escenas de cada día).
class ShootingDaysScreen extends StatefulWidget {
  const ShootingDaysScreen({super.key});

  @override
  State<ShootingDaysScreen> createState() => _ShootingDaysScreenState();
}

class _ShootingDaysScreenState extends State<ShootingDaysScreen> {
  late Future<List<ShootingDay>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ShootingDay>> _load() {
    final session = context.read<AuthSession>();
    return ShootingDayService(session.api).all();
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Plan de Rodaje',
      showBack: true,
      floatingActionButton: session.can('create_scenes')
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo día'),
            )
          : null,
      body: FutureBuilder<List<ShootingDay>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const LoadingView();
          if (snap.hasError) return ErrorView(message: 'No se pudo cargar el plan de rodaje.', onRetry: _reload);
          final days = snap.data ?? [];
          if (days.isEmpty) {
            return const EmptyView(message: 'Todavía no hay días de rodaje planificados.', icon: Icons.event_note_outlined);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = days[i];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.coral,
                      child: Text(d.diaRodaje?.toString() ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Versión ${d.version}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (d.location != null)
                            Text(d.location!, style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                          if (d.horaInicio != null || d.horaFin != null)
                            Text('${d.horaInicio ?? ''} - ${d.horaFin ?? ''}',
                                style: const TextStyle(color: AppColors.grisMedio, fontSize: 12)),
                        ],
                      ),
                    ),
                    StatusPill(label: d.activo ? 'Activo' : 'Inactivo', color: d.activo ? AppColors.success : AppColors.grisMedio),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _ShootingDayFormSheet(),
      ),
    );
    if (created == true) _reload();
  }
}

class _ShootingDayFormSheet extends StatefulWidget {
  const _ShootingDayFormSheet();

  @override
  State<_ShootingDayFormSheet> createState() => _ShootingDayFormSheetState();
}

class _ShootingDayFormSheetState extends State<_ShootingDayFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _version = TextEditingController();
  final _diaRodaje = TextEditingController();
  final _location = TextEditingController();
  final _horaInicio = TextEditingController();
  final _horaFin = TextEditingController();
  final _notas = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nuevo Día de Rodaje', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppTextField(label: 'Versión', hint: 'v1', controller: _version, validator: _req)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Día de rodaje', hint: '1', controller: _diaRodaje, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 16),
            AppTextField(label: 'Ubicación', hint: 'Finca El Paraíso', controller: _location),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppTextField(label: 'Hora inicio', hint: 'HH:MM', controller: _horaInicio)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Hora fin', hint: 'HH:MM', controller: _horaFin)),
            ]),
            const SizedBox(height: 16),
            AppTextField(label: 'Notas', controller: _notas, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final session = context.read<AuthSession>();

    try {
      await ShootingDayService(session.api).create(ShootingDay(
        version: _version.text.trim(),
        diaRodaje: int.tryParse(_diaRodaje.text.trim()),
        location: _location.text.trim(),
        horaInicio: _horaInicio.text.trim().isEmpty ? null : '${_horaInicio.text.trim()}:00',
        horaFin: _horaFin.text.trim().isEmpty ? null : '${_horaFin.text.trim()}:00',
        notas: _notas.text.trim(),
      ));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
