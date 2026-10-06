from sqlalchemy import Column, Integer, String, Boolean, Date, ForeignKey
from core.database import Base

class Mascota(Base):
    __tablename__ = "mascotas"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String)
    tipo = Column(String)
    cuidado = Column(String)
    fecha = Column(Date)
    estado = Column(Boolean, default = False)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"))