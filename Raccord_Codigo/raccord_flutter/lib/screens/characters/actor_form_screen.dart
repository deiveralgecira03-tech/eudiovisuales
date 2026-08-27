import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_exception.dart';
import '../../core/session.dart';
import '../../models/character.dart';
import '../../services/character_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';

/// Ficha técnica completa del actor (medidas, continuidad física). No
/// hay mockup específico para esta pantalla; los campos siguen
/// exactamente ActorSchema del backend para que la creación funcione
/// contra la API real.
class ActorFormScreen extends StatefulWidget {
  final String? idPersonaje;
  const ActorFormScreen({super.key, this.idPersonaje});

  @override
  State<ActorFormScreen> createState() => _ActorFormScreenState();
}

class _ActorFormScreenState extends State<ActorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _fechaNacimiento = TextEditingController();
  final _tallaZapatos = TextEditingController();
  final _anchoEspalda = TextEditingController();
  final _pecho = TextEditingController();
  final _cintura = TextEditingController();
  final _cadera = TextEditingController();
  final _largoManga = TextEditingController();
  final _largoPierna = TextEditingController();
  final _colorCabello = TextEditingController();
  final _texturaCabello = TextEditingController();
  final _tipoPiel = TextEditingController();
  final _colorOjos = TextEditingController();
  final _nacionalidad = TextEditingController();
  final _alergias = TextEditingController();
  String _genero = kGenerosActor.first;
  bool _dobleRiesgo = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ficha técnica del actor',
      showBack: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('Datos personales'),
              Row(children: [
                Expanded(child: AppTextField(label: 'Nombre', controller: _nombre, validator: _req)),
                const SizedBox(width: 12),
                Expanded(child: AppTextField(label: 'Apellido', controller: _apellido, validator: _req)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: AppDropdown<String>(
                    label: 'Género',
                    value: _genero,
                    items: kGenerosActor,
                    labelBuilder: (e) => e,
                    onChanged: (v) => setState(() => _genero = v ?? _genero),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Fecha de nacimiento',
                    hint: 'AAAA-MM-DD',
                    controller: _fechaNacimiento,
                    validator: _req,
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              AppTextField(label: 'Nacionalidad', controller: _nacionalidad, validator: _req),
              const SizedBox(height: 24),
              _sectionTitle('Medidas de vestuario'),
              _measureRow(_tallaZapatos, 'Talla de zapatos', _anchoEspalda, 'Ancho de espalda'),
              const SizedBox(height: 12),
              _measureRow(_pecho, 'Pecho', _cintura, 'Cintura'),
              const SizedBox(height: 12),
              _measureRow(_cadera, 'Cadera', _largoManga, 'Largo de manga'),
              const SizedBox(height: 12),
              AppTextField(label: 'Largo de pierna', controller: _largoPierna, validator: _req),
              const SizedBox(height: 24),
              _sectionTitle('Maquillaje y caracterización'),
              _measureRow(_colorCabello, 'Color de cabello', _texturaCabello, 'Textura de cabello'),
              const SizedBox(height: 12),
              _measureRow(_tipoPiel, 'Tipo de piel', _colorOjos, 'Color de ojos'),
              const SizedBox(height: 24),
              _sectionTitle('Otros'),
              AppTextField(label: 'Alergias', controller: _alergias, maxLines: 2),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Doble de riesgo'),
                value: _dobleRiesgo,
                onChanged: (v) => setState(() => _dobleRiesgo = v),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar ficha técnica'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.moradoTech)),
      );

  Widget _measureRow(TextEditingController a, String labelA, TextEditingController b, String labelB) {
    return Row(children: [
      Expanded(child: AppTextField(label: labelA, controller: a, validator: _req)),
      const SizedBox(width: 12),
      Expanded(child: AppTextField(label: labelB, controller: b, validator: _req)),
    ]);
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fecha = DateTime.tryParse(_fechaNacimiento.text.trim());
    if (fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fecha de nacimiento inválida, usa el formato AAAA-MM-DD')),
      );
      return;
    }

    setState(() => _loading = true);
    final session = context.read<AuthSession>();

    try {
      await ActorService(session.api).create(ActorModel(
        nombre: _nombre.text.trim(),
        apellido: _apellido.text.trim(),
        genero: _genero,
        fechaDeNacimiento: fecha,
        tallaZapatos: _tallaZapatos.text.trim(),
        anchoEspalda: _anchoEspalda.text.trim(),
        pecho: _pecho.text.trim(),
        cintura: _cintura.text.trim(),
        cadera: _cadera.text.trim(),
        largoManga: _largoManga.text.trim(),
        largoPierna: _largoPierna.text.trim(),
        colorCabello: _colorCabello.text.trim(),
        texturaCabello: _texturaCabello.text.trim(),
        tipoPiel: _tipoPiel.text.trim(),
        colorOjos: _colorOjos.text.trim(),
        alergias: _alergias.text.trim(),
        nacionalidad: _nacionalidad.text.trim(),
        dobleRiesgo: _dobleRiesgo,
        idPersonaje: widget.idPersonaje,
        idProject: session.projectId,
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ficha técnica guardada')));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
