from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import jwt
from core.database import get_db
from . import models, schemas
from pydantic import BaseModel

router = APIRouter()

SECRET_KEY = "clave_secreta_super_segura_para_mascota_al_dia"
ALGORITHM = "HS256"

def crear_token_acceso(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(hours=24)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

@router.post("/registro", response_model=schemas.UsuarioResponse, status_code=status.HTTP_201_CREATED)
def registrar_usuario(usuario: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.UsuarioDB).filter(models.UsuarioDB.correo == usuario.correo).first()
    if db_user:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")
    
    nuevo_usuario = models.UsuarioDB(
        nombre=usuario.nombre,
        correo=usuario.correo,
        password=usuario.password # En producción recuerda usar passlib para hash
    )
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario

@router.post("/login")
def login_usuario(credenciales: schemas.UsuarioLogin, db: Session = Depends(get_db)):
    usuario = db.query(models.UsuarioDB).filter(
        models.UsuarioDB.correo == credenciales.correo,
        models.UsuarioDB.password == credenciales.password
    ).first()
    
    if not usuario:
        raise HTTPException(status_code=401, detail="Correo o contraseña incorrectos")
    
    # Generar el Token JWT con el correo del usuario
    access_token = crear_token_acceso(data={"sub": usuario.correo})
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "correo": usuario.correo,
        "nombre": usuario.nombre
    }
class RecuperarRequest(BaseModel):
    correo: str
    
    @router.post("/usuarios/recuperar-password")
    def recuperar_password(request: RecuperarRequest):
        # 1. Buscar en la base de datos si el usuario con request.correo existe
        # 2. Generar token de recuperación o enviar correo
        # (Para pruebas, puedes simplemente retornar un mensaje de éxito)
        return {"mensaje": "Si el correo existe, se han enviado las instrucciones."}