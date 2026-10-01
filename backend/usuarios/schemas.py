from pydantic import BaseModel, EmailStr

class UsuarioCreate(BaseModel):
    nombre: str
    correo: EmailStr
    password: str

class UsuarioLogin(BaseModel):
    correo: EmailStr
    password: str

class UsuarioResponse(BaseModel):
    id: int
    nombre: str
    correo: EmailStr

    class Config:
        from_attributes = True