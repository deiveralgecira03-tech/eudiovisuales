from sqlalchemy import Column, String, Text, Date, Boolean, Enum, ForeignKey, FetchedValue
from app.config.database import Base

class Actor(Base):
    __tablename__ = "actors"

    id_actor = Column(
        Text,
        primary_key=True,
        server_default=FetchedValue()
    )

    nombre = Column(String(45), nullable=False)
    apellido = Column(String(45), nullable=False)

    genero = Column(
        Enum("masculino", "fenemino", "otro", name="generosex", native_enum=True, create_type=False),
        nullable=False
    )

    fecha_de_nacimiento = Column(Date, nullable=False)

    talla_zapatos = Column(String(10), nullable=False)
    ancho_espalda = Column(String(30), nullable=False)
    pecho = Column(String(30), nullable=False)
    cintura = Column(String(30), nullable=False)
    cadera = Column(String(30), nullable=False)
    largo_manga = Column(String(30), nullable=False)
    largo_pierna = Column(String(30), nullable=False)

    talla_anillo = Column(Text)
    contorno_cabeza = Column(String(30))
    contorno_cuello = Column(String(30))

    color_cabello = Column(String(45), nullable=False)
    textura_cabello = Column(String(45), nullable=False)
    tipo_piel = Column(String(45), nullable=False)
    color_ojos = Column(String(45), nullable=False)

    alergias = Column(Text)
    habilidades_especiales = Column(Text)
    restricciones = Column(Text)
    comentarios_adicionales = Column(Text)

    nacionalidad = Column(String(50), nullable=False)
    doble_riesgo = Column(Boolean, nullable=False)

    id_personaje = Column(
        Text,
        ForeignKey("personajes.id_personaje", onupdate="CASCADE", ondelete="CASCADE"),
        nullable=True
    )
