"""
Parser heurístico de guiones (PDF -> escenas + personajes detectados).

Enfoque elegido A PROPÓSITO (decisión explícita del usuario, en vez de
mandar el guion a un modelo de IA): reglas de texto/expresiones
regulares sobre encabezados de escena ("sluglines") con el formato
estándar de guion. Es gratis y rápido, pero depende de que el PDF
tenga texto real (no escaneado) y de que el guion esté razonablemente
bien formateado — guiones con formato muy irregular pueden salir con
escenas mal separadas o personajes de menos. Documentado también en el
mensaje que ve el usuario en el frontend.

No usa ninguna librería de "parsing de guiones" porque no hay ninguna
bien mantenida en el ecosistema Python/pub — se arma a mano con
regex, que para sluglines es un patrón bastante estable y conocido.

DISEÑO IMPORTANTE (aprendido depurando un caso real): `pypdf.extract_text()`
NO reconstruye saltos de línea de forma confiable, y ese comportamiento
además CAMBIA entre versiones de pypdf — la misma librería puede
entregar "una palabra por línea" en una versión y "el encabezado pegado
al párrafo siguiente en una sola línea" en otra. Cualquier parser que
dependa de dónde pypdf decide cortar las líneas es frágil y se puede
romper con solo actualizar la librería.

Por eso este parser NO trabaja línea por línea: normaliza todo el
espacio en blanco (saltos de línea incluidos) a espacios simples,
reconstruyendo el texto de cada página como un párrafo continuo, y
busca los encabezados de escena y las intervenciones de personajes
directamente sobre ese texto continuo con `re.finditer` (sin anclar a
"^"/"$" de línea). Esto es indiferente a cómo la librería de turno
decida partir las líneas.
"""
import io
import re
from collections import OrderedDict

from pypdf import PdfReader

# ==========================================
# ENCABEZADO DE ESCENA ("slugline")
# ==========================================
# Cubre variantes reales vistas en guiones típicos:
#   "ESC 4. EXT. CARRERA SÉPTIMA / CALLES DEL CENTRO - DÍA"
#   "ESC 1. INT. REDACCIÓN EL ESPECTADOR - DÍA"
#   "INT. BAÑO- NOCHE"                (sin "ESC N.", sin espacio antes del "-")
#   "EXT./INT. AUTO - DÍA"
# Estructura: [ESC/ESCENA N.] (INT|EXT|INT/EXT|EXT/INT) LUGAR - MOMENTO
#
# El momento del día se matchea contra una lista cerrada de palabras
# conocidas (DIA, NOCHE, etc.) con límite de palabra ("\b"), en vez de
# depender de dónde termina la "línea" — así detecta el encabezado
# aunque venga pegado al texto de acción que le sigue en el mismo
# párrafo normalizado.
_MODO_VISTA_MAP = {
    "INT": "int",
    "EXT": "ext",
    "INT/EXT": "int/ext",
    "EXT/INT": "ext/int",
}

_MOMENTO_DIA_MAP = {
    "DIA": "dia",
    "DÍA": "dia",
    "NOCHE": "noche",
    "AMANECER": "amanecer",
    "ATARDECER": "atardecer",
    "ANOCHECER": "atardecer",
    "TARDE": "dia",
    "MADRUGADA": "noche",
    "DIA/NOCHE": "dia/noche",
    "DÍA/NOCHE": "dia/noche",
    "AMANECER/DIA": "amanecer/dia",
    "AMANECER/DÍA": "amanecer/dia",
}

# Ordenadas de más larga a más corta para que "DIA/NOCHE" no se corte
# en "DIA" cuando ambas son candidatas (alternancia regex prueba en orden).
_MOMENTO_PALABRAS = sorted(_MOMENTO_DIA_MAP.keys(), key=len, reverse=True)
_MOMENTO_ALTERNATIVAS = "|".join(re.escape(w) for w in _MOMENTO_PALABRAS)

#
# BUG REAL encontrado en producción (guiones con portada/acotaciones
# que contienen palabras como "Extendida" o "Internacional"): la
# versión anterior de este patrón solo tenía un \b ANTES del grupo
# INT/EXT, nunca uno DESPUÉS de las 3 letras. Eso permitía que "Ext"
# dentro de "Extendida" o "Int" dentro de "Internacional" hicieran
# match como si fueran un encabezado real, y como el grupo(2) es
# no-codicioso pero solo se detiene en el PRIMER "- MOMENTO" que
# encuentre más adelante, el "encabezado" terminaba tragándose todo el
# texto de portada/acción intermedio hasta la escena real siguiente.
# Fix: exigir \b justo después de "INT"/"EXT" (antes del punto
# opcional), así "Ext" dentro de "Extendida" no cuenta como boundary
# (la "e" que sigue es letra, no hay corte de palabra ahí) pero
# "EXT." o "EXT " sí lo son.
_SCENE_RE = re.compile(
    r"\b(?:(?:ESC|ESCENA)\.?\s*\d+\.?\s*)?"
    r"\b(INT\b\.?\s*/\s*EXT\b\.?|EXT\b\.?\s*/\s*INT\b\.?|INT\b\.?|EXT\b\.?)\s*\.?\s*"
    r"(.+?)\s*-\s*(" + _MOMENTO_ALTERNATIVAS + r")\b",
    re.IGNORECASE,
)

# Líneas/frases en mayúsculas que NO son nombres de personaje
# (encabezados de transición/técnicos comunes en guiones). Se
# descartan como candidatos.
_NOT_A_CHARACTER = {
    "CORTE A", "FUNDIDO A NEGRO", "FADE IN", "FADE OUT", "TITULO", "TÍTULO",
    "CONTINUA", "CONTINÚA", "V.O.", "O.S.", "CONT'D", "FIN", "ESCENA",
    "TITULOS", "TÍTULOS", "CREDITOS", "CRÉDITOS",
}

