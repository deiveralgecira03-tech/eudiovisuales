from sqlalchemy import Column, String, Text
from app.config.database import Base

# ==========================================
# DEPARTMENT MODEL
# ==========================================
# Tabla "departamentos" en la BD. El id_departamento NO se genera acá:
# la base de datos tiene un trigger (gen_id_departamento) que lo arma
# como 'area' + consecutivo (area01, area02, ...) al hacer el INSERT.
# Por eso este modelo no define default para esa columna: se deja que
# el trigger la complete y SQLAlchemy la recupera automáticamente con
# RETURNING después del commit.
class Department(Base):
    __tablename__ = "departamentos"

    id_departamento = Column(
        Text,
        primary_key=True,
        index=True
    )

    nombre = Column(
        String(45),
        nullable=False
    )

    ubicacion = Column(
        Text,
        nullable=False
    )
