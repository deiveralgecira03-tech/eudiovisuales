import uuid
from sqlalchemy import Column, String, Text, Date, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.config.database import Base

# ==========================================
# ACTOR MODEL (tabla "actors")
# ==========================================
# id_actor es UUID, generado en Python (uuid.uuid4) — ver
# sql/009_uuid_primary_keys.sql. Antes lo armaba un trigger de Postgres
# ('act1', 'act2'...) con una secuencia central, propensa a colisionar
# si dos clientes crean actores sin conexión al mismo tiempo.
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
        UUID(as_uuid=True),
        primary_key=True,
        index=True,
        default=uuid.uuid4
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
        UUID(as_uuid=True),
        ForeignKey("personajes.id_personaje", ondelete="CASCADE"),
        nullable=True
    )

    # Aislamiento por proyecto (ver sql/015_project_scoping.sql). No basta
    # con resolverlo vía `id_personaje` porque ese campo es opcional (un
    # actor puede existir sin personaje asignado todavía) — sin su propio
    # id_project, un actor "suelto" no tendría forma de saber a qué
    # proyecto pertenece. Nullable=True solo para la migración de filas
    # existentes; toda fila nueva lo exige (ActorSchema).
    id_project = Column(
        UUID(as_uuid=True),
        ForeignKey("projects.id_project", ondelete="CASCADE"),
        nullable=True,
        index=True,
    )
