from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from core.database import get_db
from . import models, schemas
from typing import Optional

from usuarios.router import obtener_usuario_token

router = APIRouter()

@router.get("/", response_model=list[schemas.Evento])
def mi_historial(
    tipo: Optional[str] = None,
    db: Session = Depends(get_db),
    usuario = Depends(obtener_usuario_token)
):
    # Solo los eventos del usuario que inició sesión
    query = db.query(models.Evento).filter(models.Evento.usuario_id == usuario.id)
    if tipo:
        query = query.filter(models.Evento.tipo == tipo)
    # El más reciente primero
    eventos = query.order_by(models.Evento.fecha_hora.desc(), models.Evento.id.desc()).all()
    return eventos
