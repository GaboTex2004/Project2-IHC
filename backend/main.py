from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core.database import engine, Base
from usuarios.router import router as usuarios_router

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

@app.get("/")
def root():
    return {"estado": "API funcionando correctamente"}