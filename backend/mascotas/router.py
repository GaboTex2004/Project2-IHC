# backend/mascotas/router.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from core.database import get_db
from . import models, schemas
from historial.models import Evento
from typing import Optional
from datetime import date

from usuarios.router import obtener_usuario_token 

router = APIRouter()

@router.get("/lista", response_model=list[schemas.Mascota])
def mis_mascotas(
    nombre: Optional[str] = None,
    estado: Optional[bool] = None,
    cuidado: Optional[str] = None,
    fecha_inicio: Optional[date] = None,
    fecha_fin: Optional[date] = None,
    db: Session = Depends(get_db), 
    usuario = Depends(obtener_usuario_token)
):
    query = db.query(models.Mascota).filter(models.Mascota.usuario_id == usuario.id)
    if nombre:
        query = query.filter(models.Mascota.nombre.ilike(f"%{nombre}%"))
    if estado is not None:
        query = query.filter(models.Mascota.estado == estado)
    if cuidado:
        query = query.filter(models.Mascota.cuidado.ilike(f"%{cuidado}%"))
    if fecha_inicio:
        query = query.filter(models.Mascota.fecha >= fecha_inicio)
    if fecha_fin:
        query = query.filter(models.Mascota.fecha <= fecha_fin)
    # Ordenados por fecha para ver primero lo más próximo
    mascotas = query.order_by(models.Mascota.fecha).all()
    return mascotas

@router.post("/crear", response_model=schemas.Mascota)
def crear_mascota(mascota: schemas.MascotaCreate, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    # La fecha del cuidado tiene que ser futura (misma regla que editar)
    if mascota.fecha <= date.today():
        raise HTTPException(status_code=400, detail="La fecha del cuidado debe ser futura")

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
    # Guardamos el evento para el historial
    db.add(Evento(
        usuario_id=usuario.id,
        mascota_id=mascota.id,
        mascota_nombre=mascota.nombre,
        cuidado=mascota.cuidado,
        tipo="realizado",
        detalle=f"Cuidado del {mascota.fecha} marcado como realizado"
    ))
    db.commit()
    return {"mensaje": "Cuidado completado exitosamente"}


@router.put("/editar/{id}", response_model=schemas.Mascota)
def editar_mascota(id: int, mascota_actualizada: schemas.MascotaCreate, db: Session = Depends(get_db), usuario = Depends(obtener_usuario_token)):
    mascota = db.query(models.Mascota).filter(models.Mascota.id == id, models.Mascota.usuario_id == usuario.id).first()
    
    if not mascota:
        raise HTTPException(status_code=404, detail="Mascota no encontrada")
    
    if mascota.estado:
        raise HTTPException(status_code=400, detail="No puedes editar un cuidado que ya fue realizado.")

    # Si cambia la fecha, tiene que ser futura (misma regla que reprogramar)
    if mascota_actualizada.fecha != mascota.fecha and mascota_actualizada.fecha <= date.today():
        raise HTTPException(status_code=400, detail="La nueva fecha debe ser futura")

    # Si cambió la fecha es una reprogramación y se guarda en el historial
    if mascota_actualizada.fecha != mascota.fecha:
        db.add(Evento(
            usuario_id=usuario.id,
            mascota_id=mascota.id,
            mascota_nombre=mascota_actualizada.nombre,
            cuidado=mascota_actualizada.cuidado,
            tipo="reprogramado",
            detalle=f"Del {mascota.fecha} al {mascota_actualizada.fecha}"
        ))

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

