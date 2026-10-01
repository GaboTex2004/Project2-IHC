from sqlalchemy import Column, Integer, String
from core.database import Base

class UsuarioDB(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    correo = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False)  # Nota: En producción se guarda encriptado