from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date

# Debe coincidir exactamente con el ENUM "generosex" de la BD. El valor
# 'fenemino' es el que existe realmente en Postgres (typo original del
# esquema, no un error de este archivo) — si se manda 'femenino' bien
# escrito, Postgres lo rechaza porque no es un label válido del enum.
Genero = Literal["masculino", "fenemino", "otro"]


# ==========================================
# ACTORS
# ==========================================
# id_actor no va en el schema de creación: lo genera el trigger de la
# base de datos (act1, act2, ...). id_personaje es opcional: un actor
# puede existir en el catálogo sin estar todavía asignado a un rol.
class ActorSchema(BaseModel):
    nombre: str
    apellido: str
    genero: Genero
    fecha_de_nacimiento: date

    talla_zapatos: str
    ancho_espalda: str
    pecho: str
    cintura: str
    cadera: str
    largo_manga: str
    largo_pierna: str
    talla_anillo: Optional[str] = None
    contorno_cabeza: Optional[str] = None
    contorno_cuello: Optional[str] = None

    color_cabello: str
    textura_cabello: str
    tipo_piel: str
    color_ojos: str

    alergias: Optional[str] = None
    habilidades_especiales: Optional[str] = None
    restricciones: Optional[str] = None
    comentarios_adicionales: Optional[str] = None

    nacionalidad: str
    doble_riesgo: bool

    id_personaje: Optional[str] = None
    # Obligatorio (ver sql/015_project_scoping.sql y CharacterSchema):
    # todo actor NUEVO debe quedar amarrado a un proyecto desde que se
    # crea, tenga o no personaje asignado todavía. No se puede cambiar
    # después (no está en ActorUpdateSchema).
    id_project: str


class ActorUpdateSchema(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    genero: Optional[Genero] = None
    fecha_de_nacimiento: Optional[date] = None

    talla_zapatos: Optional[str] = None
    ancho_espalda: Optional[str] = None
    pecho: Optional[str] = None
    cintura: Optional[str] = None
    cadera: Optional[str] = None
    largo_manga: Optional[str] = None
    largo_pierna: Optional[str] = None
    talla_anillo: Optional[str] = None
    contorno_cabeza: Optional[str] = None
    contorno_cuello: Optional[str] = None

    color_cabello: Optional[str] = None
    textura_cabello: Optional[str] = None
    tipo_piel: Optional[str] = None
    color_ojos: Optional[str] = None

    alergias: Optional[str] = None
    habilidades_especiales: Optional[str] = None
    restricciones: Optional[str] = None
    comentarios_adicionales: Optional[str] = None

    nacionalidad: Optional[str] = None
    doble_riesgo: Optional[bool] = None

    id_personaje: Optional[str] = None
