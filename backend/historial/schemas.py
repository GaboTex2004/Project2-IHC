from pydantic import BaseModel
from datetime import datetime

class Evento(BaseModel):
    id: int
    mascota_id: int
    mascota_nombre: str
    cuidado: str
    tipo: str
    detalle: str
    fecha_hora: datetime

    class Config:
        orm_mode=True
