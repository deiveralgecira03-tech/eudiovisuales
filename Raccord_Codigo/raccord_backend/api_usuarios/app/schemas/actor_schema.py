from pydantic import BaseModel
from typing import Optional, Literal
from datetime import date

GeneroActor = Literal["masculino", "fenemino", "otro"]

class ActorSchema(BaseModel):
    nombre: str
    apellido: str
    genero: GeneroActor
    fecha_de_nacimiento: date

    talla_zapatos: str
    ancho_espalda: str
    pecho: str
    cintura: str
    cadera: str
    largo_manga: str
    largo_pierna: str

    color_cabello: str
    textura_cabello: str
    tipo_piel: str
    color_ojos: str

    nacionalidad: str
    doble_riesgo: bool

    # Opcionales (nullable=True en la base de datos)
    talla_anillo: Optional[str] = None
    contorno_cabeza: Optional[str] = None
    contorno_cuello: Optional[str] = None
    alergias: Optional[str] = None
    habilidades_especiales: Optional[str] = None
    restricciones: Optional[str] = None
    comentarios_adicionales: Optional[str] = None
    id_personaje: Optional[str] = None


class ActorUpdateSchema(BaseModel):
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    genero: Optional[GeneroActor] = None
    fecha_de_nacimiento: Optional[date] = None

    talla_zapatos: Optional[str] = None
    ancho_espalda: Optional[str] = None
    pecho: Optional[str] = None
    cintura: Optional[str] = None
    cadera: Optional[str] = None
    largo_manga: Optional[str] = None
    largo_pierna: Optional[str] = None

    color_cabello: Optional[str] = None
    textura_cabello: Optional[str] = None
    tipo_piel: Optional[str] = None
    color_ojos: Optional[str] = None

    nacionalidad: Optional[str] = None
    doble_riesgo: Optional[bool] = None

    talla_anillo: Optional[str] = None
    contorno_cabeza: Optional[str] = None
    contorno_cuello: Optional[str] = None
    alergias: Optional[str] = None
    habilidades_especiales: Optional[str] = None
    restricciones: Optional[str] = None
    comentarios_adicionales: Optional[str] = None
    id_personaje: Optional[str] = None
