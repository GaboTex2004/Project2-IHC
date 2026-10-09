# backend/mascotas/router.py
from datetime import date

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

def reprogramar_cuidado(
    id: int,
    nueva_fecha: date,
    db: Session,
    usuario,
):
    cuidado = db.query(models.Mascota).filter(
        models.Mascota.id == id,
        models.Mascota.usuario_id == usuario.id
    ).first()

    if not cuidado:
        raise HTTPException(status_code=404, detail="Cuidado no encontrado o no es tuyo")

    if cuidado.estado:
        raise HTTPException(
            status_code=400,
            detail="No puedes reprogramar un cuidado que ya fue realizado"
        )

    if nueva_fecha <= date.today():
        raise HTTPException(
            status_code=400,
            detail="La nueva fecha debe ser futura"
        )

    cuidado.fecha = nueva_fecha
    db.commit()
    db.refresh(cuidado)
    return cuidado

@router.put("/{id}/reprogramar", response_model=schemas.Mascota)
def actualizar_fecha_cuidado(
    id: int,
    datos: schemas.ReprogramarCuidado,
    db: Session = Depends(get_db),
    usuario = Depends(obtener_usuario_token)
):
    return reprogramar_cuidado(id, datos.fecha, db, usuario)

@router.put("/editar/{id}", response_model=schemas.Mascota)
def editar_mascota(id: int, mascota_actualizada: schemas.MascotaCreate, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id, models.Mascota.usuario_id == usuario.id).first()
    
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    
    if mascota.estado:
        raise HTTPException(status_code=400, detail="No puedes editar un cuidado que ya fue realizado.")

    # Actualizamos los datos
    mascota.nombre = mascota_actualizada.nombre
    mascota.tipo = mascota_actualizada.tipo
    mascota.cuidado = mascota_actualizada.cuidado
    mascota.fecha = mascota_actualizada.fecha
    
    db.commit()
    db.refresh(mascota)
    return mascota

@router.delete("/eliminar/{id}")
def eliminar_mascota(id: int, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id, models.Mascota.usuario_id == usuario.id).first()
    
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    
    db.delete(mascota)
    db.commit()
    return {"mensaje": "Mascota eliminada correctamente"}

@router.put("/{id}/completar")
def completar_cuidado(id: int, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id, models.Mascota.usuario_id == usuario.id).first()

    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")

    if mascota.estado:
        raise HTTPException(status_code=400, detail="El cuidado ya estaba completado")

    mascota.estado = True
    db.commit()
    return {"mensaje": "Cuidado completado exitosamente"}