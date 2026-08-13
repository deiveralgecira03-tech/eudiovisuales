from pydantic import BaseModel
from typing import Optional
from datetime import time


# ==========================================
# PLAN DE RODAJE (día de rodaje / stripboard)
# ==========================================
# id_rodaje no va en el schema de creación: lo genera la BD
# ('rod' + consecutivo).
class ShootingDaySchema(BaseModel):
    version: str
    semana_grabacion: Optional[int] = None
    dia_rodaje: Optional[int] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    location: Optional[str] = None
    notas: Optional[str] = None
    activo: Optional[bool] = True


class ShootingDayUpdateSchema(BaseModel):
    version: Optional[str] = None
    semana_grabacion: Optional[int] = None
    dia_rodaje: Optional[int] = None
    hora_inicio: Optional[time] = None
    hora_fin: Optional[time] = None
    location: Optional[str] = None
    notas: Optional[str] = None
    activo: Optional[bool] = None
