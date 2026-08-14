from sqlalchemy import Column, Integer, String, Boolean
from app.config.database import Base

class Actor(Base):
    __tablename__ = "actors"

    id_actor = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True
    )

    nombre = Column(
        String(100),
        nullable=False
    )

    apellido = Column(
        String(100),
        nullable=False
    )

    email = Column(
        String(150)
    )

    telefono = Column(
        String(20)
    )

    activo = Column(
        Boolean,
        default=True
    )
