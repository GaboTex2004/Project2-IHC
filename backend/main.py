from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.database import engine, Base
from usuarios.router import router as usuarios_router
from mascotas.router import router as mascotas_router
# Crear las tablas automáticamente al iniciar
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Mascota al Día API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(usuarios_router, prefix="/api/usuarios", tags=["Usuarios"])
app.include_router(mascotas_router, prefix="/api/mascotas", tags=["Mascotas"])

@app.get("/")
def root():
    return {"estado": "API funcionando correctamente"}