# Nombre de personaje (1 a 3 palabras en mayúsculas, con edad opcional
# entre paréntesis) seguido de su diálogo o una acotación — el
# indicador de "esto es un cue de personaje" es que venga justo al
# inicio del texto de la página o justo después del final de una
# oración (. ! ? o paréntesis de cierre), y que lo que sigue ya no
# esté en mayúsculas (el diálogo) o sea una acotación entre paréntesis.
_CHARACTER_CUE_RE = re.compile(
    r"(?:^|(?<=[.!?)]))\s*"
    r"([A-ZÁÉÍÓÚÑ]{2,}(?:\s[A-ZÁÉÍÓÚÑ]{2,}){0,2})"
    r"(?:\s*\(\d{1,3}\))?"
    r"\s+(?=[A-ZÁÉÍÓÚÑ][a-záéíóúñ]|\()"
)


def _normalize_modo_vista(raw: str) -> str | None:
    key = re.sub(r"\.", "", raw).strip().upper()
    key = re.sub(r"\s*/\s*", "/", key)
    return _MODO_VISTA_MAP.get(key)


def _normalize_momento_dia(raw: str) -> str | None:
    key = raw.strip().upper()
    key = re.sub(r"\s*/\s*", "/", key)
    return _MOMENTO_DIA_MAP.get(key)


def _normalize_whitespace(texto: str) -> str:
    return re.sub(r"\s+", " ", texto).strip()


def _extract_text_by_page(pdf_bytes: bytes) -> list[str]:
    reader = PdfReader(io.BytesIO(pdf_bytes))
    return [_normalize_whitespace(page.extract_text() or "") for page in reader.pages]


def _clean_character_name(nombre: str) -> str | None:
    nombre = nombre.strip()
    if nombre in _NOT_A_CHARACTER or len(nombre) < 2:
        return None
    if len(nombre.split()) > 3:
        return None
    return nombre


def parse_script(pdf_bytes: bytes) -> dict:
    """
    Devuelve:
    {
        "escenas": [
            {
                "numero_de_escena": "1",
                "encabezado": "EXT. CARRERA SÉPTIMA / CALLES DEL CENTRO - DÍA",
                "modo_vista": "ext" | None,
                "momento_dia": "dia" | None,
                "pagina": 1,
                "personajes_detectados": ["JULIÁN", "ELENA"],
            },
            ...
        ],
        "personajes_detectados": ["JULIÁN", "ELENA", "CONDUCTOR"],
    }
    """
    paginas = _extract_text_by_page(pdf_bytes)

    # Se concatena todo el documento en un solo texto continuo (en vez
    # de procesar página por página) porque una escena puede empezar
    # en una página y su diálogo/acción seguir en la siguiente — cortar
    # por página perdería esos personajes. Se guarda el offset donde
    # empieza cada página para poder reportar en qué página cae cada
    # escena detectada.
    texto_completo = ""
    offsets_pagina: list[tuple[int, int]] = []  # (offset_inicio, numero_pagina)
    for idx_pagina, texto in enumerate(paginas, start=1):
        offsets_pagina.append((len(texto_completo), idx_pagina))
        texto_completo += texto + " "

    def _pagina_de(pos: int) -> int:
        pagina = 1
        for offset, idx_pagina in offsets_pagina:
            if pos >= offset:
                pagina = idx_pagina
            else:
                break
        return pagina

    matches = list(_SCENE_RE.finditer(texto_completo))

    # Primera pasada: contar apariciones de cada personaje candidato en
    # TODO el guion, para descartar palabras en mayúsculas que
    # aparecieron una sola vez (falsos positivos de acción, no
    # personajes reales con diálogo).
    candidatos_conteo: dict[str, int] = {}
    for cm in _CHARACTER_CUE_RE.finditer(texto_completo):
        nombre = _clean_character_name(cm.group(1))
        if nombre:
            candidatos_conteo[nombre] = candidatos_conteo.get(nombre, 0) + 1

    personajes_validos = {nombre for nombre, veces in candidatos_conteo.items() if veces >= 2}

    escenas = []
    personajes_globales: "OrderedDict[str, None]" = OrderedDict()

    for idx, m in enumerate(matches):
        numero = idx + 1
        modo_vista = _normalize_modo_vista(m.group(1))
        momento_dia = _normalize_momento_dia(m.group(3))
        encabezado_limpio = _normalize_whitespace(m.group(0))

        # Personajes de esta escena: los que aparecen entre el final de
        # este encabezado y el inicio del siguiente (o el final del
        # documento, si es la última escena).
        inicio_fragmento = m.end()
        fin_fragmento = matches[idx + 1].start() if idx + 1 < len(matches) else len(texto_completo)
        fragmento = texto_completo[inicio_fragmento:fin_fragmento]

        personajes_escena: "OrderedDict[str, None]" = OrderedDict()
        for cm in _CHARACTER_CUE_RE.finditer(fragmento):
            nombre = _clean_character_name(cm.group(1))
            if nombre and nombre in personajes_validos:
                personajes_escena[nombre] = None
                personajes_globales[nombre] = None

        escenas.append({
            "numero_de_escena": str(numero),
            "encabezado": encabezado_limpio,
            "modo_vista": modo_vista,
            "momento_dia": momento_dia,
            "pagina": _pagina_de(m.start()),
            "personajes_detectados": list(personajes_escena.keys()),
        })

    return {
        "escenas": escenas,
        "personajes_detectados": list(personajes_globales.keys()),
    }
