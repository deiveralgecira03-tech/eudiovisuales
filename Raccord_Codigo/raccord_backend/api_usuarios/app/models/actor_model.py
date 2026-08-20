from sqlalchemy import Column, String, Text, Date, Boolean, ForeignKey
from app.config.database import Base

# ==========================================
# ACTOR MODEL (tabla "actors")
# ==========================================
# id_actor NO se genera acá: la BD tiene un trigger (gen_id_actor) que
# arma 'act' + consecutivo en el INSERT. Se deja sin default para que
# el trigger la complete y SQLAlchemy la recupere con RETURNING.
#
# "genero" es ENUM en Postgres (generosex: masculino/fenemino/otro —
# el typo "fenemino" es el valor real que existe en la BD, no un error
# de este archivo), mapeado como texto plano igual que el resto de
# enums del proyecto (la validación estricta va en el schema Pydantic).
#
# id_personaje es la llave foránea hacia personajes.id_personaje (con
# ON DELETE CASCADE en la BD): así es como un actor queda "casteado"
# en un personaje. Es nullable porque un actor puede existir en el
# catálogo sin estar asignado todavía a ningún personaje.
class Actor(Base):
    __tablename__ = "actors"

    id_actor = Column(
        Text,
        primary_key=True,
        index=True
    )

    nombre = Column(String(45), nullable=False)
    apellido = Column(String(45), nullable=False)
    genero = Column(String(20), nullable=False)
    fecha_de_nacimiento = Column(Date, nullable=False)

    talla_zapatos = Column(String(10), nullable=False)
    ancho_espalda = Column(String(30), nullable=False)
    pecho = Column(String(30), nullable=False)
    cintura = Column(String(30), nullable=False)
    cadera = Column(String(30), nullable=False)
    largo_manga = Column(String(30), nullable=False)
    largo_pierna = Column(String(30), nullable=False)
    talla_anillo = Column(Text, nullable=True)
    contorno_cabeza = Column(String(30), nullable=True)
    contorno_cuello = Column(String(30), nullable=True)

    color_cabello = Column(String(45), nullable=False)
    textura_cabello = Column(String(45), nullable=False)
    tipo_piel = Column(String(45), nullable=False)
    color_ojos = Column(String(45), nullable=False)

    alergias = Column(Text, nullable=True)
    habilidades_especiales = Column(Text, nullable=True)
    restricciones = Column(Text, nullable=True)
    comentarios_adicionales = Column(Text, nullable=True)

    nacionalidad = Column(String(50), nullable=False)
    doble_riesgo = Column(Boolean, nullable=False)

    id_personaje = Column(  # llave foránea -> personajes.id_personaje
        Text,
        ForeignKey("personajes.id_personaje", ondelete="CASCADE"),
        nullable=True
    )
