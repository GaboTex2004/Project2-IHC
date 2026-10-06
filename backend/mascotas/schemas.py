from pydantic import BaseModel
from datetime import date

class MascotaCreate(BaseModel):
    nombre: str
    tipo: str
    cuidado: str
    fecha: date

class Mascota(BaseModel):
    id: int 
    nombre: str
    tipo: str
    cuidado: str
    fecha: date
    estado: bool
    usuario_id: int

    class Config:
        orm_mode=True