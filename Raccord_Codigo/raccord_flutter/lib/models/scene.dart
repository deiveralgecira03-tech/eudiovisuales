import '../core/json_utils.dart';

const kModosVista = ['int', 'ext', 'int/ext', 'ext/int'];
const kMomentosDia = ['dia', 'noche', 'amanecer', 'atardecer', 'amanecer/dia', 'dia/noche'];

class Scene {
  final String? idEscena;
  final String numeroDeEscena;
  final String encabezado;
  final String? descripcion;
  final int? idGuion;
  final String? modoVista;
  final String? momentoDia;
  final String? ciudad;
  final int? pagina;
  final DateTime? fechaDeGrabacion;
  final int? diaDramatico;
  final String? idRodaje;
  final String? idDesglose;

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
      idGuion: asInt(pick(json, ['id_guion'])),
      modoVista: asString(pick(json, ['modo_vista'])),
      momentoDia: asString(pick(json, ['momento_dia'])),
      ciudad: asString(pick(json, ['ciudad'])),
      pagina: asInt(pick(json, ['pagina'])),
      fechaDeGrabacion: fecha != null ? DateTime.tryParse(fecha) : null,
      diaDramatico: asInt(pick(json, ['dia_dramatico'])),
      idRodaje: asString(pick(json, ['id_rodaje'])),
      idDesglose: asString(pick(json, ['id_desglose'])),
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
      };
}
