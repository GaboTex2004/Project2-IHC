# backend/mascotas/router.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from core.database import get_db
from . import models, schemas

# IMPORTACIÓN CLAVE: Traemos la función desde tu módulo de usuarios
from usuarios.router import obtener_usuario_token 

router = APIRouter()

@router.get("/lista", response_model=list[schemas.Mascota])
def mis_mascotas(db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    mascotas = db.query(models.Mascota).filter(models.Mascota.usuario_id == usuario.id).all()
    return mascotas

@router.post("/crear", response_model=schemas.Mascota)
def crear_mascota(mascota: schemas.MascotaCreate, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    nueva_mascota = models.Mascota(
        nombre=mascota.nombre,
        tipo=mascota.tipo,
        cuidado=mascota.cuidado,
        fecha=mascota.fecha,
        usuario_id=usuario.id
    )
    db.add(nueva_mascota)
    db.commit()
    db.refresh(nueva_mascota)
    return nueva_mascota

@router.put("/{id}/completar")
def completar_cuidado(id: int, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    mascota = db.query(models.Mascota).filter(
        models.Mascota.id == id,
        models.Mascota.usuario_id == usuario.id
    ).first()

    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada o no es tuya")

    # No se puede completar un cuidado que ya está completado
    if mascota.estado:
        raise HTTPException(status_code=400, detail="El cuidado ya estaba completado")

    mascota.estado = True
    db.commit()
    return {"mensaje": "Cuidado completado exitosamente"}