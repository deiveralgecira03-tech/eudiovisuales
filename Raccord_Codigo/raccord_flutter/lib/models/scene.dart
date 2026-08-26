import '../core/json_utils.dart';

const kModosVista = ['int', 'ext', 'int/ext', 'ext/int'];
const kMomentosDia = ['dia', 'noche', 'amanecer', 'atardecer', 'amanecer/dia', 'dia/noche'];
const kEstadosEscena = ['Pendiente', 'En proceso', 'Finalizada'];

class Scene {
  final String? idEscena;
  final String numeroDeEscena;
  final String encabezado;
  final String? descripcion;
  final String? idGuion;
  final String? modoVista;
  final String? momentoDia;
  final String? ciudad;
  final int? pagina;
  final DateTime? fechaDeGrabacion;
  final int? diaDramatico;
  final String? idRodaje;
  final String? idDesglose;
  final String estado;

  // Datos PROPIOS del Plan de Rodaje (no de la escena narrativa) — se
  // editan desde esa pantalla, no desde el editor general de Escenas.
  // Ver app/models/scene_model.py y sql/007_plan_rodaje_datos_propios.sql.
  final String? locacionRodaje;
  final String? tiempoEstimado;
  final String? horaInicioRodaje; // "HH:MM:SS" (formato hora backend)
  final String? notasRodaje;
  final int? ordenRodaje;

  Scene({
    this.idEscena,
    required this.numeroDeEscena,
    required this.encabezado,
    this.descripcion,
    this.idGuion,
    this.modoVista,
    this.momentoDia,
    this.ciudad,
    this.pagina,
    this.fechaDeGrabacion,
    this.diaDramatico,
    this.idRodaje,
    this.idDesglose,
    this.estado = 'Pendiente',
    this.locacionRodaje,
    this.tiempoEstimado,
    this.horaInicioRodaje,
    this.notasRodaje,
    this.ordenRodaje,
  });

  String get modoYMomento {
    final parts = <String>[];
    if (modoVista != null) parts.add(modoVista!.toUpperCase());
    if (momentoDia != null) parts.add(momentoDia!);
    return parts.join(' · ');
  }

  factory Scene.fromJson(Map<String, dynamic> json) {
    final fecha = asString(pick(json, ['fecha_de_grabacion']));
    return Scene(
      idEscena: asString(pick(json, ['id_escena'])),
      numeroDeEscena: asString(pick(json, ['numero_de_escena'])) ?? '',
      encabezado: asString(pick(json, ['encabezado'])) ?? '',
      descripcion: asString(pick(json, ['descripcion'])),
      idGuion: asString(pick(json, ['id_guion'])),
      modoVista: asString(pick(json, ['modo_vista'])),
      momentoDia: asString(pick(json, ['momento_dia'])),
      ciudad: asString(pick(json, ['ciudad'])),
      pagina: asInt(pick(json, ['pagina'])),
      fechaDeGrabacion: fecha != null ? DateTime.tryParse(fecha) : null,
      diaDramatico: asInt(pick(json, ['dia_dramatico'])),
      idRodaje: asString(pick(json, ['id_rodaje'])),
      idDesglose: asString(pick(json, ['id_desglose'])),
      estado: asString(pick(json, ['estado'])) ?? 'Pendiente',
      locacionRodaje: asString(pick(json, ['locacion_rodaje'])),
      tiempoEstimado: asString(pick(json, ['tiempo_estimado'])),
      horaInicioRodaje: asString(pick(json, ['hora_inicio_rodaje'])),
      notasRodaje: asString(pick(json, ['notas_rodaje'])),
      ordenRodaje: asInt(pick(json, ['orden_rodaje'])),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'numero_de_escena': numeroDeEscena,
        'encabezado': encabezado,
        if (descripcion != null && descripcion!.isNotEmpty) 'descripcion': descripcion,
        if (idGuion != null) 'id_guion': idGuion,
        if (modoVista != null) 'modo_vista': modoVista,
        if (momentoDia != null) 'momento_dia': momentoDia,
        if (ciudad != null && ciudad!.isNotEmpty) 'ciudad': ciudad,
        if (pagina != null) 'pagina': pagina,
        if (fechaDeGrabacion != null)
          'fecha_de_grabacion': fechaDeGrabacion!.toIso8601String().split('T').first,
        if (diaDramatico != null) 'dia_dramatico': diaDramatico,
        if (idRodaje != null && idRodaje!.isNotEmpty) 'id_rodaje': idRodaje,
        if (idDesglose != null && idDesglose!.isNotEmpty) 'id_desglose': idDesglose,
        'estado': estado,
        if (locacionRodaje != null && locacionRodaje!.isNotEmpty) 'locacion_rodaje': locacionRodaje,
        if (tiempoEstimado != null && tiempoEstimado!.isNotEmpty) 'tiempo_estimado': tiempoEstimado,
        if (horaInicioRodaje != null && horaInicioRodaje!.isNotEmpty) 'hora_inicio_rodaje': horaInicioRodaje,
        if (notasRodaje != null && notasRodaje!.isNotEmpty) 'notas_rodaje': notasRodaje,
        if (ordenRodaje != null) 'orden_rodaje': ordenRodaje,
      };
}
