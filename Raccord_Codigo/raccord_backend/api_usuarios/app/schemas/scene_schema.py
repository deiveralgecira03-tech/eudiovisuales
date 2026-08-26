from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date, time

# Deben coincidir exactamente con los ENUM de la BD.
ModoVista = Literal["int", "ext", "int/ext", "ext/int"]
MomentoDia = Literal["dia", "noche", "amanecer", "atardecer", "amanecer/dia", "dia/noche"]
EstadoEscena = Literal["Pendiente", "En proceso", "Finalizada"]


# ==========================================
# ESCENAS
# ==========================================
# id_escena no va en el schema de creación: lo genera el trigger de la
# base de datos (esc001, esc002, ...).
class SceneSchema(BaseModel):
    numero_de_escena: str
    encabezado: str
    descripcion: Optional[str] = None
    id_guion: Optional[str] = None
    modo_vista: Optional[ModoVista] = None
    momento_dia: Optional[MomentoDia] = None
    ciudad: Optional[str] = None
    pagina: Optional[int] = None
    fecha_de_grabacion: Optional[date] = None
    dia_dramatico: Optional[int] = None
    id_rodaje: Optional[str] = None
    id_desglose: Optional[str] = None
    estado: Optional[EstadoEscena] = "Pendiente"
    # Datos propios del Plan de Rodaje (no de la escena narrativa) — ver
    # scene_model.py y sql/007_plan_rodaje_datos_propios.sql.
    locacion_rodaje: Optional[str] = None
    tiempo_estimado: Optional[str] = None
    hora_inicio_rodaje: Optional[time] = None
    notas_rodaje: Optional[str] = None
    orden_rodaje: Optional[int] = None


class SceneUpdateSchema(BaseModel):
    numero_de_escena: Optional[str] = None
    encabezado: Optional[str] = None
    descripcion: Optional[str] = None
    id_guion: Optional[str] = None
    modo_vista: Optional[ModoVista] = None
    momento_dia: Optional[MomentoDia] = None
    ciudad: Optional[str] = None
    pagina: Optional[int] = None
    fecha_de_grabacion: Optional[date] = None
    dia_dramatico: Optional[int] = None
    id_rodaje: Optional[str] = None
    id_desglose: Optional[str] = None
    estado: Optional[EstadoEscena] = None
    locacion_rodaje: Optional[str] = None
    tiempo_estimado: Optional[str] = None
    hora_inicio_rodaje: Optional[time] = None
    notas_rodaje: Optional[str] = None
    orden_rodaje: Optional[int] = None
