from sqlalchemy import Column, Integer, String, Text, Date
from app.config.database import Base

# ==========================================
# SCRIPT MODEL (tabla "guiones")
# ==========================================
# "estado" es un ENUM en Postgres (estado_guion: Borrador, Revisión,
# Aprobado, En Rodaje, Archivado). Igual que "document" en Client o
# "formato_de_produccion"/"genero" en Project, se mapea como texto
# plano en el modelo — psycopg2 convierte el enum de Postgres a string
# de forma transparente, y así se evita depender de sqlalchemy.Enum
# (que intentaría crear el tipo si la tabla no existe todavía).
class Script(Base):
    __tablename__ = "guiones"

    id_guion = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True
    )

    numero_de_version = Column(
        String(45),
        nullable=False,
        unique=True
    )

    fecha_de_emision = Column(
        Date,
        nullable=False
    )

    estado = Column(
        String(50),
        nullable=False
    )

    archivo = Column(
        Text,
        nullable=False
    )

    nombre = Column(
        String(100),
        nullable=False
    )

    descripcion = Column(
        Text
    )

    id_project = Column(  # llave foránea -> projects.id_project
        String(20),
        nullable=True
    )
