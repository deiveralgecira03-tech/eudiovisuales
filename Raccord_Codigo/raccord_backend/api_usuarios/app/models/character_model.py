import uuid
from sqlalchemy import Column, String, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from app.config.database import Base

# ==========================================
# CHARACTER MODEL (tabla "personajes")
# ==========================================
# id_personaje es UUID, generado en Python (uuid.uuid4) — ver
# sql/009_uuid_primary_keys.sql. Antes lo armaba un trigger
# (gen_id_personaje, 'cast1', 'cast2'...) con una secuencia central.
class Character(Base):
    __tablename__ = "personajes"

    id_personaje = Column(
        UUID(as_uuid=True),
        primary_key=True,
        index=True,
        default=uuid.uuid4
    )

    nombre = Column(
        String(45),
        nullable=False
    )

    edad = Column(
        Integer,
        nullable=False
    )

    codigo_personaje = Column(
        String(30),
        nullable=False
    )
