from sqlalchemy import Column, String, Integer, Text
from app.config.database import Base

# ==========================================
# CHARACTER MODEL (tabla "personajes")
# ==========================================
# id_personaje NO se genera acá: la BD tiene un trigger
# (gen_id_personaje) que arma 'cast' + consecutivo (cast1, cast2, ...)
# en el INSERT. Igual que Department/Scene, se deja sin default para
# que el trigger la complete y SQLAlchemy la recupere con RETURNING.
class Character(Base):
    __tablename__ = "personajes"

    id_personaje = Column(
        Text,
        primary_key=True,
        index=True
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
