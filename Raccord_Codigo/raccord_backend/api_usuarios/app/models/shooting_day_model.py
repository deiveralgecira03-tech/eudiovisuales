import uuid
from sqlalchemy import Column, Integer, String, Text, Time, Boolean
from sqlalchemy.dialects.postgresql import UUID
from app.config.database import Base

# ==========================================
# SHOOTING DAY MODEL (tabla "plan_rodaje")
# ==========================================
# Representa un día de rodaje dentro del cronograma (el "stripboard"):
# semana, número de día de rodaje, horario de call time, locación y
# notas generales de ese día. Las escenas que se filman ese día se
# relacionan por escenas.id_rodaje (FK ON DELETE CASCADE hacia acá).
#
# id_rodaje NO se genera en Python: en la BD la columna tiene
# DEFAULT ('rod' || nextval(plan_rodaje_seq)), igual de automático que
# un SERIAL. Se deja sin default en el modelo para que Postgres la
# complete y SQLAlchemy la recupere con RETURNING (mismo patrón que
# Department/Scene, aunque allá el mecanismo es un trigger).
class ShootingDay(Base):
    __tablename__ = "plan_rodaje"

    id_rodaje = Column(
        UUID(as_uuid=True),
        primary_key=True,
        index=True,
        default=uuid.uuid4
    )

    version = Column(
        String(50),
        nullable=False
    )

    semana_grabacion = Column(
        Integer,
        nullable=True
    )

    dia_rodaje = Column(
        Integer,
        nullable=True
    )

    hora_inicio = Column(
        Time,
        nullable=True
    )

    hora_fin = Column(
        Time,
        nullable=True
    )

    location = Column(
        String(200),
        nullable=True
    )

    notas = Column(
        Text,
        nullable=True
    )

    activo = Column(
        Boolean,
        default=True
    )
