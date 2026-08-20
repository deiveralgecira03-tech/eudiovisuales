import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/breakdown.dart';
import '../../services/breakdown_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/state_views.dart';

/// Mockup 11: Desglose de Producción, a nivel de una escena puntual
/// (el backend indexa el desglose general por id_escena).
class BreakdownScreen extends StatefulWidget {
  const BreakdownScreen({super.key});

  @override
  State<BreakdownScreen> createState() => _BreakdownScreenState();
}

class _BreakdownScreenState extends State<BreakdownScreen> {
  final _idEscenaCtrl = TextEditingController();
  List<DesgloseItem>? _items;
  bool _loading = false;
  String? _error;

  Future<void> _buscar() async {
    final idEscena = _idEscenaCtrl.text.trim();
    if (idEscena.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final session = context.read<AuthSession>();
    try {
      final items = await BreakdownService(session.api).itemsByScene(idEscena);
      if (!mounted) return;
      setState(() => _items = items);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'No se pudo cargar el desglose.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return AppScaffold(
      title: 'Desglose de Producción',
      showBack: true,
      floatingActionButton: session.can('manage_general_breakdown') && _idEscenaCtrl.text.trim().isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar item'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Haz clic en una escena para ver y editar los requerimientos por departamento.',
              style: TextStyle(color: AppColors.grisMedio),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _idEscenaCtrl,
                    decoration: const InputDecoration(hintText: 'ID de escena (ej: esc001)'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _loading ? null : _buscar, child: const Text('Buscar')),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading) const Expanded(child: LoadingView()),
            if (!_loading && _error != null) Expanded(child: ErrorView(message: _error!, onRetry: _buscar)),
            if (!_loading && _error == null && _items != null)
              Expanded(
                child: _items!.isEmpty
                    ? const EmptyView(message: 'Sin items de desglose para esta escena.', icon: Icons.checklist_outlined)
                    : ListView.separated(
                        itemCount: _items!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = _items![i];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                StatusPill(label: item.categoria, color: AppColors.moradoTech),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.cantidad != null ? '${item.nombreItem} (${item.cantidad})' : item.nombreItem,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
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
        child: _BreakdownItemFormSheet(idEscena: _idEscenaCtrl.text.trim()),
      ),
    );
    if (created == true) _buscar();
  }
}

class _BreakdownItemFormSheet extends StatefulWidget {
  final String idEscena;
  const _BreakdownItemFormSheet({required this.idEscena});

  @override
  State<_BreakdownItemFormSheet> createState() => _BreakdownItemFormSheetState();
}

class _BreakdownItemFormSheetState extends State<_BreakdownItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreItem = TextEditingController();
  final _cantidad = TextEditingController();
  final _notas = TextEditingController();
  String _categoria = kCategoriasDesglose.first;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Agregar item — ${widget.idEscena}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            AppDropdown<String>(
              label: 'Categoría',
              value: _categoria,
              items: kCategoriasDesglose,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _categoria = v ?? _categoria),
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Item', hint: 'Ej: Carta sellada con lacre rojo', controller: _nombreItem, validator: _req),
            const SizedBox(height: 16),
            AppTextField(label: 'Cantidad', controller: _cantidad, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            AppTextField(label: 'Notas', controller: _notas, maxLines: 2),
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
      await BreakdownService(session.api).createItem(DesgloseItem(
        idEscena: widget.idEscena,
        categoria: _categoria,
        nombreItem: _nombreItem.text.trim(),
        cantidad: int.tryParse(_cantidad.text.trim()),
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
